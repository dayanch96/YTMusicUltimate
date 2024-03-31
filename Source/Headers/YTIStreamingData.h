#import <Foundation/Foundation.h>

@interface YTIStreamingData : NSObject
@property (nonatomic, copy, readwrite) NSString *hlsManifestURL;
@property (nonatomic, copy, readwrite) NSMutableArray *adaptiveFormatsArray;
@end