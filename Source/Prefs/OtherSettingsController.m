#import "OtherSettingsController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

extern NSBundle *YTMusicUltimateBundle();

@implementation OtherSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizer];

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
    if (indexPath.section == 1) {
        return 45;
    } else {
        return 60;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 1;
    } return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *tweakBundle = YTMusicUltimateBundle();

    if (section == 1) {
        return LOC(@"STARTUP_TAB");
    } else {
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSBundle *tweakBundle = YTMusicUltimateBundle();
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"DONT_STICK_HEADERS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"DONT_STICK_HEADERS_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }

            UISwitch *noStickyHeaders = [[UISwitch alloc] initWithFrame:CGRectZero];
            noStickyHeaders.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [noStickyHeaders addTarget:self action:@selector(toggleNoStickyHeaders:) forControlEvents:UIControlEventValueChanged];
            noStickyHeaders.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"noStickyHeaders_enabled"];
            cell.accessoryView = noStickyHeaders;
        } if (indexPath.row == 1) {
            cell.textLabel.text = LOC(@"REMOVE_TABBAR_LABELS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"REMOVE_TABBAR_LABELS_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *noTabBarLabels = [[UISwitch alloc] initWithFrame:CGRectZero];
            noTabBarLabels.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [noTabBarLabels addTarget:self action:@selector(toggleNoTabBarLabels:) forControlEvents:UIControlEventValueChanged];
            noTabBarLabels.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"noTabBarLabels_enabled"];
            cell.accessoryView = noTabBarLabels;
        }
    } if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            UISegmentedControl *startupPage = [[UISegmentedControl alloc] initWithItems:@[LOC(@"HOME"), LOC(@"EXPLORE"), LOC(@"LIBRARY")]];

            for (UIView *segmentView in startupPage.subviews) {
                for (UIView *subview in segmentView.subviews) {
                    if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        label.adjustsFontSizeToFitWidth = YES;
                    }
                }
            }

            startupPage.selectedSegmentIndex = [defaults integerForKey:@"startupPage"];
            [startupPage addTarget:self action:@selector(startupPageSelect:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:startupPage];
            startupPage.translatesAutoresizingMaskIntoConstraints = NO;
            [startupPage.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = YES;
            [startupPage.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor].active = YES;
            [startupPage.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:5.0].active = YES;
            [startupPage.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-5.0].active = YES;
}
    }

    return cell;
}

#pragma mark - Nav bar stuff
- (NSString *)title {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    return LOC(@"OTHER_SETTINGS");
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

@implementation OtherSettingsController (Privates)

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleNoStickyHeaders:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noStickyHeaders_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noStickyHeaders_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleNoTabBarLabels:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noTabBarLabels_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noTabBarLabels_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)startupPageSelect:(UISegmentedControl *)sender {
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    NSString *selectedSegment = [sender titleForSegmentAtIndex:selectedIndex];
    NSLog(@"Selected segment: %@", selectedSegment);
    if (selectedIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"startupPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"startupPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"startupPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end