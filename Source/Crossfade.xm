#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "Source/Headers/YTPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL crossfadeEnabled = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"crossfade");

@interface YTPlayerViewController (YTMUltimate)
@property (nonatomic, strong) AVPlayer *ytm_player;
@property (nonatomic, strong) NSTimer *ytm_timer;
@end

%hook YTPlayerViewController

- (void)viewDidLoad {
    %orig;

    if (crossfadeEnabled) {
        // Find the AVPlayer instance
        unsigned int ivarCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            NSString *name = [NSString stringWithUTF8String:ivarName];

            id ivarValue = [self valueForKey:name];
            if ([ivarValue isKindOfClass:[AVPlayer class]]) {
                self.ytm_player = (AVPlayer *)ivarValue;
                NSLog(@"YTMusicUltimate: Found AVPlayer instance: %@", self.ytm_player);
                break;
            }
        }
        free(ivars);

        if (self.ytm_player) {
            self.ytm_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkForCrossfade) userInfo:nil repeats:YES];
        } else {
            NSLog(@"YTMusicUltimate: Could not find AVPlayer instance.");
        }
    }
}

%new
- (void)checkForCrossfade {
    if (crossfadeEnabled && self.ytm_player) {
        CGFloat currentTime = [self currentVideoMediaTime];
        CGFloat totalTime = [self currentVideoTotalMediaTime];

        if (totalTime > 0) {
            if (totalTime - currentTime < 5.0) {
                // Fade out
                float volume = (totalTime - currentTime) / 5.0;
                self.ytm_player.volume = volume;
            } else if (currentTime < 5.0) {
                // Fade in
                float volume = currentTime / 5.0;
                self.ytm_player.volume = volume;
            } else {
                // Ensure volume is at max during normal playback
                if (self.ytm_player.volume < 1.0) {
                    self.ytm_player.volume = 1.0;
                }
            }
        }
    }
}

- (void)dealloc {
    if (self.ytm_timer) {
        [self.ytm_timer invalidate];
        self.ytm_timer = nil;
    }
    self.ytm_player = nil;
    %orig;
}

%end
