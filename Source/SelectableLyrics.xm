#import <Foundation/Foundation.h>
#include "Imports.h"

%group SelectableLyrics
%hook YTFormattedStringLabel
%property (nonatomic, strong) UITextView *lyricsTextView;

%new
- (BOOL)isLyricsView
{
    if ([[[self superview] superview] superview] == nil) {
        return false;
    }

    if ([self.superview.superview.superview isKindOfClass:objc_getClass("YTMLightweightMusicDescriptionShelfCell")]) {
        YTFormattedStringLabel *label = MSHookIvar<YTFormattedStringLabel *>([[[self superview] superview] superview], "_descriptionLabel");
        return [self isEqual:label];
    }

    return false;
}

- (void)layoutSubviews
{
    %orig;
    if (![self isLyricsView]) { return; }

    if (self.lyricsTextView != nil) {
        self.lyricsTextView.frame = self.bounds;
    }
}

- (void)setFont:(UIFont *)font
{
    %orig(font);
    if (![self isLyricsView]) { return; }

    [self.lyricsTextView setFont:[UIFont systemFontOfSize:14]];
}

- (void)setAttributedText:(NSAttributedString *)text
{
    %orig(text);
    if (![self isLyricsView]) { return; }

    [self setTextColor:[UIColor clearColor]];
    [self.lyricsTextView setAttributedText:text];
}

- (void)didAddSubview:(UIView *)view {
    %orig;
    if (![self isLyricsView]) { return; }

    if ([view isKindOfClass:objc_getClass("MDCInkView")]) {
        self.lyricsTextView = [[UITextView alloc] init];
        [self.lyricsTextView setBackgroundColor:[UIColor clearColor]];
        [self.lyricsTextView setTextColor:[UIColor whiteColor]];
        [self.lyricsTextView setEditable:NO];
        
        [self addSubview:self.lyricsTextView];
        self.userInteractionEnabled = YES;
        [view removeFromSuperview];
    }
}
%end
%end

%ctor{

    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL selectableLyrics = ([[NSUserDefaults standardUserDefaults] objectForKey:@"selectableLyrics_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"selectableLyrics_enabled"] : NO;
    
    if (isEnabled){
        if (selectableLyrics) {
            %init(SelectableLyrics);
        }
    }
}