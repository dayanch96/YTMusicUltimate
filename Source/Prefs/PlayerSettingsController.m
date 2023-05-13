#import "PlayerSettingsController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

extern NSBundle *YTMusicUltimateBundle();

@implementation PlayerSettingsController

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
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    if (section == 2) {
        return LOC(@"SEEK_TIME_FOOTER");
    } return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSBundle *tweakBundle = YTMusicUltimateBundle();
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"PLAYBACK_RATE_BUTTON");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"PLAYBACK_RATE_BUTTON_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }

            UISwitch *playbackRateButton = [[UISwitch alloc] initWithFrame:CGRectZero];
            [playbackRateButton addTarget:self action:@selector(togglePlaybackRateButton:) forControlEvents:UIControlEventValueChanged];
            playbackRateButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"playbackRateButton_enabled"];
            cell.accessoryView = playbackRateButton;
        } if (indexPath.row == 1) {
            cell.textLabel.text = LOC(@"SELECTABLE_LYRICS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"SELECTABLE_LYRICS_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *selectableLyrics = [[UISwitch alloc] initWithFrame:CGRectZero];
            [selectableLyrics addTarget:self action:@selector(toggleSelectableLyrics:) forControlEvents:UIControlEventValueChanged];
            selectableLyrics.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"selectableLyrics_enabled"];
            cell.accessoryView = selectableLyrics;
        } if (indexPath.row == 2) {
            cell.textLabel.text = LOC(@"VOLBAR");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"VOLBAR_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *volBar = [[UISwitch alloc] initWithFrame:CGRectZero];
            [volBar addTarget:self action:@selector(toggleVolBar:) forControlEvents:UIControlEventValueChanged];
            volBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"volBar_enabled"];
            cell.accessoryView = volBar;
        } if (indexPath.row == 3) {
            cell.textLabel.text = LOC(@"NO_AUTORADIO");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"NO_AUTORADIO_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *disableAutoRadio = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableAutoRadio addTarget:self action:@selector(toggleDisableAutoRadio:) forControlEvents:UIControlEventValueChanged];
            disableAutoRadio.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"disableAutoRadio_enabled"];
            cell.accessoryView = disableAutoRadio;
        } if (indexPath.row == 4) {
            cell.textLabel.text = LOC(@"SKIP_NONMUSIC_PARTS");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = LOC(@"SKIP_NONMUSIC_PARTS_DESC");
            cell.detailTextLabel.numberOfLines = 0;

            if (@available(iOS 13, *)) {
                cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            }
            UISwitch *sponsorBlock = [[UISwitch alloc] initWithFrame:CGRectZero];
            [sponsorBlock addTarget:self action:@selector(toggleSponsorBlock:) forControlEvents:UIControlEventValueChanged];
            sponsorBlock.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"sponsorBlock_enabled"];
            cell.accessoryView = sponsorBlock;
        }
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
            
        }
        return cell;
    } if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"SEEK_BUTTONS");
            cell.textLabel.numberOfLines = 0;

            UISwitch *seekButtons = [[UISwitch alloc] initWithFrame:CGRectZero];
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

#pragma mark - Nav bar stuff
- (NSString *)title {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    return LOC(@"PLAYER_SETTINGS");
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

@implementation PlayerSettingsController (Privates)

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)togglePlaybackRateButton:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playbackRateButton_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playbackRateButton_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleSelectableLyrics:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"selectableLyrics_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"selectableLyrics_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleVolBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"volBar_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"volBar_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableAutoRadio:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"disableAutoRadio_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"disableAutoRadio_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleSponsorBlock:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sponsorBlock_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sponsorBlock_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleSeekButtons:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seekButtons_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"seekButtons_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    NSString *selectedSegment = [sender titleForSegmentAtIndex:selectedIndex];
    NSLog(@"Selected segment: %@", selectedSegment);
    if (selectedIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"seekTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"seekTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 2) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"seekTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 3) {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"seekTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (selectedIndex == 4) {
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"seekTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end