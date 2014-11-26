//
//  RepoTableViewCell.h
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Cell used in ReposViewController.
 */
@class GHRepo;
@interface RepoTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) GHRepo *repo;

- (void)configureWithRepo:(GHRepo *)repo;

+ (CGFloat)cellHeight;

@end
