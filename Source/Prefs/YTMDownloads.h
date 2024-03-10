#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import "Localization.h"

@interface YTMDownloads : UIViewController <UITableViewDelegate, UITableViewDataSource> 
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray *audioFiles;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) UIImage *icon;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle;
- (void)show;
@end
