#import "Headers/YTMNowPlayingViewController.h"
#import "Headers/YTMNowPlayingView.h"
#import "Headers/YTAssetLoader.h"
#import "Headers/Localization.h"

static NSInteger seekTime() {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];

    if (YTMUltimateDict && YTMUltimateDict[@"seekTime"]) {
        NSInteger index = [YTMUltimateDict[@"seekTime"] integerValue];
        NSArray *seekTimes = @[@0, @10, @20, @30, @60];

        return [seekTimes[index] integerValue];
    }

    return 0;
}

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

%hook YTMNowPlayingViewController
- (void)viewDidLoad {
    %orig;

    if (!YTMU(@"YTMUltimateIsEnabled") || !YTMU(@"seekButtons")) {
        return;
    }

    YTMNowPlayingView *nowPlayingView = [self valueForKey:@"_nowPlayingView"];

    if (nowPlayingView) {
        YTMPlayerControlsView *controlsView = nowPlayingView.playerControlsView;

        [controlsView.prevButton removeTarget:self action:@selector(didTapPrevButton) forControlEvents:UIControlEventTouchUpInside];
        [controlsView.nextButton removeTarget:self action:@selector(didTapNextButton) forControlEvents:UIControlEventTouchUpInside];

        [controlsView.prevButton addTarget:self action:@selector(didTapSeekBackwardButton) forControlEvents:UIControlEventTouchUpInside];
        [controlsView.nextButton addTarget:self action:@selector(didTapSeekForwardButton) forControlEvents:UIControlEventTouchUpInside];

        UILongPressGestureRecognizer *longPressPrev = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPrev:)];
        [longPressPrev setMinimumPressDuration:0.5];
        [controlsView.prevButton addGestureRecognizer:longPressPrev];

        UILongPressGestureRecognizer *longPressNext = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressNext:)];
        [longPressNext setMinimumPressDuration:0.5];
        [controlsView.nextButton addGestureRecognizer:longPressNext];

        NSInteger backValue = seekTime() == 0 ? 10 : seekTime();
        NSInteger forwardValue = seekTime() == 0 ? 30 : seekTime();

        YTAssetLoader *al = [[%c(YTAssetLoader) alloc] initWithBundle:[NSBundle mainBundle]];

        UIImage *backImage = [al imageNamed:[NSString stringWithFormat:@"ic_seek_back_%ld_40", backValue]];
        UIImage *forwardImage = [al imageNamed:[NSString stringWithFormat:@"ic_seek_forward_%ld_40", forwardValue]];

        [controlsView.prevButton setImage:backImage forState:UIControlStateNormal];
        [controlsView.prevButton setImage:backImage forState:UIControlStateSelected];
        [controlsView.nextButton setImage:forwardImage forState:UIControlStateNormal];
        [controlsView.nextButton setImage:forwardImage forState:UIControlStateSelected];
    }
}

// - (void)didTapPrevButton {
//     YTMU(@"YTMUltimateIsEnabled") && YTMU(@"seekButtons") ? [self didTapSeekBackwardButton] : %orig;
// }

// - (void)didTapNextButton {
//     YTMU(@"YTMUltimateIsEnabled") && YTMU(@"seekButtons") ? [self didTapSeekForwardButton] : %orig;
// }

%new
- (void)longPressPrev:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self didTapPrevButton];
    }
}

%new
- (void)longPressNext:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self didTapNextButton];
    }
}
%end

%hook YTColdConfig
- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekForwardTime {
    return (seekTime() == 0) ? %orig : seekTime();
}

- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekBackwardTime {
    return (seekTime() == 0) ? %orig : seekTime();
}
%end
