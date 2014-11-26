//
//  GitHubOAuthFlow.m
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "GitHubOAuthFlow.h"
#import <AFOAuth2Manager.h>
#import "RequestUtil.h"

NSString * const kGitHubOAuthFlowErrorDomain = @"GitHubOAuthFlow";

NSString * const kQueryStateKey = @"state";
NSString * const kQueryCodeKey = @"code";

typedef void (^GitHubOAuthFlowFailureBlock)(NSError *);
typedef void (^GitHubOAuthFlowSuccessBlock)(AFOAuthCredential *);

@interface GitHubOAuthFlow ()

@property (nonatomic, strong) AFOAuth2Manager *oauth2Manager;
@property (nonatomic, copy) GitHubOAuthFlowFailureBlock failure;
@property (nonatomic, copy) GitHubOAuthFlowSuccessBlock success;

@property (nonatomic, copy) NSString *authFlowIdentifier;
@property (nonatomic, strong) GitHubAuthConfig *authConfig;
@property (nonatomic, assign) BOOL callBackTriggered;

@end

@implementation GitHubOAuthFlow

- (instancetype)initWithAuthConfig:(GitHubAuthConfig *)authConfig
{
    self = [super init];
    if (self) {
        _authConfig = authConfig;
        _oauth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:authConfig.baseURL
                                                         clientID:authConfig.clientID
                                                           secret:authConfig.clientSecret];
        _authFlowIdentifier = [[NSUUID UUID] UUIDString];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startFlowWithSuccess:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    
    self.success = success;
    self.failure = failure;
    
    NSDictionary *params = @{
                             @"client_id" : self.authConfig.clientID,
                             @"state" : self.authFlowIdentifier,
                             @"redirect_uri" : self.authConfig.redirectURI
                            };
    NSURL *authorizeURL = [RequestUtil URLByAppendingParameters:params toURL:[self.authConfig.baseURL URLByAppendingPathComponent:@"login/oauth/authorize"]];
    
    // Launch Safari to start off the auth flow.
    [self.authConfig.application openURL:authorizeURL];
}

- (BOOL)continueAuthenticationFlowWithCodeInURL:(NSURL *)url {
    self.callBackTriggered = YES;
    BOOL handled = NO;
    
    if ([[url absoluteString] hasPrefix:self.authConfig.redirectURI]) {
        
        handled = YES;
        
        NSDictionary *query = [RequestUtil dictionaryFromQueryString:[url query]];
        NSString *state = query[kQueryStateKey];
        NSString *code = query[kQueryCodeKey];
        GitHubOAuthFlowFailureBlock fail = self.failure;
        GitHubOAuthFlowSuccessBlock success = self.success;
        
        if (![self.authFlowIdentifier isEqualToString:state]) {
            
            NSError *error = [NSError errorWithDomain:kGitHubOAuthFlowErrorDomain
                                                 code:GitHubAuthFlowErrorIdentifierMismatch
                                             userInfo:nil];
            fail(error);
            
        } else if (!code) {
            
            NSError *error = [NSError errorWithDomain:kGitHubOAuthFlowErrorDomain
                                                 code:GitHubAuthFlowErrorCodeMissing
                                             userInfo:nil];
            fail(error);
            
        } else {
            [self.oauth2Manager authenticateUsingOAuthWithURLString:@"/login/oauth/access_token"
                                                               code:code
                                                        redirectURI:self.authConfig.redirectURI
                                                            success:^(AFOAuthCredential *credential) {
                                                            
                                                                success(credential);
                                                            
                                                            } failure:^(NSError *error) {
                                                                
                                                                NSError *newError = [NSError errorWithDomain:kGitHubOAuthFlowErrorDomain
                                                                                                        code:GitHubAuthFlowErrorTokenExchangeFailed
                                                                                                    userInfo:@{NSUnderlyingErrorKey : error}];
                                                                fail(newError);
                                                                
                                                            }];
            self.success = nil;
            self.failure = nil;
        }
    }
    
    return handled;
}

#pragma mark - Private Methods

/**
 If the user starts the flow but does not follow through, and then starts the app
 the flow will continue waiting for the call back. By listening to when the app becomes 
 active we can fail the flow unless the callback was triggered.
 */
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!self.callBackTriggered) {
        GitHubOAuthFlowFailureBlock fail = self.failure;
        if (fail) {
            NSError *newError = [NSError errorWithDomain:kGitHubOAuthFlowErrorDomain
                                                    code:GitHubAuthFlowErrorUserCancelled
                                                userInfo:nil];
            fail(newError);
        }
        self.success = nil;
        self.failure = nil;
    }
}

@end
