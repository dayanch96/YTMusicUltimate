#import "UIKit/UIKit.h"
#import "Localization.h"

@interface ThemeSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end