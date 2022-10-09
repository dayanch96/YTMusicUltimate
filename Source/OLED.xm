#import <Foundation/Foundation.h>
#include "Imports.h"

%group oledTheme
%hook YTCommonColorPalette
- (UIColor *)brandBackgroundSolid { return [UIColor blackColor]; }
- (UIColor *)brandBackgroundPrimary { return [UIColor blackColor]; }
%end

%hook YTPivotBarView
- (void)didMoveToWindow {
    self.subviews[0].backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook YTMMusicMenuTitleView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook MDCSnackbarMessageView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook YTMPlayerPageColorScheme
- (void)setMiniPlayerColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}

- (void)setQueueBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}

- (void)setQueueCurrentlyPlayingBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}

- (void)setTabViewColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}

- (void)setAVSwitchBackgroundColor:(UIColor *)color {
    %orig(color);
    [self setPlayButtonColor:color];
}

- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end

%hook YTLightweightBrowseBackgroundView
- (id)imageView {
    return nil;
}
%end
%end

#pragma mark - OLED Keyboard
%group oledKB
%hook UIPredictionViewController // support prediction bar - @ichitaso: http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController // support prediction bar - @ichitaso:http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end
%end

%ctor {

    //Get / read values
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL oledDarkTheme = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkTheme_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkTheme_enabled"] : NO;
    BOOL oledDarkKeyboard = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkKeyboard_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkKeyboard_enabled"] : NO;    
    
    if (isEnabled){

        if (oledDarkTheme) {
            %init(oledTheme);
        }

        if (oledDarkKeyboard) {
            %init(oledKB);
        }
    }
}