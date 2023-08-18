#import "NavBarSettingsController.h"
#import "Localization.h"

@implementation NavBarSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"NAVBAR_SETTINGS");

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
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"DONT_STICK_HEADERS"), @"desc": LOC(@"DONT_STICK_HEADERS_DESC"), @"selector": @"toggleNoStickyHeaders:", @"key": @"noStickyHeaders_enabled"},
            @{@"title": LOC(@"HIDE_HISTORY_BUTTON"), @"desc": LOC(@"HIDE_HISTORY_BUTTON_DESC"), @"selector": @"toggleHideHistoryButton:", @"key": @"hideHistoryButton_enabled"},
            @{@"title": LOC(@"HIDE_CAST_BUTTON"), @"desc": LOC(@"HIDE_CAST_BUTTON_DESC"), @"selector": @"toggleHideCastButton:", @"key": @"hideCastButton_enabled"},
            @{@"title": LOC(@"HIDE_FILTER_BUTTON"), @"desc": LOC(@"HIDE_FILTER_BUTTON_DESC"), @"selector": @"toggleHideFilterButton:", @"key": @"hideFilterButton_enabled"}
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = data[@"desc"];
        cell.detailTextLabel.numberOfLines = 0;

        if (@available(iOS 13, *)) {
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        }

        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:NSSelectorFromString(data[@"selector"]) forControlEvents:UIControlEventValueChanged];
        switchControl.on = [[NSUserDefaults standardUserDefaults] boolForKey:data[@"key"]];
        cell.accessoryView = switchControl;
    }

    return cell;
}

@end

@implementation NavBarSettingsController (Privates)

- (void)toggleNoStickyHeaders:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"noStickyHeaders_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideHistoryButton:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideHistoryButton_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideCastButton:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideCastButton_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleHideFilterButton:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"hideFilterButton_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end