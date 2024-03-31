#import "YTIStreamingData.h"
#import "YTIVideoDetails.h"

@interface YTIPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIStreamingData *streamingData;
@property (nonatomic, assign, readonly) YTIVideoDetails *videoDetails;
@end