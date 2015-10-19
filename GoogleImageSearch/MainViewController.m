//
//  ViewController.m
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/10/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import "MainViewController.h"

#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

#import "Image.h"
#import "ImageCell.h"
#import "GoogleClient.h"



static const int columnCountPortrait = 3;
static const int columnCountLandscape = 3;
static const CGFloat cellEqualSpacing = 15.0f;


static NSString * const ImageCellIdentifier = @"ImageCell";

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, assign) CGFloat cellWidth;
@property (strong, nonatomic) NSArray *cellColors;


@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];


    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:ImageCellIdentifier];
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, cellEqualSpacing, 0, cellEqualSpacing);
    layout.verticalItemSpacing = cellEqualSpacing;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateLayout];
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                            duration:duration];
    
    [self updateLayout];
}

- (void)updateLayout
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    
    layout.columnCount = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) ?
    columnCountPortrait :
    columnCountLandscape;
    layout.itemWidth = (self.collectionView.bounds.size.width - (layout.columnCount + 1) * cellEqualSpacing) / layout.columnCount;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.images count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier
                                                                       forIndexPath:indexPath];
    
    Image *imageRecord = [self.images objectAtIndex:indexPath.row];
    
    cell.imageView.backgroundColor = [UIColor grayColor];
    //    [cell.imageView setImageWithURL:imageRecord.thumbnailURL];
    [cell.imageView setImageWithURL:imageRecord.imageURL];
    
    
    // Check if this has been the last item, if so start loading more images...
    if (indexPath.row == [self.images count] - 1) {
        [self loadImagesWithOffset:[self.images count]];
    };
    
    return cell;
}


#pragma mark - CHTCollectionViewWaterfallLayoutDelagate

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(CHTCollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Image *image = [self.images objectAtIndex:indexPath.row];
    
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    
    return image.thumbnailSize.height * (layout.itemWidth / image.thumbnailSize.width);
}


#pragma mark - Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Dismiss the keyboard
    [searchBar resignFirstResponder];
    
    [self loadImagesWithOffset:0];
}


- (void)loadImagesWithOffset:(int)offset
{
    if ([self.searchbar.text isEqual:@""]) {
        return;
    }
    
    if (offset == 0) {
        // Clear the images array and refresh the table view so it's empty
        [self.images removeAllObjects];
        [self.collectionView reloadData];
        
        // Show a loading spinner
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    __weak MainViewController *weakSelf = self;
    
    [GoogleClient getImages:self.searchbar.text
                  withOffset:offset
                     success:^(NSURLSessionDataTask *task, NSArray *imageArray) {
                         
                         if (offset == 0) {
                             weakSelf.images = [NSMutableArray arrayWithArray:imageArray];
                         } else {
                             [weakSelf.images addObjectsFromArray:imageArray];
                         }
                         
                         [weakSelf.collectionView reloadData];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         });
                     }
      
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         
                         NSLog(@"An error occured while searching for images, %@", [error description]);
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                         });
                    }
      ];
}


@end
