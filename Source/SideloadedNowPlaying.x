#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

#import "Headers/YTIThumbnailDetails.h"
#import "Headers/YTIThumbnailDetails_Thumbnail.h"
#import "Headers/YTIVideoDetails.h"
#import "Headers/YTPlayerResponse.h"
#import "Headers/YTPlayerViewController.h"

// A normally-sideloaded build cannot claim Apple's managed CarPlay entitlement,
// so it is not eligible for a dedicated icon or browsing UI. Keep the system
// Now Playing fallback useful by publishing metadata from YTM's active player.

static NSString *YTMUCurrentNowPlayingVideoID;
static NSTimeInterval YTMULastElapsedTimeUpdate;
static NSCache<NSString *, MPMediaItemArtwork *> *YTMUArtworkCache;

static BOOL YTMUIsEnabled(void) {
    NSDictionary *preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [preferences[@"YTMUltimateIsEnabled"] boolValue];
}

static void YTMUSetNowPlayingArtwork(MPMediaItemArtwork *artwork, NSString *videoID) {
    if (!artwork || ![YTMUCurrentNowPlayingVideoID isEqualToString:videoID]) return;

    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *nowPlayingInfo = [center.nowPlayingInfo mutableCopy] ?: [NSMutableDictionary dictionary];
    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork;
    center.nowPlayingInfo = nowPlayingInfo;
}

static void YTMULoadNowPlayingArtwork(YTIThumbnailDetails *thumbnailDetails, NSString *videoID) {
    if (videoID.length == 0) return;

    MPMediaItemArtwork *cachedArtwork = [YTMUArtworkCache objectForKey:videoID];
    if (cachedArtwork) {
        YTMUSetNowPlayingArtwork(cachedArtwork, videoID);
        return;
    }

    YTIThumbnailDetails_Thumbnail *thumbnail = [thumbnailDetails.thumbnailsArray lastObject];
    NSURL *thumbnailURL = [NSURL URLWithString:thumbnail.URL];
    if (!thumbnailURL) return;

    [[[NSURLSession sharedSession] dataTaskWithURL:thumbnailURL
                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data.length == 0) return;

        UIImage *image = [UIImage imageWithData:data];
        if (!image) return;

        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc]
            initWithBoundsSize:image.size
                requestHandler:^UIImage *(CGSize requestedSize) {
                    return image;
                }];
        [YTMUArtworkCache setObject:artwork forKey:videoID];

        dispatch_async(dispatch_get_main_queue(), ^{
            YTMUSetNowPlayingArtwork(artwork, videoID);
        });
    }] resume];
}

static void YTMUUpdateNowPlayingInfo(YTPlayerViewController *playerViewController, BOOL trackChanged) {
    if (!YTMUIsEnabled()) return;

    void (^updateBlock)(void) = ^{
        YTIPlayerResponse *playerData = playerViewController.playerResponse.playerData;
        YTIVideoDetails *videoDetails = playerData.videoDetails;
        if (!videoDetails) return;

        NSString *videoID = [playerViewController.currentVideoID copy];
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary *nowPlayingInfo = [center.nowPlayingInfo mutableCopy] ?: [NSMutableDictionary dictionary];

        if (videoDetails.title.length > 0) {
            nowPlayingInfo[MPMediaItemPropertyTitle] = videoDetails.title;
        }
        if (videoDetails.author.length > 0) {
            nowPlayingInfo[MPMediaItemPropertyArtist] = videoDetails.author;
        }

        NSTimeInterval duration = playerViewController.currentVideoTotalMediaTime;
        NSTimeInterval elapsedTime = playerViewController.currentVideoMediaTime;
        if (duration > 0) {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(duration);
        }
        if (elapsedTime >= 0) {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(elapsedTime);
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = @(MPNowPlayingInfoMediaTypeAudio);
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = @NO;
        if (videoID.length > 0) {
            nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = videoID;
        }

        if (trackChanged) {
            YTMUCurrentNowPlayingVideoID = videoID;
            [nowPlayingInfo removeObjectForKey:MPMediaItemPropertyArtwork];
        }

        center.nowPlayingInfo = nowPlayingInfo;

        if (trackChanged && videoID.length > 0) {
            YTMULoadNowPlayingArtwork(videoDetails.thumbnail, videoID);
        }
    };

    if ([NSThread isMainThread]) {
        updateBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), updateBlock);
    }
}

%hook YTPlayerViewController

- (void)playbackController:(id)controller didActivateVideo:(id)video withPlaybackData:(id)playbackData {
    %orig;
    YTMUUpdateNowPlayingInfo(self, YES);
}

- (void)singleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - YTMULastElapsedTimeUpdate >= 1.0) {
        YTMULastElapsedTimeUpdate = now;
        YTMUUpdateNowPlayingInfo(self, NO);
    }
}

- (void)potentiallyMutatedSingleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - YTMULastElapsedTimeUpdate >= 1.0) {
        YTMULastElapsedTimeUpdate = now;
        YTMUUpdateNowPlayingInfo(self, NO);
    }
}

%end

%ctor {
    YTMUArtworkCache = [[NSCache alloc] init];
    YTMUArtworkCache.countLimit = 20;
}
