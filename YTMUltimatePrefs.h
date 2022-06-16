//
//  YTMUltimatePrefs.h
//  
//
//  Created by Noah Little on 17/8/21.
//
#import <UIKit/UIKit.h>

@interface YTMUltimatePrefs : NSObject
@property(nonatomic,assign) BOOL isEnabled;
@property(nonatomic,assign) BOOL showStatusBarInPlayer;
@property(nonatomic,assign) BOOL oledDarkTheme;
@property(nonatomic,assign) BOOL oledDarkKeyboard;
+(id)sharedInstance;
@end

// Color
@interface UIKeyboardDockView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface YTPivotBarView : UIView
@end

@interface YTMMusicMenuTitleView : UIView
@end

@interface MDCSnackbarMessageView : UIView
@end

@interface UIPredictionViewController : UIViewController
@end

@interface UICandidateViewController : UIViewController
@end