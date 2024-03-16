#import "TabBarSettingsController.h"
#import "Localization.h"

@implementation OtherSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"TABBAR_SETTINGS");
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 6;
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

    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell0"];

        UISegmentedControl *startupPage = [[UISegmentedControl alloc] initWithItems:@[[self tbImageNamed:@"yt_outline_home_24pt"], [self tbImageNamed:@"youtube_outline/samples_24pt"], [self tbImageNamed:@"yt_outline_compass_24pt"], [self tbImageNamed:@"yt_outline_library_music_24pt"], [self tbImageNamed:@"downloads"]]];

        for (UIView *segmentView in startupPage.subviews) {
            for (UIView *subview in segmentView.subviews) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subview;
                    label.adjustsFontSizeToFitWidth = YES;
                }
            }
        }

        startupPage.selectedSegmentIndex = [YTMUltimateDict[@"startupPage"] integerValue];
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
            @{@"title": LOC(@"REMOVE_TABBAR_LABELS"), @"key": @"noTabBarLabels"},
            @{@"title": LOC(@"HIDE_HOME"), @"key": @"hideHomeTab"},
            @{@"title": LOC(@"HIDE_SAMPLES"), @"key": @"hideSamplesTab"},
            @{@"title": LOC(@"HIDE_EXPLORE"), @"key": @"hideExploreTab"},
            @{@"title": LOC(@"HIDE_LIBRARY"), @"key": @"hideLibraryTab"},
            @{@"title": LOC(@"HIDE_DOWNLOADS"), @"key": @"hideDownloadsTab"}
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchControl.onTintColor = [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        [switchControl addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
        switchControl.tag = indexPath.row;
        switchControl.on = [YTMUltimateDict[data[@"key"]] boolValue];
        cell.accessoryView = switchControl;
    }

    return cell;
}

- (UIImage *)tbImageNamed:(NSString *)imageName {
    YTAssetLoader *al = [[NSClassFromString(@"YTAssetLoader") alloc] initWithBundle:[NSBundle mainBundle]];

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(24, 24)];
    UIImage *downloadsImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        UIImage *buttonImage = [UIImage imageWithContentsOfFile:[YTMusicUltimateBundle() pathForResource:@"downloads" ofType:@"png" inDirectory:@"icons"]];
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        UIImageView *buttonImageView = [[UIImageView alloc] initWithImage:buttonImage];
        buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
        buttonImageView.clipsToBounds = YES;
        buttonImageView.tintColor = [UIColor labelColor];
        buttonImageView.frame = imageView.bounds;

        [imageView addSubview:buttonImageView];
        [imageView.layer renderInContext:rendererContext.CGContext];
    }];

    return [imageName isEqualToString:@"downloads"] ? downloadsImage : [al imageNamed:imageName];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)startupPageSelect:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@(sender.selectedSegmentIndex) forKey:@"startupPage"];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

- (void)toggleSwitch:(UISwitch *)sender {
    NSArray *settingsData = @[
        @{@"key": @"noTabBarLabels"},
        @{@"key": @"hideHomeTab"},
        @{@"key": @"hideSamplesTab"},
        @{@"key": @"hideExploreTab"},
        @{@"key": @"hideLibraryTab"},
        @{@"key": @"hideDownloadsTab"},
    ];

    NSDictionary *data = settingsData[sender.tag];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [YTMUltimateDict setObject:@([sender isOn]) forKey:data[@"key"]];
    [defaults setObject:YTMUltimateDict forKey:@"YTMUltimate"];
}

@end