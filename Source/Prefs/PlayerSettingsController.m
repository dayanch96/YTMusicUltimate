#import "PlayerSettingsController.h"
#import "Localization.h"

@implementation PlayerSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"PLAYER_SETTINGS");

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
        return 5;
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

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"PLAYBACK_RATE_BUTTON"), @"desc": LOC(@"PLAYBACK_RATE_BUTTON_DESC"), @"selector": @"togglePlaybackRateButton:", @"key": @"playbackRateButton_enabled"},
            @{@"title": LOC(@"SELECTABLE_LYRICS"), @"desc": LOC(@"SELECTABLE_LYRICS_DESC"), @"selector": @"toggleSelectableLyrics:", @"key": @"selectableLyrics_enabled"},
            @{@"title": LOC(@"VOLBAR"), @"desc": LOC(@"VOLBAR_DESC"), @"selector": @"toggleVolBar:", @"key": @"volBar_enabled"},
            @{@"title": LOC(@"NO_AUTORADIO"), @"desc": LOC(@"NO_AUTORADIO_DESC"), @"selector": @"toggleDisableAutoRadio:", @"key": @"disableAutoRadio_enabled"},
            @{@"title": LOC(@"SKIP_NONMUSIC_PARTS"), @"desc": LOC(@"SKIP_NONMUSIC_PARTS_DESC"), @"selector": @"toggleSponsorBlock:", @"key": @"sponsorBlock_enabled"}
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
    } if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell2"];
            BOOL audioVideoMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"AudioVideoMode"];
            cell.textLabel.text = LOC(@"AV_DEFAULT_MODE");

            UISegmentedControl *control;
            if (@available(iOS 13, *)) {
                control = [[UISegmentedControl alloc] initWithItems:@[[UIImage systemImageNamed:@"music.note"], [UIImage systemImageNamed:@"film"]]];
            } else {
                control = [[UISegmentedControl alloc] initWithItems:@[LOC(@"AUDIO"), LOC(@"VIDEO")]];
            }

            control.selectedSegmentIndex = audioVideoMode ? 0 : 1;
            [control addTarget:self action:@selector(controlSelect:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:control];
            control.translatesAutoresizingMaskIntoConstraints = NO;
            [control.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = YES;
            [control.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-6].active = YES;
            
        } return cell;
    } if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"SEEK_BUTTONS");
            cell.textLabel.numberOfLines = 0;

            UISwitch *seekButtons = [[UISwitch alloc] initWithFrame:CGRectZero];
            seekButtons.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [seekButtons addTarget:self action:@selector(toggleSeekButtons:) forControlEvents:UIControlEventValueChanged];
            seekButtons.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"seekButtons_enabled"];
            cell.accessoryView = seekButtons;
        } if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell3"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

            UISegmentedControl *seekTime = [[UISegmentedControl alloc] initWithItems:@[LOC(@"DEFAULT"), @"10", @"20", @"30", @"60"]];

            for (UIView *segmentView in seekTime.subviews) {
                for (UIView *subview in segmentView.subviews) {
                    if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        label.adjustsFontSizeToFitWidth = YES;
                    }
                }
            }

            seekTime.selectedSegmentIndex = [defaults integerForKey:@"seekTime"];
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

@end

@implementation PlayerSettingsController (Privates)

- (void)togglePlaybackRateButton:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"playbackRateButton_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleSelectableLyrics:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"selectableLyrics_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleVolBar:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"volBar_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleDisableAutoRadio:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"disableAutoRadio_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleSponsorBlock:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"sponsorBlock_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleSeekButtons:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"seekButtons_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)controlSelect:(UISegmentedControl *)sender {
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    NSString *selectedSegment = [sender titleForSegmentAtIndex:selectedIndex];
    NSLog(@"Selected segment: %@", selectedSegment);
    if (selectedIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AudioVideoMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AudioVideoMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)seekTimeSelect:(UISegmentedControl *)sender {
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    NSLog(@"Selected segment: %@", [sender titleForSegmentAtIndex:selectedIndex]);
    
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"seekTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end