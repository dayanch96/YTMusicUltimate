#import "YTIIcon.h"
#import "YTICommand.h"
#import "YTIFormattedString.h"

@interface YTIPivotBarItemRenderer : NSObject
@property (nonatomic, retain) YTIIcon *icon; // @dynamic icon;
@property (nonatomic, retain) YTICommand *navigationEndpoint; // @dynamic navigationEndpoint;
@property (nonatomic, copy) NSString *pivotIdentifier;
@property (nonatomic, retain) YTIFormattedString *title; // @dynamic title;
@property (nonatomic, copy) NSData *trackingParams; // @dynamic trackingParams;
@end