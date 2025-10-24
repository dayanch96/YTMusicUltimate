#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "Source/Headers/YTPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

// Helper to safely read from NSUserDefaults
static id YTMUValue(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"][key];
}

static BOOL crossfadeEnabled() {
    return [YTMUValue(@"YTMUltimateIsEnabled") boolValue] && [YTMUValue(@"crossfade") boolValue];
}

static int crossfadeDuration() {
    NSNumber *duration = YTMUValue(@"crossfadeDuration");
    return duration ? [duration intValue] : 5; // Default to 5 seconds if not set
}

#pragma mark - YTPlayerViewController Category

@interface YTPlayerViewController (YTMUltimate)
@property (nonatomic, strong) AVPlayer *ytm_player;
@property (nonatomic, strong) id ytm_timeObserver;
- (void)checkForCrossfade;
- (void)cleanupCrossfadeObserver;
@end

#pragma mark - Logos Hooks

%hook YTPlayerViewController

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    // It is critical to clean up the observer from the *previous* song before the original method runs.
    [self cleanupCrossfadeObserver];
    %orig;

    if (crossfadeEnabled()) {
        // Find the AVPlayer instance for the newly activated video.
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
    if (!crossfadeEnabled() || !self.ytm_player) return;

    CGFloat currentTime = self.currentVideoMediaTime;
    CGFloat totalTime = self.currentVideoTotalMediaTime;
    int duration = crossfadeDuration();

    if (CMTIME_IS_VALID(self.ytm_player.currentTime) && totalTime > duration && duration > 0) {
        // Fade out in the last X seconds
        if (totalTime - currentTime < duration) {
            float newVolume = (totalTime - currentTime) / duration;
            if (self.ytm_player.volume != newVolume) self.ytm_player.volume = newVolume;
        }
        // Fade in in the first X seconds
        else if (currentTime < duration) {
            float newVolume = currentTime / duration;
            if (self.ytm_player.volume != newVolume) self.ytm_player.volume = newVolume;
        }
        // Otherwise, ensure volume is at max
        else {
            if (self.ytm_player.volume < 1.0) {
                self.ytm_player.volume = 1.0;
            }
        }
    }
}

// This logic is now more robust to prevent crashes.
// It ensures that we don't try to remove an observer from a deallocated player.
%new
- (void)cleanupCrossfadeObserver {
    if (self.ytm_timeObserver) {
        // The original player instance might be gone, so we find it again just to be safe.
        AVPlayer *player_instance = self.ytm_player;
        if (player_instance) {
             @try {
                [player_instance removeTimeObserver:self.ytm_timeObserver];
             } @catch (NSException *e) {
                // Player was likely deallocated. Safe to ignore.
             }
        }
        self.ytm_timeObserver = nil;
    }
    self.ytm_player = nil;
}

- (void)dealloc {
    [self cleanupCrossfadeObserver];
    %orig;
}

%end
