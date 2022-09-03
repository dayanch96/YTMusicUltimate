//
//  YTMUltimatePrefs.m
//  
//
//  Created by Noah Little on 17/8/21.
//

#import "YTMUltimatePrefs.h"

@implementation YTMUltimatePrefs

-(id)init{
    self = [super init];
    if (self){
        
    } return self;
}

- (NSMutableArray *)settings {
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    NSArray *keys = @[
        @"YTMUltimateIsEnabled", 
        @"oledDarkTheme_enabled", 
        @"oledDarkKeyboard_enabled", 
        @"playbackRateButton_enabled"
    ];

    NSArray *titles = @[
        @"Enabled",
        @"OLED Dark Theme",
        @"OLED Dark Keyboard",
        @"Show playback rate button"
    ];

    NSArray *subtitles = @[
        @"Premium features, no ads, background playback, etc.",
        @"Enable OLED Dark Theme",
        @"Enable OLED Dark Keyboard",
        @"Adjust playback speed"
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
