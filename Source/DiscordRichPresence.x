#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "Discord/YTMUDiscordDefaults.h"
#import "Discord/YTMUDiscordRPC.h"
#import "Headers/YTIThumbnailDetails_Thumbnail.h"
#import "Headers/YTPlayerViewController.h"

// YouTube Music does not hand the player and the lock screen the same picture
// of what is playing, so both are used: the player gives us the video id and
// the cover art URL, MPNowPlayingInfoCenter gives us the metadata, the play
// state and the elapsed time. The two arrive on different threads, hence the
// lock around the shared context.
static NSString *gCurrentVideoID = nil;
static NSArray<NSString *> *gCurrentArtworkCandidates = nil;
static NSString *gCurrentAuthor = nil;
// The title the player reported alongside the ids above, used to notice when
// the lock screen has moved on to a track the player hook never saw.
static NSString *gCurrentTitle = nil;
static NSString *const gVideoContextLock = @"YTMUDiscordVideoContextLock";

// Widest first, then the fixed thumbnail names YouTube publishes for every
// video. Discord fetches these itself and refuses some of them for reasons it
// does not report, so it gets a list to work down rather than a single URL.
static NSArray<NSString *> *YTMUThumbnailCandidates(YTIThumbnailDetails *thumbnail, NSString *videoID) {
    NSMutableArray<NSString *> *urls = [NSMutableArray array];

    NSMutableArray *thumbnails = [thumbnail.thumbnailsArray mutableCopy];
    [thumbnails sortUsingComparator:^NSComparisonResult(YTIThumbnailDetails_Thumbnail *a, YTIThumbnailDetails_Thumbnail *b) {
        if (a.width == b.width) return NSOrderedSame;
        return a.width > b.width ? NSOrderedAscending : NSOrderedDescending;
    }];

    for (YTIThumbnailDetails_Thumbnail *candidate in thumbnails) {
        if (![candidate respondsToSelector:@selector(URL)]) continue;

        NSString *url = candidate.URL;
        if (url.length > 0 && ![urls containsObject:url]) [urls addObject:url];
    }

    if (videoID.length > 0) {
        for (NSString *name in @[@"maxresdefault", @"sddefault", @"hqdefault"]) {
            NSString *url = [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/%@.jpg", videoID, name];
            if (![urls containsObject:url]) [urls addObject:url];
        }
    }

    return urls;
}

static void YTMUPublishNowPlayingInfo(NSDictionary *info) {
    YTMUDiscordRPC *rpc = YTMUDiscordRPC.sharedInstance;

    if (info.count == 0) {
        [rpc clearPresence];
        return;
    }

    YTMUDiscordTrack *track = [[YTMUDiscordTrack alloc] init];
    track.title = info[MPMediaItemPropertyTitle];

    // Queue advances do not always reach the player hook, which would leave
    // the previous song's cover and link attached to the new title. Trust the
    // cached ids only while they still describe what is playing.
    @synchronized (gVideoContextLock) {
        if (gCurrentTitle.length == 0 || [gCurrentTitle isEqualToString:track.title]) {
            track.videoID = gCurrentVideoID;
            track.artworkCandidates = gCurrentArtworkCandidates;
            track.artworkURL = gCurrentArtworkCandidates.firstObject;
            track.artist = gCurrentAuthor;
        }
    }

    if ([info[MPMediaItemPropertyArtist] length] > 0) track.artist = info[MPMediaItemPropertyArtist];
    track.album = info[MPMediaItemPropertyAlbumTitle];
    track.duration = [info[MPMediaItemPropertyPlaybackDuration] doubleValue];
    track.elapsed = [info[MPNowPlayingInfoPropertyElapsedPlaybackTime] doubleValue];

    // No rate at all means the app never told us it paused, so assume playing.
    id rate = info[MPNowPlayingInfoPropertyPlaybackRate];
    track.playing = rate == nil || [rate doubleValue] > 0.0;

    [rpc updateWithTrack:track];
}

%group DiscordRichPresence

%hook YTPlayerViewController

- (void)playbackController:(id)controller didActivateVideo:(id)video withPlaybackData:(id)playbackData {
    %orig;

    if (!YTMUDiscordIsEnabled()) return;

    YTIVideoDetails *details = self.playerResponse.playerData.videoDetails;

    @synchronized (gVideoContextLock) {
        gCurrentVideoID = [self.currentVideoID copy];
        gCurrentAuthor = [details.author copy];
        gCurrentTitle = [details.title copy];
        gCurrentArtworkCandidates = YTMUThumbnailCandidates(details.thumbnail, self.currentVideoID);
    }

    // The lock screen info usually lands a beat later; publish what we already
    // know so the presence does not lag behind the first few seconds.
    YTMUDiscordTrack *track = [[YTMUDiscordTrack alloc] init];
    track.videoID = self.currentVideoID;
    track.title = details.title;
    track.artist = details.author;
    track.artworkCandidates = YTMUThumbnailCandidates(details.thumbnail, self.currentVideoID);
    track.artworkURL = track.artworkCandidates.firstObject;
    track.duration = self.currentVideoTotalMediaTime;
    track.elapsed = self.currentVideoMediaTime;
    track.playing = YES;

    [YTMUDiscordRPC.sharedInstance updateWithTrack:track];
}

%end

%hook MPNowPlayingInfoCenter

- (void)setNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    %orig;

    if (!YTMUDiscordIsEnabled()) return;

    YTMUPublishNowPlayingInfo(nowPlayingInfo);
}

%end

%end

%ctor {
    YTMUDiscordRegisterDefaults();

    %init(DiscordRichPresence);

    // Becoming active also covers coming back from a spell in the background
    // long enough for the socket to have been torn down for good.
    for (NSNotificationName name in @[UIApplicationDidFinishLaunchingNotification, UIApplicationDidBecomeActiveNotification]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
            [YTMUDiscordRPC.sharedInstance synchronizeConnection];
        }];
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
        [YTMUDiscordRPC.sharedInstance clearPresence];
    }];
}
