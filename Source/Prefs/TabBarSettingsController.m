#import "TabBarSettingsController.h"
#import "Localization.h"

@implementation OtherSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"TABBAR_SETTINGS");

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
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];
}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 5;
    } else {
        return 1;
    } return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return LOC(@"STARTUP_TAB");
    } if (section == 1) {
        return LOC(@"TAB_SETTINGS");
    } else {
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell0"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        UISegmentedControl *startupPage = [[UISegmentedControl alloc] initWithItems:@[LOC(@"HOME"), LOC(@"SAMPLES"), LOC(@"EXPLORE"), LOC(@"LIBRARY")]];

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
    } if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"REMOVE_TABBAR_LABELS"), @"selector": @"toggleNoTabBarLabels:", @"key": @"noTabBarLabels_enabled"},
            @{@"title": LOC(@"HIDE_HOME"), @"selector": @"toggleHideHome:", @"key": @"hideHomeTab"},
            @{@"title": LOC(@"HIDE_SAMPLES"), @"selector": @"toggleHideSamples:", @"key": @"hideSamplesTab"},
            @{@"title": LOC(@"HIDE_EXPLORE"), @"selector": @"toggleHideExplore:", @"key": @"hideExploreTab"},
            @{@"title": LOC(@"HIDE_LIBRARY"), @"selector": @"toggleHideLibrary:", @"key": @"hideLibraryTab"},
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:NSSelectorFromString(data[@"selector"]) forControlEvents:UIControlEventValueChanged];
        switchControl.on = [[NSUserDefaults standardUserDefaults] boolForKey:data[@"key"]];
        cell.accessoryView = switchControl;
    }

    return cell;
}

@end

@implementation OtherSettingsController (Privates)

- (void)startupPageSelect:(UISegmentedControl *)sender {
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    NSLog(@"Selected segment: %@", [sender titleForSegmentAtIndex:selectedIndex]);

    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"startupPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleNoTabBarLabels:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"noTabBarLabels_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideHome:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideHomeTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideSamples:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideSamplesTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideExplore:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideExploreTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideLibrary:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideLibraryTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end