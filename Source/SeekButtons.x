#import "SeekButtons.h"

extern NSBundle *YTMusicUltimateBundle();

static BOOL seekTimeDef() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"] == 0);
}

static BOOL seekTime10sec() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"] == 1);
}

static BOOL seekTime20sec() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"] == 2);
}

static BOOL seekTime30sec() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"] == 3);
}

static BOOL seekTime60sec() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"] == 4);
}

%group gSeekButtons
%hook YTMNowPlayingView
- (void)layoutSubviews {
    %orig;

    UIButton *dislikeButton = [self dislikeButton];
    UIButton *likeButton = [self likeButton];

    NSSet *dislikeTargets = [dislikeButton allTargets];
    for (id dislikeTarget in dislikeTargets) {
        NSArray *actions = [dislikeButton actionsForTarget:dislikeTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapDislikeButton"]) {
                [dislikeButton removeTarget:dislikeTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [dislikeButton addTarget:dislikeTarget action:@selector(didTapSeekBackwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    NSSet *likeTargets = [likeButton allTargets];
    for (id likeTarget in likeTargets) {
        NSArray *actions = [likeButton actionsForTarget:likeTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapLikeButton"]) {
                [likeButton removeTarget:likeTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [likeButton addTarget:likeTarget action:@selector(didTapSeekForwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    //Temporary solution
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    if (seekTimeDef()) {
        [dislikeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"b10" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"f30" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
    } else if (seekTime10sec()) {
        [dislikeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"b10" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"f10" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
    } else if (seekTime20sec()) {
        [dislikeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"b20" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"f20" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
    } else if (seekTime30sec()) {
        [dislikeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"b30" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"f30" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
    } else if (seekTime60sec()) {
        [dislikeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"b60" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"f60" ofType:@"png" inDirectory:@"icons"]] forState:UIControlStateNormal];
    }
}

- (void)didTapSeekBackwardButton {
    [self didTapSeekBackwardButton];
}

- (void)didTapSeekForwardButton {
    [self didTapSeekForwardButton];
}
%end

%hook YTColdConfig
- (long long)iosPlayerClientSharedConfigTransportControlsSeekForwardTime {
    if (seekTime10sec()) {
        return 10;
    } else if (seekTime20sec()) {
        return 20;
    } else if (seekTime30sec()) {
        return 30;
    } else if (seekTime60sec()) {
        return 60;
    } return %orig;
}

- (long long)iosPlayerClientSharedConfigTransportControlsSeekBackwardTime {
    if (seekTime10sec()) {
        return 10;
    } else if (seekTime20sec()) {
        return 20;
    } else if (seekTime30sec()) {
        return 30;
    } else if (seekTime60sec()) {
        return 60;
    } return %orig;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL seekButtons = ([[NSUserDefaults standardUserDefaults] objectForKey:@"seekButtons_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"seekButtons_enabled"] : YES;

    if (isEnabled & seekButtons){
        %init(gSeekButtons);
    }
}