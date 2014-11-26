//
//  LoginViewController.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Handles Login to GitHub.
 */
@class GitHubService;
@protocol LoginViewConrollerDelegate;
@interface LoginViewController : UIViewController

/** Designated Initializer. */
- (id)initWithGitHubService:(GitHubService *)service delegate:(id<LoginViewConrollerDelegate>)delegate;

@end

@protocol LoginViewConrollerDelegate <NSObject>

- (void)loginViewControllerDidLogin:(LoginViewController *)controller;

@end