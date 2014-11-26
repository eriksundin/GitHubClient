//
//  GitHubService.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubAuthConfig.h"

/** Posted when -clearAuthentication is called. */
extern NSString * const kGitHubServiceDidClearAuthenticationNotification;

/** Errors */
extern NSString * const kGitHubServiceErrorDomain;

typedef NS_ENUM(NSUInteger, GitHubServiceError) {
    GitHubServiceAuthenticationError, // Authentication failed, you need to re-authenticate
    GitHubServiceGenericError // A generic error, covers the rest. (deliberatly thin handling because of demo)
};

/**
 Service for interacting with the GitHub API.
 Authentication needs to be completed before any of the data API methods can be used.
*/
@class GHRepo, GHUser;
@protocol PaginationToken; // Defined at the end.
@interface GitHubService : NSObject

/** Designated Initializer. */
- (instancetype)initWithBaseURL:(NSURL *)baseURL authConfig:(GitHubAuthConfig *)authConfig;

///----------------------------
/// GitHub Authentication
///----------------------------

/**
 Start the authentication flow.
 */
- (void)authenticateWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 To be called from AppDelegate for resuming the flow after authorize completes in Safari.
 */
- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url;

/** 
 Returns YES if there is valid authentication.
 */
- (BOOL)isAuthenticationValid;

/** 
 Clears any valid authentication.
 Sends out a kGitHubServiceDidClearAuthenticationNotification notification when done.
 */
- (void)clearAuthentication;

///----------------------------
/// GitHub Data API
///----------------------------

/**
 Load the profile for the current user.
 */
- (void)userProfileWithSuccess:(void (^)(GHUser *user))success failure:(void (^)(NSError *error))failure;

/** 
 Load repos for the current user.
 Pass in an empty (nil) token to load from scratch. To load the next page pass in the token you got back
 in a previous load.
*/
- (void)userReposWithPaginationToken:(id<PaginationToken>)token
                             success:(void (^)(NSArray *repos, id<PaginationToken> next))success
                             failure:(void (^)(NSError *error))failure;

@end



/** Token that is used for load the next page for a paged result. */
@protocol PaginationToken <NSObject>

/** Returns YES if the end has been reached. */
- (BOOL)hasMoreResults;

@end

