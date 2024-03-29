#import "UIKit/UIKit.h"
#import "Localization.h"

@interface NavBarSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end