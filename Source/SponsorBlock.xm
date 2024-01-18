#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL sponsorBlock = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"sponsorBlock");

@protocol YTPlaybackController
@end

@interface YTPlayerViewController : UIViewController <YTPlaybackController>
- (void)seekToTime:(CGFloat)time;
- (NSString *)currentVideoID;
- (CGFloat)currentVideoMediaTime;
@end

@interface YTSingleVideoTime : NSObject
@end

BOOL isSponsorBlockEnabled;
NSDictionary *sponsorBlockValues = [[NSDictionary alloc] init];

%hook YTPlayerViewController
- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    isSponsorBlockEnabled = NO;
    %orig();
    NSString *options = @"[%22music_offtopic%22]";
    NSURLRequest *request;
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@", self.currentVideoID, options]]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
                sponsorBlockValues = jsonResponse;
                isSponsorBlockEnabled = YES;
            } else {
                isSponsorBlockEnabled = NO;
            }
        } else if (error) {
            isSponsorBlockEnabled = NO;
        }
    }] resume];
}
- (void)singleVideo:(id)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig();
    if (sponsorBlock && isSponsorBlockEnabled && [NSJSONSerialization isValidJSONObject:sponsorBlockValues]) {
        for (NSMutableDictionary *jsonDictionary in sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= ([[jsonDictionary objectForKey:@"segment"][1] floatValue] - 1)) {
                [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
            }
        }
    }
}
%end
