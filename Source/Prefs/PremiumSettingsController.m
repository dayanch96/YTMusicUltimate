#import "PremiumSettingsController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

extern NSBundle *YTMusicUltimateBundle();

@implementation PremiumSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [self backButton];

    UITableViewStyle style;
    if (@available(iOS 13, *)) {
        style = UITableViewStyleInsetGrouped;
    } else {
        style = UITableViewStyleGrouped;
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSBundle *tweakBundle = YTMusicUltimateBundle();
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"NO_ADS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"NO_ADS_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }

            UISwitch *noAds = [[UISwitch alloc] initWithFrame:CGRectZero];
            [noAds addTarget:self action:@selector(toggleNoAds:) forControlEvents:UIControlEventValueChanged];
            noAds.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"noAds_enabled"];
            cell.accessoryView = noAds;
        } if (indexPath.row == 1) {
            cell.textLabel.text = LOC(@"BACKGROUND_PLAYBACK");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"BACKGROUND_PLAYBACK_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *backgroundPlayback = [[UISwitch alloc] initWithFrame:CGRectZero];
            [backgroundPlayback addTarget:self action:@selector(toggleBackgroundPlayback:) forControlEvents:UIControlEventValueChanged];
            backgroundPlayback.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundPlayback_enabled"];
            cell.accessoryView = backgroundPlayback;
        }
    }

    return cell;
}

#pragma mark - Nav bar stuff
- (NSString *)title {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    return LOC(@"PREMIUM_SETTINGS");
}

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *item;

    if (@available(iOS 13, *)) {
        item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"chevron.left"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(back)];
    } else {
        NSBundle *tweakBundle = YTMusicUltimateBundle();
        item = [[UIBarButtonItem alloc] initWithTitle:LOC(@"BACK")
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(back)];
    }

    return item;
}

@end

@implementation PremiumSettingsController (Privates)

- (void)back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleNoAds:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noAds_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noAds_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleBackgroundPlayback:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backgroundPlayback_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backgroundPlayback_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end