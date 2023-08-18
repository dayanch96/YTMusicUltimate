#import "ThemeSettingsController.h"
#import "Localization.h"

@implementation ThemeSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"THEME_SETTINGS");

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
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"OLED_DARK_THEME"), @"desc": LOC(@"OLED_DARK_THEME_DESC"), @"selector": @"toggleOledDarkTheme:", @"key": @"oledDarkTheme_enabled"},
            @{@"title": LOC(@"OLED_DARK_KEYBOARD"), @"desc": LOC(@"OLED_DARK_KEYBOARD_DESC"), @"selector": @"toggleOledDarkKeyboard:", @"key": @"oledDarkKeyboard_enabled"},
            @{@"title": LOC(@"LOW_CONTRAST"), @"desc": LOC(@"LOW_CONTRAST_DESC"), @"selector": @"toggleLowContrast:", @"key": @"lowContrast_enabled"}
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

@implementation ThemeSettingsController (Privates)

- (void)toggleOledDarkTheme:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"oledDarkTheme_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleOledDarkKeyboard:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"oledDarkKeyboard_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleLowContrast:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"lowContrast_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end