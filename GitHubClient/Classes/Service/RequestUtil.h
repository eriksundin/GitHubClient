//
//  RequestUtil.h
//  GitHubClient
//
//  Created by Erik Sundin on 25/11/14.
//  Copyright (c) 2014 Erik Sundin. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Helper util to do common request tasks. */
@interface RequestUtil : NSObject

/** Turn a HTTP query string into a dictionary. */
+ (NSDictionary *)dictionaryFromQueryString:(NSString *)queryString;

/** Create a URL with query parameters */
+ (NSURL *)URLByAppendingParameters:(NSDictionary *)parameters toURL:(NSURL *)url;

@end
