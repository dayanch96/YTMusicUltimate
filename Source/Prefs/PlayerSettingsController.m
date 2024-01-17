#import "PlayerSettingsController.h"
#import "Localization.h"

@implementation PlayerSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"PLAYER_SETTINGS");
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    } if (indexPath.section == 2 && indexPath.row == 0) {
        return 70;
    } else {
        return 45;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    } if (section == 2) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return LOC(@"SEEK_TIME_FOOTER");
    } return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"PLAYBACK_RATE_BUTTON"), @"desc": LOC(@"PLAYBACK_RATE_BUTTON_DESC"), @"key": @"playbackRateButton"},
            @{@"title": LOC(@"SELECTABLE_LYRICS"), @"desc": LOC(@"SELECTABLE_LYRICS_DESC"), @"key": @"selectableLyrics"},
            @{@"title": LOC(@"VOLBAR"), @"desc": LOC(@"VOLBAR_DESC"), @"key": @"volBar"},
            @{@"title": LOC(@"NO_AUTORADIO"), @"desc": LOC(@"NO_AUTORADIO_DESC"), @"key": @"disableAutoRadio"},
            @{@"title": LOC(@"SKIP_NONMUSIC_PARTS"), @"desc": LOC(@"SKIP_NONMUSIC_PARTS_DESC"), @"key": @"sponsorBlock"},
            @{@"title": LOC(@"SKIP_CONTENT_WARNING"), @"desc": LOC(@"SKIP_CONTENT_WARNING_DESC"), @"key": @"skipWarning"}
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = data[@"desc"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
        switchControl.tag = indexPath.row;
        switchControl.on = [YTMUltimateDict[data[@"key"]] boolValue];
        cell.accessoryView = switchControl;
    } if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell2"];
            cell.textLabel.text = LOC(@"AV_DEFAULT_MODE");

            UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[[UIImage systemImageNamed:@"music.note"], [UIImage systemImageNamed:@"film"]]];
            control.selectedSegmentIndex = [YTMUltimateDict[@"audioVideoMode"] integerValue];
            [control addTarget:self action:@selector(controlSelect:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = control;
        } return cell;
    } if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"SEEK_BUTTONS");
            cell.textLabel.numberOfLines = 0;

            UISwitch *seekButtons = [[UISwitch alloc] initWithFrame:CGRectZero];
            seekButtons.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [seekButtons addTarget:self action:@selector(toggleSeekButtons:) forControlEvents:UIControlEventValueChanged];
            seekButtons.on = [YTMUltimateDict[@"seekButtons"] boolValue];
            cell.accessoryView = seekButtons;
        } if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell3"];
            UISegmentedControl *seekTime = [[UISegmentedControl alloc] initWithItems:@[LOC(@"DEFAULT"), @"10", @"20", @"30", @"60"]];

            for (UIView *segmentView in seekTime.subviews) {
                for (UIView *subview in segmentView.subviews) {
                    if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        label.adjustsFontSizeToFitWidth = YES;
                    }
                }
            }

            seekTime.selectedSegmentIndex = [YTMUltimateDict[@"seekTime"] integerValue];
            [seekTime addTarget:self action:@selector(seekTimeSelect:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:seekTime];
            seekTime.translatesAutoresizingMaskIntoConstraints = NO;
            [seekTime.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = YES;
            [seekTime.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor].active = YES;
            [seekTime.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:5.0].active = YES;
            [seekTime.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-5.0].active = YES;
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)toggleSwitch:(UISwitch *)sender {
    NSArray *settingsData = @[
        @{@"key": @"playbackRateButton"},
        @{@"key": @"selectableLyrics"},
        @{@"key": @"volBar"},
        @{@"key": @"disableAutoRadio"},
        @{@"key": @"sponsorBlock"},
        @{@"key": @"skipWarning"},
    ];

    NSDictionary *data = settingsData[sender.tag];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:data[@"key"]];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)toggleSeekButtons:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:@"seekButtons"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)controlSelect:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@(sender.selectedSegmentIndex) forKey:@"audioVideoMode"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)seekTimeSelect:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@(sender.selectedSegmentIndex) forKey:@"seekTime"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

@end