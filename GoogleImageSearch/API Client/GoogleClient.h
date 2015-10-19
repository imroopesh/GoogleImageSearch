//
//  GoogleClient.h
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/17/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface GoogleClient : AFHTTPSessionManager

+(GoogleClient *) sharedClient;
+ (void)getImages:(NSString *)query withOffset:(int)offset
          success:(void (^)(NSURLSessionDataTask *, NSArray *))success
          failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end
