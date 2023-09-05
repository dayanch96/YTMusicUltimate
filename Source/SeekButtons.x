#import "SeekButtons.h"

static NSInteger currentSeekTime() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"];
}

%group gSeekButtons
%hook YTMPlayerControlsView
- (void)layoutSubviews {
    %orig;

    UIButton *prevButton = [self prevButton];
    UIButton *nextButton = [self nextButton];

    NSSet *prevTargets = [prevButton allTargets];
    for (id prevTarget in prevTargets) {
        NSArray *actions = [prevButton actionsForTarget:prevTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapPrevButton"]) {
                [prevButton removeTarget:prevTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [prevButton addTarget:prevTarget action:@selector(didTapSeekBackwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    NSSet *nextTargets = [nextButton allTargets];
    for (id nextTarget in nextTargets) {
        NSArray *actions = [nextButton actionsForTarget:nextTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapNextButton"]) {
                [nextButton removeTarget:nextTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [nextButton addTarget:nextTarget action:@selector(didTapSeekForwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    NSString *backValue = @"10";
    NSString *forwardValue = @"30";

    if (currentSeekTime() == 1) {
        backValue = @"10";
        forwardValue = @"10";
    } else if (currentSeekTime() == 2) {
        backValue = @"20";
        forwardValue = @"20";
    } else if (currentSeekTime() == 3) {
        backValue = @"30";
        forwardValue = @"30";
    } else if (currentSeekTime() == 4) {
        backValue = @"60";
        forwardValue = @"60";
    }

    NSString *appBundle = [[NSBundle mainBundle] bundlePath];
    UIImage *backImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_seek_back_%@_40", backValue] inBundle:[NSBundle bundleWithPath:appBundle] compatibleWithTraitCollection:nil];
    UIImage *forwardImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_seek_forward_%@_40", forwardValue] inBundle:[NSBundle bundleWithPath:appBundle] compatibleWithTraitCollection:nil];

    [prevButton setImage:backImage forState:UIControlStateNormal];
    [prevButton setImage:backImage forState:UIControlStateSelected];
    [nextButton setImage:forwardImage forState:UIControlStateNormal];
    [nextButton setImage:forwardImage forState:UIControlStateSelected];
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
    if (currentSeekTime() == 1) {
        return 10;
    } else if (currentSeekTime() == 2) {
        return 20;
    } else if (currentSeekTime() == 3) {
        return 30;
    } else if (currentSeekTime() == 4) {
        return 60;
    } return %orig;
}

- (long long)iosPlayerClientSharedConfigTransportControlsSeekBackwardTime {
    if (currentSeekTime() == 1) {
        return 10;
    } else if (currentSeekTime() == 2) {
        return 20;
    } else if (currentSeekTime() == 3) {
        return 30;
    } else if (currentSeekTime() == 4) {
        return 60;
    } return %orig;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL seekButtons = [[NSUserDefaults standardUserDefaults] boolForKey:@"seekButtons_enabled"];

    if (isEnabled && seekButtons){
        %init(gSeekButtons);
    }
}
