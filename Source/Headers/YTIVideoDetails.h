#import "YTIThumbnailDetails.h"

@interface YTIVideoDetails : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *thumbnail;
@end