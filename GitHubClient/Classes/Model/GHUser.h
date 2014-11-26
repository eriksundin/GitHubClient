//
//  GHUser.h
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface GHUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSURL *avatarURL;
@property (nonatomic, assign, readonly) NSUInteger repos;
@property (nonatomic, copy, readonly) NSString *location;

@end
