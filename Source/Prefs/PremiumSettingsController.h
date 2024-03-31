#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"

@interface PremiumSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end