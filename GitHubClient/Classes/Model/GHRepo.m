//
//  GHRepo.m
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "GHRepo.h"

@implementation GHRepo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"full_name",
             @"repoDescription": @"description",
             @"fork": @"fork",
             @"stars": @"stargazers_count",
             @"watchers": @"watchers_count",
             @"githubURL": @"html_url"
             };
}

+ (NSValueTransformer *)githubURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
