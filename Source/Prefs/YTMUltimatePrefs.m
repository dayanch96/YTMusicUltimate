//
//  YTMUltimatePrefs.m
//  
//
//  Created by Noah Little on 17/8/21.
//

#import <rootless.h>
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
        @"selectableLyrics_enabled",
        @"lowContrast_enabled",
        @"volBar_enabled",
        @"disableAutoRadio_enabled",
        @"hideHistoryButton_enabled",
        @"hideCastButton_enabled"
    ];

    NSArray *titles = @[
        LOC(@"ENABLED"),
        LOC(@"OLED_DARK_THEME"),
        LOC(@"OLED_DARK_KEYBOARD"),
        LOC(@"PLAYBACK_RATE_BUTTON"),
        LOC(@"SELECTABLE_LYRICS"),
        LOC(@"LOW_CONTRAST"),
        LOC(@"VOLBAR"),
        LOC(@"NO_AUTORADIO"),
        LOC(@"HIDE_HISTORY_BUTTON"),
        LOC(@"HIDE_CAST_BUTTON")
    ];

    NSArray *subtitles = @[
        LOC(@"ENABLED_DESC"),
        LOC(@"OLED_DARK_THEME_DESC"),
        LOC(@"OLED_DARK_KEYBOARD_DESC"),
        LOC(@"PLAYBACK_RATE_BUTTON_DESC"),
        LOC(@"SELECTABLE_LYRICS_DESC"),
        LOC(@"LOW_CONTRAST_DESC"),
        LOC(@"VOLBAR_DESC"),
        LOC(@"NO_AUTORADIO_DESC"),
        LOC(@"HIDE_HISTORY_BUTTON_DESC"),
        LOC(@"HIDE_CAST_BUTTON_DESC")
    ];

    for (int i = 0; i < keys.count; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[keys objectAtIndex:i] forKey:@"defaultsKey"];
        [dict setObject:[titles objectAtIndex:i] forKey:@"title"];
        [dict setObject:[subtitles objectAtIndex:i] forKey:@"subtitle"];

        [arr addObject:dict];
    }

    //Init isEnabled for first time
    if ([[NSUserDefaults standardUserDefaults] objectForKey:keys[0]] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keys[0]];
    }

    return arr;
}

- (NSMutableArray *)links {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    /* To add an entry to the YTMusicUltimate settings, you need to add a key, 
    title and subtitle to the respected arrays below. */

    NSArray *urls = @[
        @"https://twitter.com/ginsudev", 
        @"https://discord.com/invite/BhdUyCbgkZ", 
        @"https://github.com/ginsudev/YTMusicUltimate"
    ];

    NSArray *titles = @[
        LOC(@"TWITTER"),
        LOC(@"DISCORD"),
        LOC(@"SOURCE_CODE"),
    ];

    NSArray *subtitles = @[
        LOC(@"TWITTER_DESC"),
        LOC(@"DISCORD_DESC"),
        LOC(@"SOURCE_CODE_DESC"),
    ];

    for (int i = 0; i < urls.count; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[urls objectAtIndex:i] forKey:@"url"];
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
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle")];
    });
    return bundle;
}
