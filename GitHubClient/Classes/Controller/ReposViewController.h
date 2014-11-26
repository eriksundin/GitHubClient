//
//  ReposViewController.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Main view controller. Shows the current users repos.
*/
@class GitHubService;
@interface ReposViewController : UIViewController

/** Designated Initializer. */
- (id)initWithGitHubService:(GitHubService *)service;

@end
