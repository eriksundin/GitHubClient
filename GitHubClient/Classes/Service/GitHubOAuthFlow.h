//
//  GitHubOAuthFlow.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubAuthConfig.h"

/** Errors */
extern NSString * const kGitHubOAuthFlowErrorDomain;

typedef NS_ENUM(NSUInteger, GitHubAuthFlowError) {
    GitHubAuthFlowErrorIdentifierMismatch, // There was a mismatch in the flow identifier going out and coming back from github
    GitHubAuthFlowErrorCodeMissing, // The OAuth authorize code was missing
    GitHubAuthFlowErrorTokenExchangeFailed, // The OAuth code could not be changed into an access token
    GitHubAuthFlowErrorUserCancelled // User did not complete the github login
};

/**
 Encapsulates the OAuth2 flow towards GitHub. Used by GitHubService.
*/
@class AFOAuthCredential;
@interface GitHubOAuthFlow : NSObject

/** Designated Initializer. */
- (instancetype)initWithAuthConfig:(GitHubAuthConfig *)authConfig;

/**
 Initiate the flow.
 */
- (void)startFlowWithSuccess:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

/** 
 Parse the authorization code and exchange it into a token.
 Return NO if the url is invalid.
*/
- (BOOL)continueAuthenticationFlowWithCodeInURL:(NSURL *)url;

@end
