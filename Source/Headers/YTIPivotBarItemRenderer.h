#import "YTIIcon.h"
#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIAccessibilitySupportedDatas.h"

@interface YTIPivotBarItemRenderer : NSObject
@property (nonatomic, copy, readwrite) NSString *pivotIdentifier;
@property (nonatomic, copy, readwrite) NSString *targetId;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, strong, readwrite) YTIFormattedString *title;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@property (nonatomic, strong, readwrite) YTIAccessibilitySupportedDatas *accessibility;
@end