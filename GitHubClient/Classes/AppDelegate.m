//
//  AppDelegate.m
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "AppDelegate.h"
#import "GitHubService.h"
#import "LoginViewController.h"
#import "ReposViewController.h"

/** Details for the demo github app. */
NSString * const kDemoClientId = @"7de0380c2f35c52627aa";
NSString * const kDemoClientSecret = @"048b6ec246681df268456cb99afe71bc842c4d91";
NSString * const kDemoRedirectURI = @"githubapidemo://success";
NSString * const kGitHubAuthBaseURL = @"https://github.com";
NSString * const kGitHubAPIBaseURL = @"https://api.github.com";

@interface AppDelegate () <LoginViewConrollerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) GitHubService *service;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize the github service.
    GitHubAuthConfig *config = [GitHubAuthConfig configWithClientID:kDemoClientId
                                                       clientSecret:kDemoClientSecret
                                                        redirectURI:kDemoRedirectURI
                                                            baseURL:[NSURL URLWithString:kGitHubAuthBaseURL]
                                                        application:application];
    
    self.service = [[GitHubService alloc] initWithBaseURL:[NSURL URLWithString:kGitHubAPIBaseURL]
                                               authConfig:config];
    
    // Let us know when authentication is cleared.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autheticationClearedNotification:)
                                                 name:kGitHubServiceDidClearAuthenticationNotification
                                               object:self.service];
    
    // Setup the initial view controllers
    self.navigationController = [UINavigationController new];
    
    if ([self.service isAuthenticationValid]) {
        [self makeHomeViewControllerVisible];
    } else {
        [self makeLoginViewControllerVisible];
    }
    
    // Appearance
    UIColor *gitHubGray = [UIColor colorWithRed:82.0/255.0
                                          green:82.0/255.0
                                           blue:82.0/255.0
                                          alpha:1.0];
    [[UINavigationBar appearance] setTintColor:gitHubGray];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: gitHubGray}
                                                forState:UIControlStateNormal];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Pass on potential authentication callback to the GitHub service.
    return [self.service handleAuthorizationCallbackURL:url];
}

#pragma mark - View Controller Setup

- (void)makeLoginViewControllerVisible {
    LoginViewController *loginController = [[LoginViewController alloc] initWithGitHubService:self.service delegate:self];
    [self.navigationController setViewControllers:@[loginController] animated:YES];
}

- (void)makeHomeViewControllerVisible {
    ReposViewController *home = [[ReposViewController alloc] initWithGitHubService:self.service];
    [self.navigationController setViewControllers:@[home] animated:YES];
}

#pragma mark - Notifications

- (void)autheticationClearedNotification:(NSNotification *)notification {
    // Default to showing the login controller if authentication is cleared.
    [self makeLoginViewControllerVisible];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - <LoginViewControllerDelegate>

- (void)loginViewControllerDidLogin:(LoginViewController *)controller {
    [self makeHomeViewControllerVisible];
}

@end
