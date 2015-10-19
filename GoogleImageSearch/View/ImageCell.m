//
//  ImageCell.m
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/17/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import "ImageCell.h"


@interface ImageCell()

@property (strong, readwrite, nonatomic) UIImageView *imageView;

@end

@implementation ImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _imageView.layer.cornerRadius = 5.0f;
        
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}


@end
