//
//  ViewController.h
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/10/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"


@interface MainViewController : UIViewController <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

- (void)loadImagesWithOffset:(int)offset;

@end
