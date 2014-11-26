//
//  RepoViewController.m
//  GitHubClient
//
//  Created by Erik Sundin on 26/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "RepoViewController.h"
#import "GitHubService.h"
#import "GHRepo.h"

@interface RepoViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) GitHubService *service;
@property (nonatomic, strong) GHRepo *repo;
@property (weak, nonatomic) IBOutlet UILabel *repoNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repoImageView;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;
@property (weak, nonatomic) IBOutlet UILabel *watchersLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *repoURLButton;

@end

@implementation RepoViewController

- (id)initWithGitHubService:(GitHubService *)service repo:(GHRepo *)repo {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _service = service;
        _repo = repo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mark"]];

    [self.repoNameLabel setText:self.repo.name];
    UIImage *repoImage = [UIImage imageNamed:self.repo.isFork ? @"Fork" : @"Repo"];
    [self.repoImageView setImage:repoImage];
    [self.starsLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.repo.stars]];
    [self.watchersLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)self.repo.watchers]];
    [self.descriptionLabel setText:self.repo.repoDescription];
    [self.descriptionLabel sizeToFit];
}

#pragma mark - Open Repo in Safari

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:self.repo.githubURL];
    }
}

- (IBAction)repoURLButtonPressed:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Leaving Already?"
                                message:@"You are about to open this repo in Safari. Do you wish to continue?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}

@end
