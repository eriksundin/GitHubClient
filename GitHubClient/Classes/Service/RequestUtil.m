//
//  RequestUtil.m
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import "RequestUtil.h"

@implementation RequestUtil

+ (NSDictionary *)dictionaryFromQueryString:(NSString *)queryString {
    NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *queryPart in [queryString componentsSeparatedByString:@"&"]) {
        NSArray *queryComponents = [queryPart componentsSeparatedByString:@"="];
        queryDictionary[queryComponents[0]] = [queryComponents[1] stringByRemovingPercentEncoding];
    }
    return queryDictionary;
}

+ (NSURL *)URLByAppendingParameters:(NSDictionary *)parameters toURL:(NSURL *)url {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@?", [url absoluteString]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [urlString appendFormat:@"%@=%@&", key, [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }];
    // Remove last &-sign.
    return [NSURL URLWithString:[urlString substringToIndex:[urlString length] - 1]];
}

@end
