//
//  GitHubServiceTests.m
//  GitHubClient
//
//  Created by Erik Sundin on 26/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RequestUtil.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <OHHTTPStubs.h>

#import "GitHubService.h"

@interface GitHubServiceTests : XCTestCase

@end

@implementation GitHubServiceTests

- (void)tearDown
{
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)testSuccessfulOAuth2Flow {
    
    // Construct Service Class with mocked UIApplication
    UIApplication *mockApplication = MKTMock([UIApplication class]);
    
    GitHubAuthConfig *config = [GitHubAuthConfig configWithClientID:@"test-id"
                                                       clientSecret:@"test-secret"
                                                        redirectURI:@"test-redirect://"
                                                            baseURL:[NSURL URLWithString:@"http://auth"] application:mockApplication];
    
    GitHubService *service = [[GitHubService alloc] initWithBaseURL:[NSURL URLWithString:@"http://api"]
                                                         authConfig:config];
    [service clearAuthentication];
    
    // Mock outgoing calls to github auth
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        
        // Take a look at the request and make sure it's a proper token exchange request
        NSString *query = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        NSDictionary *params = [RequestUtil dictionaryFromQueryString:query];
        
        return [[request.URL absoluteString] hasPrefix:@"http://auth/login/oauth/access_token"] &&
        [params[@"code"] isEqualToString:@"test"] &&
        [params[@"redirect_uri"] isEqualToString:@"test-redirect://"];
        
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        NSString* fixture = OHPathForFileInBundle(@"token_response.json",nil);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200 headers:@{@"Content-Type":@"text/json"}];
    }];
    
    // Setup an asynchronous expectation for when auth succeeds and start the auth flow.
    XCTestExpectation* authSuccess = [self expectationWithDescription:@"auth has succeeded"];
    
    [service authenticateWithSuccess:^{
        [authSuccess fulfill];
    } failure:^(NSError *error) {
    }];
    
    // Capture the authorize URL being lauched through UIApplication -openURL:
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [MKTVerify(mockApplication) openURL:[argument capture]];
    
    NSURL *authorize = [argument value];
    NSDictionary *params = [RequestUtil dictionaryFromQueryString:[authorize query]];
    
    // Verify we've got a pretty authorize URL
    assertThat(params[@"client_id"], equalTo(@"test-id"));
    assertThat(params[@"redirect_uri"], equalTo(@"test-redirect://"));
    NSString *identifier = params[@"state"];
    assertThat(identifier, notNilValue());
    
    // Construct a valid authorize callback and assert the service handles it.
    NSString *callbackURLString = [NSString stringWithFormat:@"test-redirect://?code=test&state=%@", identifier];
    BOOL handled = [service handleAuthorizationCallbackURL:[NSURL URLWithString:callbackURLString]];
    assertThatBool(handled, equalToBool(YES));
    
    // Now wait for the auth flow to succeed
    [self waitForExpectationsWithTimeout:0.5 handler:^(NSError *error) {
    }];
    
    [service clearAuthentication];
}

@end
