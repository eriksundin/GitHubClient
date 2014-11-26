//
//  GHUser.m
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "GHUser.h"

@implementation GHUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"avatarURL": @"avatar_url",
             @"repos": @"public_repos",
             @"location" : @"location"
             };
}

+ (NSValueTransformer *)avatarURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
