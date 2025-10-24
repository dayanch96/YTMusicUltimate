#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "Source/Headers/YTPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL crossfadeEnabled() {
    return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"crossfade");
}

#pragma mark - YTPlayerViewController Category

@interface YTPlayerViewController (YTMUltimate)
@property (nonatomic, strong) AVPlayer *ytm_player;
@property (nonatomic, strong) id ytm_timeObserver;
- (void)checkForCrossfade;
- (void)cleanupCrossfade;
@end

#pragma mark - Logos Hooks

%hook YTPlayerViewController

// The feature was previously initialized in viewDidLoad, which was too early and caused a crash.
// By moving the logic to `didActivateVideo`, we ensure the player is ready, making the feature stable.
- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;

    // Clean up any previous observer before starting a new one.
    [self cleanupCrossfade];

    if (crossfadeEnabled()) {
        unsigned int ivarCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            const char *ivarName = ivar_getName(ivar);
            NSString *name = [NSString stringWithUTF8String:ivarName];

            id ivarValue = [self valueForKey:name];
            if ([ivarValue isKindOfClass:[AVPlayer class]]) {
                self.ytm_player = (AVPlayer *)ivarValue;
                break;
            }
        }
        free(ivars);

        if (self.ytm_player) {
            __weak typeof(self) weakSelf = self;
            self.ytm_timeObserver = [self.ytm_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                [weakSelf checkForCrossfade];
            }];
        }
    }
}

%new
- (void)checkForCrossfade {
    if (crossfadeEnabled() && self.ytm_player) {
        CGFloat currentTime = self.currentVideoMediaTime;
        CGFloat totalTime = self.currentVideoTotalMediaTime;

        if (CMTIME_IS_VALID(self.ytm_player.currentTime) && totalTime > 0) {
            // Fade out in the last 5 seconds
            if (totalTime - currentTime < 5.0) {
                self.ytm_player.volume = (totalTime - currentTime) / 5.0;
            }
            // Fade in in the first 5 seconds
            else if (currentTime < 5.0) {
                self.ytm_player.volume = currentTime / 5.0;
            }
            // Otherwise, ensure volume is at max
            else {
                if (self.ytm_player.volume < 1.0) {
                    self.ytm_player.volume = 1.0;
                }
            }
        }
    }
}

%new
- (void)cleanupCrossfade {
    if (self.ytm_timeObserver) {
        [self.ytm_player removeTimeObserver:self.ytm_timeObserver];
        self.ytm_timeObserver = nil;
    }
    self.ytm_player = nil;
}

- (void)dealloc {
    [self cleanupCrossfade];
    %orig;
}

%end
