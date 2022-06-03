#import "YTMUltimatePrefs.h"
#import "YTMUltimateSettingsController.h"

@implementation YTMUltimateSettingsController

-(void)viewDidLoad{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 100)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.textColor = [UIColor redColor];
    headerLabel.text = @"YTMusicUltimate";
    headerLabel.font = [UIFont systemFontOfSize:38];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:headerLabel];
    //x
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //y
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //subtitleLabel.textColor = [UIColor Color];
    subtitleLabel.text = @"By @Ginsu";
    subtitleLabel.font = [UIFont systemFontOfSize:12];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:subtitleLabel];
    //x
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:subtitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //y
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,30,30);
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13, *)) {
        [backButton setImage:[[UIImage systemImageNamed:@"arrow.backward.circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
    }
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.tintColor = [UIColor redColor];
    [self.headerView addSubview:backButton];
    //x
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
    //y
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    if (indexPath.row != 4 && indexPath.row != 5){
        cell.accessoryView = switchView;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Enabled";
            cell.detailTextLabel.text = @"Premium features, no ads, background playback, etc.";
            switchView.tag = 1;
            [switchView setOn:[[YTMUltimatePrefs sharedInstance] isEnabled] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        case 1:
            cell.textLabel.text = @"Status bar in player";
            cell.detailTextLabel.text = @"Always show the status bar.";
            switchView.tag = 2;
            [switchView setOn:[[YTMUltimatePrefs sharedInstance] showStatusBarInPlayer] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        case 2:
            cell.textLabel.text = @"OLED Dark Theme";
            cell.detailTextLabel.text = @"Enable OLED Dark Theme";
            switchView.tag = 3;
            [switchView setOn:[[YTMUltimatePrefs sharedInstance] oledDarkTheme] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        case 3:
            cell.textLabel.text = @"OLED Dark Keyboard";
            cell.detailTextLabel.text = @"Enable OLED Dark Keyboard";
            switchView.tag = 4;
            [switchView setOn:[[YTMUltimatePrefs sharedInstance] oledDarkKeyboard] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        case 4:
            cell.textLabel.text = @"Apply";
            cell.detailTextLabel.text = @"Restarts the app to apply changes.";
            cell.textLabel.textColor = [UIColor systemBlueColor];
            cell.detailTextLabel.textColor = [UIColor systemBlueColor];
            break;
        case 5:
            cell.textLabel.text = @"Follow me on Twitter";
            cell.detailTextLabel.text = @"Tap to follow @ginsudev on Twitter.";
            cell.textLabel.textColor = [UIColor systemBlueColor];
            cell.detailTextLabel.textColor = [UIColor systemBlueColor];
            break;
        default:
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4){
        @throw NSInternalInconsistencyException;
    } else if (indexPath.row == 5){
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:@"https://twitter.com/ginsudev"]
            options:@{}
            completionHandler:nil];
    }
}

- (void)switchChanged:(UISwitch *)sender{
    switch (sender.tag) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"YTMUltimateIsEnabled"];
            [[YTMUltimatePrefs sharedInstance] setIsEnabled:sender.on];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"YTMUltimateShowStatusBarInPlayer"];
            [[YTMUltimatePrefs sharedInstance] setShowStatusBarInPlayer:sender.on];
            break;
        case 3:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"oledDarkTheme_enabled"];
            [[YTMUltimatePrefs sharedInstance] setOledDarkTheme:sender.on];
            break;
        case 4:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"oledDarkKeyboard_enabled"];
            [[YTMUltimatePrefs sharedInstance] setOledDarkKeyboard:sender.on];
            break;
        default:
            break;
    }
}

@end
