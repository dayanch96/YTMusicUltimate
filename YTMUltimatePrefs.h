//
//  YTMUltimatePrefs.h
//  
//
//  Created by Noah Little on 17/8/21.
//
#import <UIKit/UIKit.h>

@interface YTMUltimatePrefs : NSObject
@property(nonatomic,assign) BOOL isEnabled;
@property(nonatomic,assign) BOOL oledDarkTheme;
@property(nonatomic,assign) BOOL oledDarkKeyboard;
+ (instancetype)sharedInstance;
@end