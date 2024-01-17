#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MobileFFmpeg/MobileFFmpegConfig.h"
#import "MobileFFmpeg/MobileFFmpeg.h"
#import "MobileFFmpeg/MobileFFprobe.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "Prefs/Localization.h"

@interface FFMpegDownloader : NSObject <LogDelegate, StatisticsDelegate>
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *tempName;
@property (nonatomic, strong) NSString *mediaName;
@property (nonatomic) NSInteger duration;
- (void)downloadAudio:(NSString *)audioURL;
- (void)downloadImage:(NSURL *)link;
- (void)shareMedia:(NSURL *)mediaURL;
@end