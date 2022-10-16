#import <UIKit/UIKit.h>

@interface YTFormattedStringLabel : UILabel
@end

@interface YTMLightweightMusicDescriptionShelfCell : UIView
@property (retain, nonatomic) UITextView *lyrics;
@end

%group SelectableLyrics
%hook YTMLightweightMusicDescriptionShelfCell

%property (retain, nonatomic) UITextView *lyrics;

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
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
    YTFormattedStringLabel *lyrics = [self valueForKey:@"_descriptionLabel"];
    lyrics.userInteractionEnabled = YES;
    lyrics.hidden = YES;
    self.lyrics.font = lyrics.font;
    self.lyrics.textColor = lyrics.textColor;
    self.lyrics.attributedText = lyrics.attributedText;
}

- (void)layoutSubviews {
    %orig;
    YTFormattedStringLabel *lyrics = [self valueForKey:@"_descriptionLabel"];
    self.lyrics.frame = lyrics.frame;
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