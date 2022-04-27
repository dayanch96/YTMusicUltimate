//
//  YTMUltimatePrefs.h
//  
//
//  Created by Noah Little on 17/8/21.
//
@interface YTMUltimatePrefs : NSObject
@property(nonatomic,assign) BOOL isEnabled;
@property(nonatomic,assign) BOOL showStatusBarInPlayer;
+(id)sharedInstance;
@end
