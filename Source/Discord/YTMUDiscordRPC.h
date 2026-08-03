#import <UIKit/UIKit.h>
#import "YTMUDiscordDefaults.h"

NS_ASSUME_NONNULL_BEGIN

// Everything the presence needs to know about what is on screen right now.
@interface YTMUDiscordTrack : NSObject <NSCopying>

@property (nonatomic, copy, nullable) NSString *videoID;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *artist;
@property (nonatomic, copy, nullable) NSString *album;
@property (nonatomic, copy, nullable) NSString *artworkURL;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval elapsed;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

// A track is only worth publishing once it has a title.
@property (nonatomic, readonly, getter=isUsable) BOOL usable;

@end

@interface YTMUDiscordRPC : NSObject

@property (class, nonatomic, readonly) YTMUDiscordRPC *sharedInstance;

@property (nonatomic, readonly) YTMUDiscordConnectionState connectionState;
@property (nonatomic, readonly, copy, nullable) NSString *username;
@property (nonatomic, readonly, copy, nullable) NSString *lastErrorMessage;
@property (nonatomic, readonly) BOOL hasStoredCredentials;

// Connects using the stored token when rich presence is switched on, and tears
// the connection down when it is switched off. Safe to call repeatedly.
- (void)synchronizeConnection;

// Runs the OAuth flow, stores the tokens and connects.
- (void)authorizeFromViewController:(UIViewController *)viewController
                         completion:(void (^_Nullable)(BOOL success, NSError *_Nullable error))completion;
- (void)logout;

// Called from the playback hooks.
- (void)updateWithTrack:(YTMUDiscordTrack *)track;
- (void)clearPresence;

// Drops the cached presence so the next update is always sent (used when the
// user changes a display option).
- (void)invalidateCachedPresence;

@end

NS_ASSUME_NONNULL_END
