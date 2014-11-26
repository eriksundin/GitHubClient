//
//  RepoTableViewCell.m
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "RepoTableViewCell.h"
#import "GHRepo.h"

@interface RepoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *repoNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repoImageView;

@end

@implementation RepoTableViewCell

- (void)configureWithRepo:(GHRepo *)repo {
    _repo = repo;
    self.repoNameLabel.text = repo.name;
    UIImage *repoImage = [UIImage imageNamed:repo.isFork ? @"Fork" : @"Repo"];
    [self.repoImageView setImage:repoImage];
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

@end
