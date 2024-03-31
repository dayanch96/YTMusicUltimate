#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"

@interface NavBarSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end