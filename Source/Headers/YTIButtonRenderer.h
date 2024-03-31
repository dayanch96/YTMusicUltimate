#import "YTIIcon.h"
#import "YTIFormattedString.h"
#import "YTIAccessibilitySupportedDatas.h"
#import "YTICommand.h"

@interface YTIButtonRenderer : NSObject
@property (nonatomic, assign, readwrite) int style;
@property (nonatomic, assign, readwrite) int size;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, strong, readwrite) YTIAccessibilityData *accessibility;
@property (nonatomic, strong, readwrite) YTIAccessibilitySupportedDatas *accessibilityData;
@property (nonatomic, strong, readwrite) YTICommand *command;
@end