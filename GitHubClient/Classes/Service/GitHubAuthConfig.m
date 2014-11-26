//
//  GitHubAuthConfig.m
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "GitHubAuthConfig.h"

@interface GitHubAuthConfig ()

@property (nonatomic, copy, readwrite) NSString *clientID;
@property (nonatomic, copy, readwrite) NSString *clientSecret;
@property (nonatomic, copy, readwrite) NSString *redirectURI;
@property (nonatomic, strong, readwrite) UIApplication *application;
@property (nonatomic, strong, readwrite) NSURL *baseURL;

@end

@implementation GitHubAuthConfig

+ (instancetype)configWithClientID:(NSString *)clientID
                      clientSecret:(NSString *)clientSecret
                       redirectURI:(NSString *)redirectURI
                           baseURL:(NSURL *)baseURL
                       application:(UIApplication *)application {
    GitHubAuthConfig *config = [[[self class] alloc] init];
    config.clientID = clientID;
    config.clientSecret = clientSecret;
    config.redirectURI = redirectURI;
    config.baseURL = baseURL;
    config.application = application;
    return config;
}

@end
