//
//  GHRepo.h
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface GHRepo : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *repoDescription;
@property (nonatomic, assign, readonly, getter=isFork) BOOL fork;
@property (nonatomic, assign, readonly) NSUInteger stars;
@property (nonatomic, assign, readonly) NSUInteger watchers;
@property (nonatomic, strong, readonly) NSURL *githubURL;

@end
