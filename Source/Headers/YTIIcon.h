#import <Foundation/Foundation.h>

@interface YTIIcon : NSObject
@property (nonatomic, assign, readwrite) int iconType;
@property (nonatomic, assign, readwrite) BOOL hasIconType;
- (UIImage *)iconImageWithColor:(UIColor *)color;
- (UIImage *)newIconImageWithColor:(UIColor *)color;
@end
