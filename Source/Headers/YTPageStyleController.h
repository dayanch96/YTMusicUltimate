#import "YTCommonColorPalette.h"

@interface YTPageStyleController : NSObject
+ (YTCommonColorPalette *)currentColorPalette;
+ (NSInteger)pageStyle;
@property (nonatomic, assign, readwrite) NSInteger appThemeSetting;
@property (nonatomic, assign, readonly) NSInteger pageStyle;
@end