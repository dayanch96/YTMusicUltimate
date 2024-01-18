#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL playbackRateButton = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"playbackRateButton");

@interface YTMPlaybackRateButtonHolder : NSObject
@property (readonly, copy, nonatomic) UIButton *button;
@end

@interface YTMPlayerControlsView: UIView
@property (readonly, nonatomic) NSArray <YTMPlaybackRateButtonHolder *> *playbackRateButtons;
@end

%hook YTMModularNowPlayingViewController
- (BOOL)playbackRateButtonEnabled {
    return playbackRateButton ? YES : %orig;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    playbackRateButton ? %orig(YES) : %orig;
}
%end

%hook YTMPlayerControlsView
- (BOOL)playbackRateButtonEnabled {
    return playbackRateButton ? YES : %orig;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    playbackRateButton ? %orig(YES) : %orig;
}

// Thanks to @danpashin for help
- (void)setupPlaybackRateButtons {
	%orig;

	NSMutableArray *buttonsConstraints = [NSMutableArray arrayWithCapacity:self.playbackRateButtons.count * 2];

	for (YTMPlaybackRateButtonHolder *holder in self.playbackRateButtons) {
		holder.button.translatesAutoresizingMaskIntoConstraints = NO;
		[buttonsConstraints addObject:[holder.button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
		[buttonsConstraints addObject:[holder.button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
	}

	[NSLayoutConstraint activateConstraints:buttonsConstraints];
}
%end
