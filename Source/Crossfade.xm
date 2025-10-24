#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "Headers/YTPlayerViewController.h"
// #import "Source/Headers/YTQueueController.h" // This was the cause of the build error. The header does not exist.
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

// --- Local Interface Declaration ---
// This is the correct way to use a private class that does not have a public header file.
@interface YTQueueController : NSObject
- (void)playNext;
@end


// --- Globals & Helpers ---

static AVPlayer *crossfade_takeoverPlayer = nil;

static id YTMUValue(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"][key];
}

static BOOL crossfadeEnabled() {
    return [YTMUValue(@"YTMUltimateIsEnabled") boolValue] && [YTMUValue(@"crossfade") boolValue];
}

static int crossfadeDuration() {
    NSNumber *duration = YTMUValue(@"crossfadeDuration");
    if (duration && [duration intValue] > 0) {
        return [duration intValue];
    }
    return 5; // Default to 5s
}

// --- Category for Associated Objects ---

@interface YTPlayerViewController (YTMUltimate)
@property (nonatomic, strong, setter=ytm_setPlayer:, getter=ytm_player) AVPlayer *ytm_player;
@property (nonatomic, strong, setter=ytm_setTimeObserver:, getter=ytm_timeObserver) id ytm_timeObserver;
@property (nonatomic, strong, setter=ytm_setQueueController:, getter=ytm_queueController) YTQueueController *ytm_queueController;
@end

@implementation YTPlayerViewController (YTMUltimate)
- (void)ytm_setPlayer:(AVPlayer *)player { objc_setAssociatedObject(self, @selector(ytm_player), player, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
- (AVPlayer *)ytm_player { return objc_getAssociatedObject(self, @selector(ytm_player)); }
- (void)ytm_setTimeObserver:(id)observer { objc_setAssociatedObject(self, @selector(ytm_timeObserver), observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
- (id)ytm_timeObserver { return objc_getAssociatedObject(self, @selector(ytm_timeObserver)); }
- (void)ytm_setQueueController:(YTQueueController *)controller { objc_setAssociatedObject(self, @selector(ytm_queueController), controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
- (YTQueueController *)ytm_queueController { return objc_getAssociatedObject(self, @selector(ytm_queueController)); }
@end

// --- Core Logic ---

static void cleanupObserver(YTPlayerViewController *self) {
    if (self.ytm_timeObserver) {
        AVPlayer *observedPlayer = self.ytm_player;
        if (observedPlayer) {
            @try {
                [observedPlayer removeTimeObserver:self.ytm_timeObserver];
            } @catch (NSException *exception) {
                // Player might be deallocated, which is safe to ignore.
            }
        }
        self.ytm_timeObserver = nil;
    }
    self.ytm_player = nil;
}

// --- Logos Hooks ---

%hook YTPlayerViewController

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    cleanupObserver(self);
    %orig;

    if (crossfadeEnabled()) {
        unsigned int ivarCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            const char *ivarName = ivar_getName(ivar);
            id ivarValue = object_getIvar(self, ivars[i]);
            if ([ivarValue isKindOfClass:[AVPlayer class]]) {
                self.ytm_player = ivarValue;
            } else if ([ivarValue isKindOfClass:[YTQueueController class]]) {
                self.ytm_queueController = ivarValue;
            }
        }
        free(ivars);

        if (self.ytm_player) {
            self.ytm_player.volume = 0.0;

            __weak YTPlayerViewController *weakSelf = self;
            self.ytm_timeObserver = [self.ytm_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                YTPlayerViewController *strongSelf = weakSelf;
                if (!strongSelf || !strongSelf.ytm_player) return;

                CGFloat currentTime = strongSelf.currentVideoMediaTime;
                CGFloat totalTime = strongSelf.currentVideoTotalMediaTime;
                int duration = crossfadeDuration();

                if (totalTime > duration && (totalTime - currentTime) < duration) {
                    cleanupObserver(strongSelf);

                    crossfade_takeoverPlayer = [[AVPlayer alloc] initWithPlayerItem:strongSelf.ytm_player.currentItem];
                    [crossfade_takeoverPlayer seekToTime:strongSelf.ytm_player.currentTime];
                    crossfade_takeoverPlayer.volume = strongSelf.ytm_player.volume;
                    [crossfade_takeoverPlayer play];

                    if (strongSelf.ytm_queueController) {
                        [strongSelf.ytm_queueController playNext];
                    }

                    __block float fadeOutVolume = crossfade_takeoverPlayer.volume;
                    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        fadeOutVolume -= (0.1 / duration);
                        if (fadeOutVolume <= 0 || !crossfade_takeoverPlayer) {
                            [crossfade_takeoverPlayer pause];
                            crossfade_takeoverPlayer = nil;
                            [timer invalidate];
                        } else {
                            crossfade_takeoverPlayer.volume = fadeOutVolume;
                        }
                    }];
                }
                else if (currentTime < duration) {
                    strongSelf.ytm_player.volume = currentTime / duration;
                }
                else {
                    if (strongSelf.ytm_player.volume < 1.0) {
                        strongSelf.ytm_player.volume = 1.0;
                    }
                }
            }];
        }
    }
}

- (void)dealloc {
    cleanupObserver(self);
    %orig;
}

%end
