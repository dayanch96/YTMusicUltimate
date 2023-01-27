#import "UIKit/UIKit.h"

@interface YTMUltimateSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *>* options;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *>* links;
@end
