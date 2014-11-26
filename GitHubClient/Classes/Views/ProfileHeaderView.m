//
//  ProfileHeaderView.m
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "GHUser.h"
#import <UIKit+AFNetworking.h>

@interface ProfileHeaderView () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reposLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation ProfileHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setElementsHidden:YES];
}

- (CGFloat)viewHeight {
    return 74.0;
}

- (void)setElementsHidden:(BOOL)hidden {
    CGFloat alpha = hidden ? 0.0 : 1.0;
    self.avatar.alpha = alpha;
    self.nameLabel.alpha = alpha;
    self.reposLabel.alpha = alpha;
    self.locationLabel.alpha = alpha;
}

- (void)configureWithUser:(GHUser *)user {
    _user = user;
    
    [self.avatar setImageWithURL:user.avatarURL];
    [self.nameLabel setText:user.name];
    [self.locationLabel setText:user.location];
    [self.reposLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)user.repos]];
    
    [UIView animateWithDuration:0.3
                          delay:0.5
                        options:0
                     animations:^{
                         [self setElementsHidden:NO];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.delegate profileHeaderViewDidTapSignOut:self];
    }
}

- (IBAction)logoutTapped:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Leaving Already?"
                                message:@"You are about to sign out from your account. Do you wish to continue?"
                               delegate:self
                      cancelButtonTitle:@"No way"
                      otherButtonTitles:@"Yeah, done.", nil] show];
}

@end
