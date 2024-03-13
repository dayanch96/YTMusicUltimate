#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL sponsorBlock = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"sponsorBlock");

@interface YTPlayerViewController : UIViewController
@property (nonatomic, strong) NSDictionary *sponsorBlockValues;

- (void)seekToTime:(CGFloat)time;
- (NSString *)currentVideoID;
- (CGFloat)currentVideoMediaTime;
@end

static void skipSegment(YTPlayerViewController *self) {
    if (sponsorBlock && [NSJSONSerialization isValidJSONObject:self.sponsorBlockValues]) {
        for (NSMutableDictionary *jsonDictionary in self.sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"]
                && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue]
                && self.currentVideoMediaTime <= ([[jsonDictionary objectForKey:@"segment"][1] floatValue] - 1)) {

                [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
            }
        }
    }
}

%hook YTPlayerViewController
%property (nonatomic, strong) NSDictionary *sponsorBlockValues;

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@", self.currentVideoID, @"[%22music_offtopic%22]"]]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
                self.sponsorBlockValues = jsonResponse;
            }
        }
    }] resume];
}

- (void)singleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;

    skipSegment(self);
}

- (void)potentiallyMutatedSingleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;

    skipSegment(self);
}
%end
