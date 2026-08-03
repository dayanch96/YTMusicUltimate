#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Discord will not load arbitrary image URLs in a presence. They first have to
// be registered against the application, which hands back an
// `mp:external/...` path usable as an asset key.
@interface YTMUDiscordExternalAssets : NSObject

+ (void)resolveImageURL:(NSString *)imageURL
          applicationID:(NSString *)applicationID
            bearerToken:(NSString *)bearerToken
             completion:(void (^)(NSString *_Nullable assetPath))completion;

+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
