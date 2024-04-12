#import "PlayerSettingsController.h"

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
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    } if (section == 2) {
        return 3;
    } if (section == 3) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return LOC(@"SEEK_TIME_FOOTER");
    }

    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"boolsCell"];
        
        NSArray *settingsData = @[
            @{@"title": LOC(@"DOWNLOAD_AUDIO"), @"desc": LOC(@"DOWNLOAD_AUDIO_DESC"), @"key": @"downloadAudio"},
            @{@"title": LOC(@"DOWNLOAD_COVER"), @"desc": LOC(@"DOWNLOAD_COVER_DESC"), @"key": @"downloadCoverImage"},
            @{@"title": LOC(@"PLAYBACK_RATE_BUTTON"), @"desc": LOC(@"PLAYBACK_RATE_BUTTON_DESC"), @"key": @"playbackRateButton"},
            @{@"title": LOC(@"SELECTABLE_LYRICS"), @"desc": LOC(@"SELECTABLE_LYRICS_DESC"), @"key": @"selectableLyrics"},
            @{@"title": LOC(@"VOLBAR"), @"desc": LOC(@"VOLBAR_DESC"), @"key": @"volBar"},
            @{@"title": LOC(@"NO_AUTORADIO"), @"desc": LOC(@"NO_AUTORADIO_DESC"), @"key": @"disableAutoRadio"},
            @{@"title": LOC(@"SKIP_CONTENT_WARNING"), @"desc": LOC(@"SKIP_CONTENT_WARNING_DESC"), @"key": @"skipWarning"}
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = data[@"desc"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

        ABCSwitch *switchControl = [[NSClassFromString(@"ABCSwitch") alloc] init];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
        switchControl.tag = indexPath.row;
        switchControl.on = [YTMUltimateDict[data[@"key"]] boolValue];
        cell.accessoryView = switchControl;

        return cell;
    }

    if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"avCell"];
        cell.textLabel.text = LOC(@"AV_DEFAULT_MODE");

        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[[UIImage systemImageNamed:@"music.note"], [UIImage systemImageNamed:@"film"]]];
        control.selectedSegmentIndex = [YTMUltimateDict[@"audioVideoMode"] integerValue];
        [control addTarget:self action:@selector(controlSelect:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = control;

        return cell;
    }

    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sbBoolCell"];

            cell.textLabel.text = LOC(@"SKIP_NONMUSIC_PARTS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"SKIP_NONMUSIC_PARTS_DESC");
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

            ABCSwitch *switchControl = [[NSClassFromString(@"ABCSwitch") alloc] init];
            switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [switchControl addTarget:self action:@selector(toggleSBSwitch:) forControlEvents:UIControlEventValueChanged];
            switchControl.tag = indexPath.row;
            switchControl.on = [YTMUltimateDict[@"sponsorBlock"] boolValue];
            cell.accessoryView = switchControl;

            return cell;
        }

        if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sbBehaviorCell"];

            cell.textLabel.text = LOC(@"SB_BEHAVIOR");

            UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[LOC(@"SB_SKIP"), LOC(@"SB_ASK")]];
            control.selectedSegmentIndex = [YTMUltimateDict[@"sbSkipMode"] integerValue];
            [control addTarget:self action:@selector(controlSbSelect:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = control;

            return cell;
        }

        if (indexPath.row == 2) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"sbDurationCell"];

            cell.textLabel.text = LOC(@"SB_NOTIF_DURATION");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;

            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, cell.contentView.frame.size.height)];
            textField.text = [NSString stringWithFormat:@"%ld", [YTMUltimateDict[@"sbDuration"] integerValue]];
            textField.font = [UIFont systemFontOfSize:13.0];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.textAlignment = NSTextAlignmentRight;
            textField.inputAccessoryView = [self KBToolbar:textField];
            textField.delegate = self;

            cell.accessoryView = textField;

            return cell;
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"seekButtonsCell"];

            cell.textLabel.text = LOC(@"SEEK_BUTTONS");
            cell.textLabel.numberOfLines = 0;

            ABCSwitch *seekButtons = [[NSClassFromString(@"ABCSwitch") alloc] init];
            seekButtons.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [seekButtons addTarget:self action:@selector(toggleSeekButtons:) forControlEvents:UIControlEventValueChanged];
            seekButtons.on = [YTMUltimateDict[@"seekButtons"] boolValue];
            cell.accessoryView = seekButtons;

            return cell;
        }

        if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"seekTimeCell"];
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

            return cell;
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)toggleSwitch:(UISwitch *)sender {
    NSArray *settingsData = @[
        @{@"key": @"downloadAudio"},
        @{@"key": @"downloadCoverImage"},
        @{@"key": @"playbackRateButton"},
        @{@"key": @"selectableLyrics"},
        @{@"key": @"volBar"},
        @{@"key": @"disableAutoRadio"},
        @{@"key": @"skipWarning"},
    ];

    NSDictionary *data = settingsData[sender.tag];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:data[@"key"]];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)toggleSBSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:@"sponsorBlock"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)controlSbSelect:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@(sender.selectedSegmentIndex) forKey:@"sbSkipMode"];
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    NSArray *emptyVals = @[@"", @"0"];
    if ([emptyVals containsObject:textField.text]) {
        [YTMUltimateDict setObject:@(10) forKey:@"sbDuration"];
    } else {
        [YTMUltimateDict setObject:@([textField.text integerValue]) forKey:@"sbDuration"];
    }

    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];

    textField.text = [NSString stringWithFormat:@"%ld", [YTMUltimateDict[@"sbDuration"] integerValue]];
}

- (UIView *)KBToolbar:(UITextField *)textField {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    toolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];

    [toolbar setItems:@[flexibleSpace, hideKeyboardButton]];

    return toolbar;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end