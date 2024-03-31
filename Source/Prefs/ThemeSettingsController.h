#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"

@interface ThemeSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end