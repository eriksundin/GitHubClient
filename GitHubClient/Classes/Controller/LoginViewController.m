//
//  LoginViewController.m
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "LoginViewController.h"
#import "GitHubService.h"

@interface LoginViewController ()

@property (nonatomic, strong) GitHubService *service;
@property (nonatomic, weak) id<LoginViewConrollerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;

@end

@implementation LoginViewController

- (id)initWithGitHubService:(GitHubService *)service delegate:(id<LoginViewConrollerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _service = service;
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mark"]];
}

- (void)setLoginInProgress:(BOOL)inProgress {
    [self.loginButton setHidden:inProgress];
    if (inProgress) {
        [self.loginIndicator startAnimating];
    } else {
        [self.loginIndicator stopAnimating];
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [self setLoginInProgress:YES];
    
    __weak typeof(self) weakSelf = self;
    [self.service authenticateWithSuccess:^{
        
        // Let the delegate know we succeeded.
        [weakSelf.delegate loginViewControllerDidLogin:self];
        
    } failure:^(NSError *error) {
        
        [weakSelf setLoginInProgress:NO];
        // Simple error handling for now ...
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                   message:error.localizedDescription
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    }];
}

@end
