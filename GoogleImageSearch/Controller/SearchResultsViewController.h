#import <Foundation/Foundation.h>
#import "CHTCollectionViewWaterfallLayout.h"


@interface SearchResultsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property(strong, nonatomic) NSString *searchString;

@end
