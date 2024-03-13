#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "Prefs/Localization.h"

NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
static BOOL sponsorBlock = YTMUltimateDict[@"YTMUltimateIsEnabled"] && YTMUltimateDict[@"sponsorBlock"];

@interface YTPlayerViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

- (void)seekToTime:(CGFloat)time;
- (NSString *)currentVideoID;
- (CGFloat)currentVideoMediaTime;
@end

@interface YTMToastController : NSObject
- (void)showMessage:(NSString *)message;
@end

static void skipSegment(YTPlayerViewController *self) {
    if (sponsorBlock && [NSJSONSerialization isValidJSONObject:self.sponsorBlockValues]) {
        NSDictionary *sponsorBlockValues = [self.sponsorBlockValues objectForKey:self.currentVideoID];

        for (NSDictionary *jsonDictionary in sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"]
                && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue]
                && self.currentVideoMediaTime <= ([[jsonDictionary objectForKey:@"segment"][1] floatValue] - 1)) {

                [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];

                [[%c(YTMToastController) alloc] showMessage:LOC(@"SEGMENT_SKIPPED")];
            }
        }
    }
}

%hook YTPlayerViewController
%property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;

    if (!self.sponsorBlockValues) {
        self.sponsorBlockValues = [NSMutableDictionary dictionary];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@", self.currentVideoID, @"[%22music_offtopic%22]"]]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
                [self.sponsorBlockValues setObject:jsonResponse forKey:self.currentVideoID];
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
