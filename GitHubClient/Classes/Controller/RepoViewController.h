//
//  RepoViewController.h
//  GitHubClient
//
//  Created by Erik Sundin on 26/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Shows information about a repo.
*/ 
@class GitHubService, GHRepo;
@interface RepoViewController : UIViewController

/** Designated Initializer. */
- (id)initWithGitHubService:(GitHubService *)service repo:(GHRepo *)repo;

@end
