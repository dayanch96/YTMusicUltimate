#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import "../Headers/YTAlertView.h"
#import "../Headers/YTMToastController.h"
#import "../Headers/Localization.h"

@interface YTMDownloads : UIViewController <UITableViewDelegate, UITableViewDataSource> 
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray *audioFiles;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end
