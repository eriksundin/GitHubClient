//
//  ProfileHeaderView.h
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Shows a summary of the currently logged in User.
 */
@class GHUser;
@protocol ProfileHeaderViewDelegate;
@interface ProfileHeaderView : UIView

@property (nonatomic, strong, readonly) GHUser *user;
@property (nonatomic, weak) IBOutlet id<ProfileHeaderViewDelegate> delegate;

- (CGFloat)viewHeight;

- (void)configureWithUser:(GHUser *)user;

@end

@protocol ProfileHeaderViewDelegate <NSObject>

- (void)profileHeaderViewDidTapSignOut:(ProfileHeaderView *)view;

@end
