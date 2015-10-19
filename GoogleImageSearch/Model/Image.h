//
//  Image.h
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/17/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Image : NSObject

@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, assign) CGSize imageSize;


@end
