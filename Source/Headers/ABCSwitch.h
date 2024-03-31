#import <UIKit/UIKit.h>

@interface ABCSwitch : UIControl
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, assign, readwrite, getter=isOn) BOOL on;
@end