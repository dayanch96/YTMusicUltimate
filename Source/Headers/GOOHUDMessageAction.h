#import <Foundation/Foundation.h>

@interface GOOHUDMessageAction : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
- (void)setHandler:(void(^)(void))handler;
@end