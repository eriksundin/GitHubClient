//
//  GitHubAuthConfig.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 Authentication configuration wrapper for the GitHubService.
 */
@interface GitHubAuthConfig : NSObject

@property (nonatomic, copy, readonly) NSString *clientID;
@property (nonatomic, copy, readonly) NSString *clientSecret;
@property (nonatomic, copy, readonly) NSString *redirectURI;
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) UIApplication *application; // Used to launch external link.

/** Designated factory method. */
+ (instancetype)configWithClientID:(NSString *)clientID
                      clientSecret:(NSString *)clientSecret
                       redirectURI:(NSString *)redirectURI
                           baseURL:(NSURL *)baseURL
                       application:(UIApplication *)application;

@end
