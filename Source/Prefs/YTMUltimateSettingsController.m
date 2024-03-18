#import "YTMUltimateSettingsController.h"
#import "Localization.h"

@implementation YTMUltimateSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonTapped:)]; 

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checkmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(applyButtonTapped:)]; 

    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = applyButton;

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

    //Init isEnabled for first time
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
    if (!YTMUltimateDict[@"YTMUltimateIsEnabled"]) {
        [YTMUltimateDict setObject:@(1) forKey:@"YTMUltimateIsEnabled"];
        [[NSUserDefaults standardUserDefaults] setObject:YTMUltimateDict forKey:@"YTMUltimate"];
    }

}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 3 ? LOC(@"LINKS") : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return LOC(@"RESTART_FOOTER");
    } if (section == 3) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
        return [NSString stringWithFormat:@"\nYouTubeMusic: v%@\nYTMusicUltimate: v%@\n\n© Ginsu (@ginsudev) 2021-2024", appVersion, @(OS_STRINGIFY(TWEAK_VERSION))];
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (section == 3) {
        UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
        footer.textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 5;
        case 2:
            return 1;
        case 3:
            return 4;
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    } else {
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
    }

    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell0"];
        cell.textLabel.text = LOC(@"ENABLED");
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        cell.imageView.image = [UIImage systemImageNamed:@"power"];
        cell.imageView.tintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];

        UISwitch *masterSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        masterSwitch.onTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        [masterSwitch addTarget:self action:@selector(toggleMasterSwitch:) forControlEvents:UIControlEventValueChanged];
        masterSwitch.on = [YTMUltimateDict[@"YTMUltimateIsEnabled"] boolValue];
        cell.accessoryView = masterSwitch;
    } else if (indexPath.section == 1) {
        NSArray *sectionTitles = @[LOC(@"PREMIUM_SETTINGS"), LOC(@"PLAYER_SETTINGS"), LOC(@"THEME_SETTINGS"), LOC(@"NAVBAR_SETTINGS"), LOC(@"TABBAR_SETTINGS")];
        NSArray *sectionImages = @[@"flame", @"play.rectangle", @"paintbrush", @"sidebar.trailing", @"dock.rectangle"];
        
        if (indexPath.row >= 0 && indexPath.row < sectionTitles.count) {
            cell.textLabel.text = sectionTitles[indexPath.row];
            cell.detailTextLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString *imageName = sectionImages[indexPath.row];
            cell.imageView.image = [UIImage systemImageNamed:imageName];
        }
    } else if (indexPath.section == 2) {
        cell.textLabel.text = LOC(@"CLEAR_CACHE");

        UILabel *cache = [[UILabel alloc] init];
        cache.text = [self getCacheSize];
        cache.textColor = [UIColor secondaryLabelColor];
        cache.font = [UIFont systemFontOfSize:16];
        cache.textAlignment = NSTextAlignmentRight;
        [cache sizeToFit];

        // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //     NSString *cacheSize = [self getCacheSize];

        //     dispatch_async(dispatch_get_main_queue(), ^{
        //         cache.text = cacheSize;
                
        //     });
        // });

        cell.accessoryView = cache;
        cell.imageView.image = [UIImage systemImageNamed:@"trash"];
        cell.imageView.tintColor = [UIColor redColor];
    } else if (indexPath.section == 3) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell3"];
        
        NSArray *settingsData = @[
            @{@"text": [NSString stringWithFormat:LOC(@"TWITTER"), @"Ginsu"],  @"detail": LOC(@"TWITTER_DESC"), @"image": @"ginsu-24@2x"},
            @{@"text": [NSString stringWithFormat:LOC(@"TWITTER"), @"Dayanch96"], @"detail": LOC(@"TWITTER_DESC"), @"image": @"dayanch96-24@2x"},
            @{@"text": LOC(@"DISCORD"), @"detail": LOC(@"DISCORD_DESC"), @"image": @"discord-24@2x"},
            @{@"text": LOC(@"SOURCE_CODE"), @"detail": LOC(@"SOURCE_CODE_DESC"), @"image": @"github-24@2x"}
        ];

        NSDictionary *settingData = settingsData[indexPath.row];

        cell.textLabel.text = settingData[@"text"];
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = settingData[@"detail"];
        cell.detailTextLabel.numberOfLines = 0;

        NSString *imageName = settingData[@"image"];
        UIImage *image = [UIImage imageWithContentsOfFile:[YTMusicUltimateBundle() pathForResource:imageName ofType:@"png" inDirectory:@"icons"]];
        cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    } return cell;
}

- (NSString *)getCacheSize {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];

    unsigned long long int folderSize = 0;
    for (NSString *fileName in filesArray) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [fileAttributes fileSize];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;

    return [formatter stringFromByteCount:folderSize];
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? NO : YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSArray *controllers = @[[PremiumSettingsController class],
                                 [PlayerSettingsController class],
                                 [ThemeSettingsController class],
                                 [NavBarSettingsController class],
                                 [OtherSettingsController class]];

        if (indexPath.row >= 0 && indexPath.row < controllers.count) {
            UIViewController *controller = [[controllers[indexPath.row] alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }

    if (indexPath.section == 2 && indexPath.row == 0) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        activityIndicator.color = [UIColor labelColor];
        [activityIndicator startAnimating];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = activityIndicator;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }

    if (indexPath.section == 3) {
        NSArray *urls = @[@"https://twitter.com/ginsudev",
                        @"https://twitter.com/dayanch96",
                        @"https://discord.com/invite/BhdUyCbgkZ",
                        @"https://github.com/ginsudev/YTMusicUltimate"];

        if (indexPath.row >= 0 && indexPath.row < urls.count) {
            NSURL *url = [NSURL URLWithString:urls[indexPath.row]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Nav bar stuff
- (NSString *)title {
    return @"YTMusicUltimate";
}

- (void)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyButtonTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"WARNING") message:LOC(@"APPLY_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"YES") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:1.0];
            exit(0);
        });
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleMasterSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *twitchDvnDict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"YTMUltimate"]];

    [twitchDvnDict setObject:@([sender isOn]) forKey:@"YTMUltimateIsEnabled"];
    [defaults setObject:twitchDvnDict forKey:@"YTMUltimate"];
}

@end
