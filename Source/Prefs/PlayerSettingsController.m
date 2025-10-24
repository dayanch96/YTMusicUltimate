#import "PlayerSettingsController.h"
#import "Localization.h"

@interface PlayerSettingsController ()
@property (nonatomic, strong) UILabel *crossfadeDurationLabel;
@end

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

    // Reload the table view when the crossfade switch is toggled to show/hide the slider
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"YTMUltimateCrossfadeChanged" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        // Show the slider cell only if the main crossfade toggle is on
        BOOL crossfadeEnabled = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"] objectForKey:@"crossfade"] boolValue];
        return crossfadeEnabled ? 9 : 8;
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
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0) {
        if (indexPath.row < 8) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boolsCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"boolsCell"];
            }

            NSArray *settingsData = @[
                @{@"title": LOC(@"DOWNLOAD_AUDIO"), @"desc": LOC(@"DOWNLOAD_AUDIO_DESC"), @"key": @"downloadAudio"},
                @{@"title": LOC(@"DOWNLOAD_COVER"), @"desc": LOC(@"DOWNLOAD_COVER_DESC"), @"key": @"downloadCoverImage"},
                @{@"title": LOC(@"PLAYBACK_RATE_BUTTON"), @"desc": LOC(@"PLAYBACK_RATE_BUTTON_DESC"), @"key": @"playbackRateButton"},
                @{@"title": LOC(@"SELECTABLE_LYRICS"), @"desc": LOC(@"SELECTABLE_LYRICS_DESC"), @"key": @"selectableLyrics"},
                @{@"title": LOC(@"VOLBAR"), @"desc": LOC(@"VOLBAR_DESC"), @"key": @"volBar"},
                @{@"title": LOC(@"NO_AUTORADIO"), @"desc": LOC(@"NO_AUTORADIO_DESC"), @"key": @"disableAutoRadio"},
                @{@"title": LOC(@"SKIP_CONTENT_WARNING"), @"desc": LOC(@"SKIP_CONTENT_WARNING_DESC"), @"key": @"skipWarning"},
                @{@"title": LOC(@"CROSSFADE"), @"desc": LOC(@"CROSSFADE_DESC"), @"key": @"crossfade"}
            ];

            NSDictionary *data = settingsData[indexPath.row];
            cell.textLabel.text = data[@"title"];
            cell.detailTextLabel.text = data[@"desc"];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            ABCSwitch *switchControl = [[NSClassFromString(@"ABCSwitch") alloc] init];
            switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
            [switchControl addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
            switchControl.tag = indexPath.row;
            switchControl.on = [YTMUltimateDict[data[@"key"]] boolValue];
            cell.accessoryView = switchControl;
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sliderCell"];
            }

            cell.textLabel.text = LOC(@"CROSSFADE_DURATION");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // Slider
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.5, 40)];
            slider.minimumValue = 1;
            slider.maximumValue = 10;
            slider.continuous = YES;
            [slider addTarget:self action:@selector(crossfadeSliderChanged:) forControlEvents:UIControlEventValueChanged];

            int currentDuration = [YTMUltimateDict[@"crossfadeDuration"] intValue];
            if (currentDuration < 1) currentDuration = 5; // Default value
            slider.value = currentDuration;

            // Value Label
            self.crossfadeDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 + 8, 0, 40, 40)];
            self.crossfadeDurationLabel.text = [NSString stringWithFormat:@"%d s", currentDuration];

            UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.5 + 48, 40)];
            [accessory addSubview:slider];
            [accessory addSubview:self.crossfadeDurationLabel];
            cell.accessoryView = accessory;

            return cell;
        }
    }

    //
    // THIS IS THE CODE I ACCIDENTALLY DELETED. IT IS NOW RESTORED.
    //
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
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

#pragma mark - Actions

- (void)toggleSwitch:(UISwitch *)sender {
    NSArray *keys = @[@"downloadAudio", @"downloadCoverImage", @"playbackRateButton", @"selectableLyrics", @"volBar", @"disableAutoRadio", @"skipWarning", @"crossfade"];
    NSString *key = keys[sender.tag];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];
    [YTMUltimateDict setObject:@(sender.isOn) forKey:key];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];

    if ([key isEqualToString:@"crossfade"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YTMUltimateCrossfadeChanged" object:nil];
    }
}

- (void)crossfadeSliderChanged:(UISlider *)sender {
    int discreteValue = roundl(sender.value);
    self.crossfadeDurationLabel.text = [NSString stringWithFormat:@"%d s", discreteValue];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];
    [YTMUltimateDict setObject:@(discreteValue) forKey:@"crossfadeDuration"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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
