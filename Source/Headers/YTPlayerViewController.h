#import <UIKit/UIKit.h>
#import "YTPlayerResponse.h"

@interface YTPlayerViewController : UIViewController
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (readonly, nonatomic) NSString *contentVideoID;
@property (nonatomic, assign, readonly) CGFloat currentVideoTotalMediaTime;
@property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

- (void)seekToTime:(CGFloat)time;
- (NSString *)currentVideoID;
- (CGFloat)currentVideoMediaTime;
- (void)skipSegment;
@end
