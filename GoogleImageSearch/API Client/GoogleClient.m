#import "GoogleClient.h"
#import "Image.h"

@implementation GoogleClient

+(GoogleClient *) sharedClient
{
    static GoogleClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[GoogleClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ajax.googleapis.com"]];
    });
    
    return _sharedClient;
}



+ (void)getImages:(NSString *)query withOffset:(int)offset
                                        success:(void (^)(NSURLSessionDataTask *, NSArray *))success
                                        failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSDictionary *params = @{ @"v"       : @"1.0",
                              @"rsz"     : @"8",
                              @"start"   : [@(offset) stringValue],
                              @"q"       : query
                              };
    
    [[GoogleClient sharedClient] GET:@"ajax/services/search/images" parameters:params
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 if ([responseObject objectForKey:@"responseData"] == [NSNull null]) {
                                     return;
                                 }
                                 
                                 NSArray *jsonObjects = [[responseObject objectForKey:@"responseData"] objectForKey:@"results"];
                                 
                                 NSMutableArray *images = [NSMutableArray arrayWithCapacity:jsonObjects.count];
                                 for (NSDictionary *jsonDict in jsonObjects) {
                                     Image *image = [[Image alloc] init];
                                     
                                     image.thumbnailURL = [NSURL URLWithString:[jsonDict objectForKey:@"tbUrl"]];
                                     image.thumbnailSize = CGSizeMake([[jsonDict valueForKeyPath:@"tbWidth"] floatValue],
                                                                      [[jsonDict valueForKeyPath:@"tbHeight"] floatValue]);
                                     
                                     image.imageSize = CGSizeMake([[jsonDict valueForKeyPath:@"width"] floatValue],
                                                                  [[jsonDict valueForKeyPath:@"height"] floatValue]);
                                     
                                     [images addObject:image];
                                 }
                                 success(task, images);
                             }
                             failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                                 failure(dataTask, error);
                             }];
}


@end
