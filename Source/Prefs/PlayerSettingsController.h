#import "UIKit/UIKit.h"

@interface PlayerSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UITableView* tableView;
- (UIView *)KBToolbar:(UITextField *)textField;
@end