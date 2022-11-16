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
        @"selectableLyrics_enabled",
        @"Low_contrast_enabled",
        @"VolBar_Enabled"
    ];

    NSArray *titles = @[
        LOC(@"Enabled"),
        LOC(@"OLED_Dark_Theme"),
        LOC(@"OLED_Dark_Keyboard"),
        LOC(@"Show_playback_rate_button"),
        LOC(@"Selectable_lyrics"),
        LOC(@"Low_contrast"),
        LOC(@"VolBar")
    ];

    NSArray *subtitles = @[
        LOC(@"Enabled_Desc"),
        LOC(@"Enable_OLED_Dark_Theme"),
        LOC(@"Enable_OLED_Dark_Keyboard"),
        LOC(@"Adjust_playback_speed"),
        LOC(@"Selectable_lyrics_Desc"),
        LOC(@"Low_contrast_Desc"),
        LOC(@"VolBar_Desc")
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
        LOC(@"Follow_me_on_Twitter"),
        LOC(@"Discord"),
        LOC(@"Source_code"),
    ];

    NSArray *subtitles = @[
        LOC(@"Follow_me_for_updates"),
        LOC(@"Discord_desc"),
        LOC(@"View_source_code"),
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
            bundle = [NSBundle bundleWithPath:@"/Library/Application Support/YTMusicUltimate.bundle"];
    });
    return bundle;
}
