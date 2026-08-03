#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"

@interface DiscordSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end
