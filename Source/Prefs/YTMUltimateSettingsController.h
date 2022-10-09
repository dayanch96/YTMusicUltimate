#import "UIKit/UIKit.h"

@interface YTMUltimateSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *>* options;
@end
