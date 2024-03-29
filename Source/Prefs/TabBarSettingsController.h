#import "UIKit/UIKit.h"
#import "Localization.h"

@interface OtherSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* tableView;
@end

@interface YTAssetLoader : NSObject
- (instancetype)initWithBundle:(NSBundle *)bundle;
- (UIImage *)imageNamed:(NSString *)image;
@end