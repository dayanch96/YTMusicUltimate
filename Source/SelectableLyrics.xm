#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL shouldShowSelectableLyrics() {
    return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"selectableLyrics");
}

@interface YTFormattedStringLabel : UILabel
@end

@interface YTMLightweightMusicDescriptionShelfCell : UIView
@property (retain, nonatomic) UITextView *lyrics;
@end

%hook YTMLightweightMusicDescriptionShelfCell

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self && shouldShowSelectableLyrics()) {
        UIView *container = [self valueForKey:@"_descriptionContainer"];
        self.lyrics = [[UITextView alloc] init];
        self.lyrics.backgroundColor = [UIColor clearColor];
        self.lyrics.editable = NO;
        self.lyrics.scrollEnabled = NO;
        self.lyrics.showsVerticalScrollIndicator = NO;
        [container addSubview:self.lyrics];
    }
    return self;
}

- (void)setRenderer:(id)renderer {
    %orig;

    if (shouldShowSelectableLyrics()) {
        YTFormattedStringLabel *lyrics = [self valueForKey:@"_descriptionLabel"];
        lyrics.userInteractionEnabled = YES;
        lyrics.hidden = YES;
        self.lyrics.font = lyrics.font;
        self.lyrics.textColor = lyrics.textColor;
        self.lyrics.attributedText = lyrics.attributedText;
    }
}

- (void)layoutSubviews {
    %orig;

    if (shouldShowSelectableLyrics()) {
        YTFormattedStringLabel *lyrics = [self valueForKey:@"_descriptionLabel"];
        self.lyrics.frame = lyrics.frame;
    }
}

%end
