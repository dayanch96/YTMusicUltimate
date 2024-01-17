#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL selectableLyrics = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"selectableLyrics");

@interface YTFormattedStringLabel : UILabel
@end

@interface YTMLightweightMusicDescriptionShelfCell : UIView
@property (retain, nonatomic) UITextView *lyrics;
@end

%hook YTMLightweightMusicDescriptionShelfCell

%property (retain, nonatomic) UITextView *lyrics;

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self && selectableLyrics) {
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

    if (selectableLyrics) {
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

    if (selectableLyrics) {
        YTFormattedStringLabel *lyrics = [self valueForKey:@"_descriptionLabel"];
        self.lyrics.frame = lyrics.frame;
    }
}

%end
