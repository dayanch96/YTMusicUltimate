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
        @"YTMUltimateIsEnabled"
    ];

    NSArray *titles = @[
        LOC(@"ENABLED")
    ];

    NSArray *subtitles = @[
        LOC(@"ENABLED_DESC")
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
        @"https://twitter.com/dayanch96",
        @"https://discord.com/invite/BhdUyCbgkZ", 
        @"https://github.com/ginsudev/YTMusicUltimate"
    ];
    NSArray *titles = @[
        [NSString stringWithFormat:LOC(@"TWITTER"), @"Ginsu"],
        [NSString stringWithFormat:LOC(@"TWITTER"), @"Dayanch96"],
        LOC(@"DISCORD"),
        LOC(@"SOURCE_CODE"),
    ];

    NSArray *subtitles = @[
        LOC(@"TWITTER_DESC"),
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
