#import "Image.h"
#import "ImageCell.h"
#import "GoogleClient.h"
#import "SearchResultsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"



static const int columnCount = 3;
static const CGFloat cellEqualSpacing = 15.0f;

static NSString * const ImageCellIdentifier = @"ImageCell";

@interface SearchResultsViewController()

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) CGFloat cellWidth;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end


@implementation SearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:ImageCellIdentifier];
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, cellEqualSpacing, 0, cellEqualSpacing);
    layout.verticalItemSpacing = cellEqualSpacing;
    layout.columnCount = columnCount;
    [self updateView];
    
    [self arrangeImagesAtOffset:0];
    [[self navigationController] setNavigationBarHidden:NO];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)updateView
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier
                                                                forIndexPath:indexPath];
    
    Image *image = [self.images objectAtIndex:indexPath.row];
    
    cell.imageView.backgroundColor = [UIColor grayColor];
    [cell.imageView setImageWithURL:image.thumbnailURL];
    
    if (indexPath.row == [self.images count] - 1) {
        [self arrangeImagesAtOffset:[self.images count]];
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


- (void)arrangeImagesAtOffset:(int)offset
{
    if ([self.searchString isEqual:@""]) {
        return;
    }
    
    if (offset == 0) {
        [self.images removeAllObjects];
        [self.collectionView reloadData];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    __weak SearchResultsViewController *weakSelf = self;
    
    [GoogleClient getImages:self.searchString
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
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        });

                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                            message:error.localizedRecoverySuggestion
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"OK", nil];
                        alertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                        };
                        [alertView show];
                    }
     ];
}

@end
