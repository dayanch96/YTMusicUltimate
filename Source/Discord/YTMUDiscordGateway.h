#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YTMUDiscordGateway;

@protocol YTMUDiscordGatewayDelegate <NSObject>
- (void)gatewayDidBecomeReady:(YTMUDiscordGateway *)gateway;
- (void)gatewayDidResume:(YTMUDiscordGateway *)gateway;
- (void)gateway:(YTMUDiscordGateway *)gateway didDisconnectWithCode:(NSInteger)code reason:(nullable NSString *)reason;
// The token was rejected (close code 4004); the manager should refresh it and
// call -connect again.
- (void)gatewayRequiresTokenRefresh:(YTMUDiscordGateway *)gateway;
@end

// Minimal Discord gateway client: connects over a web socket, keeps the
// heartbeat going, identifies with a bearer token and resumes/re-identifies
// on its own after a drop.
@interface YTMUDiscordGateway : NSObject

@property (nonatomic, weak, nullable) id<YTMUDiscordGatewayDelegate> delegate;
@property (nonatomic, readonly, getter=isReady) BOOL ready;

// YES while connected or working through a reconnect. Goes back to NO once the
// gateway gives up or is disconnected, which is the cue to call -connect again.
@property (atomic, readonly, getter=isActive) BOOL active;

// Returns "Bearer <access token>"; invoked again on every reconnect so a
// refreshed token is picked up automatically. Called off the main thread.
@property (nonatomic, copy, nullable) NSString *_Nullable (^tokenProvider)(void);

- (void)connect;
- (void)disconnect;

// Sends a pre-serialised op 3 frame. No-op while disconnected.
- (void)sendPresenceUpdate:(NSString *)presenceJSON;

@end

NS_ASSUME_NONNULL_END
