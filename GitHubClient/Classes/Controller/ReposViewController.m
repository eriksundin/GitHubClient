//
//  ReposViewController.h
//  GitHubClient
//
//  Created by Erik Sundin on 24/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "ReposViewController.h"
#import "GitHubService.h"
#import "RepoTableViewCell.h"
#import "ProfileHeaderView.h"
#import "RepoViewController.h"

@interface ReposViewController () <UITableViewDataSource, UITableViewDelegate, ProfileHeaderViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) GitHubService *service;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ProfileHeaderView *profileHeaderView;

@property (nonatomic, strong) NSMutableArray *repos;
@property (nonatomic, strong) id<PaginationToken> paginationToken;
@property (nonatomic, assign) BOOL loading;

@end

NSString * const kRepoCellReuseIdentifier = @"RepoCell";
NSInteger const kRetryAlertViewTag = 10;

@implementation ReposViewController

- (id)initWithGitHubService:(GitHubService *)service {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _repos = [NSMutableArray new];
        _service = service;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mark"]];
    
    // Register table view cell.
    [self.tableView registerNib:[UINib nibWithNibName:@"RepoTableViewCell" bundle:nil] forCellReuseIdentifier:kRepoCellReuseIdentifier];
    
    // Start loading repos
    [self triggerLoadRepos];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Repo loading

- (void)triggerLoadRepos {
    if (!self.loading) {
        self.loading = YES;
        
        // Load the user profile if needed.
        if (!self.profileHeaderView.user) {
            // Start loading user
            [self.service userProfileWithSuccess:^(GHUser *user) {
                [self.profileHeaderView configureWithUser:user];
            } failure:^(NSError *error) {
                // No-Op
            }];
        }
        
        [self.service userReposWithPaginationToken:self.paginationToken
                                           success:^(NSArray *repos, id<PaginationToken> next) {
                                               
                                               self.paginationToken = next;
                                               NSUInteger reposBeforeUpdate = [self.repos count];
                                               NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[repos count]];
                                               for (NSUInteger row = reposBeforeUpdate; row < reposBeforeUpdate + [repos count]; row++) {
                                                   [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
                                               }
                                               [self.repos addObjectsFromArray:repos];
                                               [self.tableView beginUpdates];
                                               [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                                               [self.tableView endUpdates];
                                               self.loading = NO;
                                               
                                           } failure:^(NSError *error) {
                                               
                                               // Simple error handling for now ...
                                               if (error.code == GitHubServiceAuthenticationError) {
                                                   [[[UIAlertView alloc] initWithTitle:@"Authentication Failed"
                                                                               message:@"You need to login again."
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil] show];
                                                   [self.service clearAuthentication];
                                                   
                                               } else {
                                                   
                                                   UIAlertView *retry = [[UIAlertView alloc] initWithTitle:@"Ops."
                                                                               message:error.localizedDescription
                                                                              delegate:self
                                                                     cancelButtonTitle:@"Call it a day"
                                                                     otherButtonTitles:@"Retry", nil];
                                                   [retry setTag:kRetryAlertViewTag];
                                                   [retry show];
                                               }
                                               
                                               self.loading = NO;
                                           }];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.repos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepoCellReuseIdentifier forIndexPath:indexPath];
    
    [cell configureWithRepo:self.repos[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.profileHeaderView; // There only ever will be one so ...
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RepoTableViewCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.profileHeaderView viewHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHRepo *repo = self.repos[indexPath.row];
    RepoViewController *repoController = [[RepoViewController alloc] initWithGitHubService:self.service repo:repo];
    [self.navigationController pushViewController:repoController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Load the next page once 2/3 of the results are scrolled.
    NSUInteger rows = [tableView numberOfRowsInSection:0];
    if (indexPath.row > (2 * rows) / 3) {
        if ([self.paginationToken hasMoreResults]) {
            [self triggerLoadRepos];
        }
    }
    
}

# pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kRetryAlertViewTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.service clearAuthentication];
        } else {
            [self triggerLoadRepos];
        }
    }
}

#pragma mark - <ProfileHeaderViewDelegate>

- (void)profileHeaderViewDidTapSignOut:(ProfileHeaderView *)view {
    [self.service clearAuthentication];
}

@end
