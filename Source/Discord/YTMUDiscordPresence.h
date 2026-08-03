#import <Foundation/Foundation.h>
#import "YTMUDiscordDefaults.h"

NS_ASSUME_NONNULL_BEGIN

// A single entry of the `activities` array of an op 3 presence update.
@interface YTMUDiscordActivity : NSObject <NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) YTMUDiscordActivityType type;
@property (nonatomic, copy, nullable) NSString *details;
@property (nonatomic, copy, nullable) NSString *state;

// Either an `mp:external/...` path resolved through the external-assets
// endpoint or an asset key registered on the Discord application.
@property (nonatomic, copy, nullable) NSString *largeImage;
@property (nonatomic, copy, nullable) NSString *largeText;
@property (nonatomic, copy, nullable) NSString *smallImage;
@property (nonatomic, copy, nullable) NSString *smallText;

// Unix epoch milliseconds. Zero means "omit".
@property (nonatomic, assign) long long startTimestamp;
@property (nonatomic, assign) long long endTimestamp;

// Array of two element @[label, url] arrays.
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *buttons;

- (NSDictionary *)JSONObject;

@end

@interface YTMUDiscordPresence : NSObject

// Serialises an op 3 PRESENCE UPDATE frame. Pass an empty array to clear.
+ (nullable NSString *)presenceUpdateJSONWithActivities:(NSArray<YTMUDiscordActivity *> *)activities
                                                 status:(NSString *)status;

@end

NS_ASSUME_NONNULL_END
