//
//  GitHubService.m
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "GitHubService.h"

#import <AFOAuth2Manager.h>
#import <AFHTTPRequestSerializer+OAuth2.h>
#import <AFNetworking.h>
#import <Mantle.h>

#import "GitHubOAuthFlow.h"
#import "GitHubAuthConfig.h"
#import "RequestUtil.h"

#import "GHUser.h"
#import "GHRepo.h"

/** Internal implementation of a pagination token. */
@interface PaginationTokenImpl : NSObject <PaginationToken>

@property (nonatomic, strong) NSURL *nextURL;
@property (nonatomic, strong) NSDictionary *parameters;

+ (id<PaginationToken>)tokenFromLinkHeader:(NSString *)header;

@end

/** Constants. */
NSString * const kGitHubServiceErrorDomain = @"GitHubService";
NSString * const kGitHubServiceDidClearAuthenticationNotification = @"GitHubServiceDidClearAuthenticationNotification";
NSString * const kGitHubServiceOAuthCredentialIdentifier = @"GitHubServiceCredential";


@interface GitHubService ()

@property (nonatomic, strong) GitHubAuthConfig *authConfig;
@property (nonatomic, strong) GitHubOAuthFlow *authflow;

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end

@implementation GitHubService

- (instancetype)initWithBaseURL:(NSURL *)baseURL authConfig:(GitHubAuthConfig *)authConfig {
    self = [super init];
    if (self) {
        _authConfig = authConfig;
        
        // Setup the Request manager
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        [_requestManager.requestSerializer setValue:@"application/vnd.github.v3+json" forHTTPHeaderField:@"Accept"];
        
        // Restore any credential we might have
        AFOAuthCredential *credential = [self savedCredential];
        if (credential) {
            [_requestManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        }
    }
    return self;
}

- (void)authenticateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    
    // If we already have a credential we'll just pass through.
    if ([self isAuthenticationValid]) {
        if (success) success();
    } else {
        
        // Create a new authenication flow.
        self.authflow = [[GitHubOAuthFlow alloc] initWithAuthConfig:self.authConfig];
        
        __weak typeof(self) weakSelf = self;
        [self.authflow startFlowWithSuccess:^(AFOAuthCredential *credential){
            
            // Store the credential and update our request manager.
            [AFOAuthCredential storeCredential:credential
                                withIdentifier:kGitHubServiceOAuthCredentialIdentifier];
            [weakSelf.requestManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            
            if (success) success();
            weakSelf.authflow = nil;
            
        } failure:^(NSError *error) {
            NSLog(@"Failed auth flow. %@", error);
            if (failure) {
                NSError *serviceError = [NSError errorWithDomain:kGitHubServiceErrorDomain code:GitHubServiceAuthenticationError userInfo:@{NSUnderlyingErrorKey: error}];
                failure(serviceError);
            }
        }];
    }
}

- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url {
    return [self.authflow continueAuthenticationFlowWithCodeInURL:url];
}

- (AFOAuthCredential *)savedCredential {
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kGitHubServiceOAuthCredentialIdentifier];
}

- (BOOL)isAuthenticationValid {
    return [self savedCredential] != nil;
}

- (void)clearAuthentication {
    [AFOAuthCredential deleteCredentialWithIdentifier:kGitHubServiceOAuthCredentialIdentifier];
    [self.requestManager.requestSerializer clearAuthorizationHeader];
    
    // Let interested parties know.
    [[NSNotificationCenter defaultCenter] postNotificationName:kGitHubServiceDidClearAuthenticationNotification
                                                        object:self];
}

#pragma mark - GitHub API

- (void)userProfileWithSuccess:(void (^)(GHUser *))success failure:(void (^)(NSError *))failure {
    
    [self.requestManager GET:@"/user" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *userJSON) {
        
        NSError *error = nil;
        GHUser *user = [MTLJSONAdapter modelOfClass:[GHUser class]
                                 fromJSONDictionary:userJSON
                                              error:&error];
        if (error) {
            NSLog(@"Failed to parse user JSON. %@", error);
            if (failure) {
                NSError *serviceError = [NSError errorWithDomain:kGitHubServiceErrorDomain code:GitHubServiceGenericError userInfo:@{NSUnderlyingErrorKey: error}];
                failure(serviceError);
            }
        } else {
            if (success) success(user);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to fetch user profile. %@", error);
        if (failure) {
            NSError *serviceError = [self serviceErrorFromError:error statusCode:operation.response.statusCode];
            failure(serviceError);
        }
    }];
}

- (void)userReposWithPaginationToken:(PaginationTokenImpl *)token
                             success:(void (^)(NSArray *, id<PaginationToken>))success
                             failure:(void (^)(NSError *))failure {
    
    [self.requestManager GET:@"/user/repos" parameters:token.parameters success:^(AFHTTPRequestOperation *operation, NSArray *reposJSON) {
        
        NSMutableArray *repos = [[NSMutableArray alloc] initWithCapacity:[reposJSON count]];
        for (NSDictionary *repoJSON in reposJSON) {
            NSError *error = nil;
            GHRepo *repo = [MTLJSONAdapter modelOfClass:[GHRepo class]
                                     fromJSONDictionary:repoJSON
                                                  error:&error];
            if (error) {
                NSLog(@"Failed parse repo JSON. %@", error);
                if (failure) failure(error);
                return;
            }
            [repos addObject:repo];
        }
        
        // Parse next link from headers.
        NSString *linkHeader = operation.response.allHeaderFields[@"Link"];
        id<PaginationToken> token = [PaginationTokenImpl tokenFromLinkHeader:linkHeader];
        
        if (success) success(repos, token);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        NSLog(@"Failed to fetch repos. %@", error);
        if (failure) {
            NSError *serviceError = [self serviceErrorFromError:error statusCode:operation.response.statusCode];
            failure(serviceError);
        }
    }];
}

#pragma mark - Private methods

- (NSError *)serviceErrorFromError:(NSError *)error statusCode:(NSInteger)status {
    GitHubServiceError code = status == 401 ? GitHubServiceAuthenticationError : GitHubServiceGenericError;
    NSString *errorDescription;
    if ([error.domain isEqualToString:NSURLErrorDomain]  && error.code == NSURLErrorNotConnectedToInternet) {
        errorDescription = @"Seems like you're not connected to the Internet.";
    } else {
        errorDescription = @"Hmm. Something went wrong. Is it cloudy outside? That might be it.";
    }
    return [NSError errorWithDomain:kGitHubServiceErrorDomain
                               code:code
                           userInfo:@{NSUnderlyingErrorKey: error,
                                      NSLocalizedDescriptionKey: errorDescription}];
}

@end

@implementation PaginationTokenImpl

+ (id<PaginationToken>)tokenFromLinkHeader:(NSString *)header {
    
    PaginationTokenImpl *token = [[PaginationTokenImpl alloc] init];;
    NSString *expression = @"<.*>; rel=\"next\"";
        NSRange range = [header rangeOfString:expression options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            
            // Get the next-URL out from the rel
            NSString *rel = [header substringWithRange:range];
            NSString *urlString = [[rel componentsSeparatedByString:@">"][0] substringFromIndex:1];
            token.nextURL = [NSURL URLWithString:urlString];
            token.parameters = [RequestUtil dictionaryFromQueryString:[token.nextURL query]];
        
        }
    return token;
}

- (BOOL)hasMoreResults {
    return self.nextURL != nil;
}

@end
