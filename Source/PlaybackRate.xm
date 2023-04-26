#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTMPlaybackRateButtonHolder : NSObject
@property (readonly, copy, nonatomic) UIButton *button;
@end

@interface YTMPlayerControlsView: UIView
@property (readonly, nonatomic) NSArray <YTMPlaybackRateButtonHolder *> *playbackRateButtons;
@end

%group RateController
%hook YTMModularNowPlayingViewController
- (BOOL)playbackRateButtonEnabled {
    return YES;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMPlayerControlsView
- (BOOL)playbackRateButtonEnabled {
    return YES;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    %orig(YES);
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
%end

%ctor {

    //Get / read values
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL playbackRateButton = ([[NSUserDefaults standardUserDefaults] objectForKey:@"playbackRateButton_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"playbackRateButton_enabled"] : NO;

    if (isEnabled){
        if (playbackRateButton) {
            %init(RateController);
        }
    }
}