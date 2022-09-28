//
//  YTMUltimatePrefs.m
//  
//
//  Created by Noah Little on 17/8/21.
//

#import "YTMUltimatePrefs.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

extern NSBundle *YTMusicUltimateBundle();

@implementation YTMUltimatePrefs

-(id)init{
    self = [super init];
    if (self){
        
    } return self;
}

- (NSMutableArray *)settings {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    /* To add an entry to the YTMusicUltimate settings, you need to add a key, 
    title and subtitle to the respected arrays below. */

    NSArray *keys = @[
        @"YTMUltimateIsEnabled", 
        @"oledDarkTheme_enabled", 
        @"oledDarkKeyboard_enabled", 
        @"playbackRateButton_enabled",
        @"selectableLyrics_enabled"
    ];

    NSArray *titles = @[
        LOC(@"Enabled"),
        LOC(@"OLED_Dark_Theme"),
        LOC(@"OLED_Dark_Keyboard"),
        LOC(@"Show_playback_rate_button"),
        LOC(@"Selectable_lyrics")
    ];

    NSArray *subtitles = @[
        LOC(@"Enabled_Desc"),
        LOC(@"Enable_OLED_Dark_Theme"),
        LOC(@"Enable_OLED_Dark_Keyboard"),
        LOC(@"Adjust_playback_speed"),
        LOC(@"Selectable_lyrics_Desc")
    ];

    for (int i = 0; i < keys.count; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[keys objectAtIndex:i] forKey:@"defaultsKey"];
        [dict setObject:[titles objectAtIndex:i] forKey:@"title"];
        [dict setObject:[subtitles objectAtIndex:i] forKey:@"subtitle"];

        [arr addObject:dict];
    }

    return arr;
}

@end

NSBundle *YTMusicUltimateBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:@"/Library/Application Support/YTMusicUltimate.bundle"];
    });
    return bundle;
}
