#import "YTMUltimateSettingsController.h"
#import "Localization.h"

@implementation YTMUltimateSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [self closeButton];
    self.navigationItem.rightBarButtonItem = [self applyButton];

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

    //Init isEnabled for first time
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YTMUltimateIsEnabled"];
    }

}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
        case 1:
            return @"";
        case 2:
            return LOC(@"LINKS");
        default:
            return @"Section";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return LOC(@"RESTART_FOOTER");
    } if (section == 2) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
        return [NSString stringWithFormat:@"\nYouTubeMusic: v%@\nYTMusicUltimate: v%@\n\n© Ginsu (@ginsudev) 2021-2023", appVersion, @(OS_STRINGIFY(TWEAK_VERSION))];
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (section == 2) {
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

    NSBundle *tweakBundle = YTMusicUltimateBundle();

    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell0"];
        cell.textLabel.text = LOC(@"ENABLED");
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        if (@available(iOS 13, *)) {
            cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
            cell.imageView.image = [UIImage systemImageNamed:@"power"];
            cell.imageView.tintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        } else {
            cell.textLabel.textColor = [UIColor systemRedColor];
        }

        UISwitch *masterSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        masterSwitch.onTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        [masterSwitch addTarget:self action:@selector(toggleMasterSwitch:) forControlEvents:UIControlEventValueChanged];
        masterSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"];
        cell.accessoryView = masterSwitch;
    } else if (indexPath.section == 1) {
        NSArray *sectionTitles = @[LOC(@"PREMIUM_SETTINGS"), LOC(@"PLAYER_SETTINGS"), LOC(@"THEME_SETTINGS"), LOC(@"NAVBAR_SETTINGS"), LOC(@"TABBAR_SETTINGS")];
        NSArray *sectionImages = @[@"flame", @"play.rectangle", @"paintbrush", @"sidebar.trailing", @"dock.rectangle"];
        
        if (indexPath.row >= 0 && indexPath.row < sectionTitles.count) {
            cell.textLabel.text = sectionTitles[indexPath.row];
            cell.detailTextLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (@available(iOS 13, *)) {
                NSString *imageName = sectionImages[indexPath.row];
                cell.imageView.image = [UIImage systemImageNamed:imageName];
            } else {
                cell.imageView.image = nil;
            }
        }
    } else if (indexPath.section == 2) {
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
        UIImage *image = [UIImage imageWithContentsOfFile:[tweakBundle pathForResource:imageName ofType:@"png" inDirectory:@"icons"]];

        if (@available(iOS 13, *)) {
            cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
            cell.imageView.image = nil;
        }
    } return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || indexPath.section == 2) {
        return YES;
    } else {
        return NO;
    }
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

    if (indexPath.section == 2) {
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

- (UIBarButtonItem *)closeButton {
    UIBarButtonItem *item;

    if (@available(iOS 13, *)) {
        item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(close)];
    } else {
        item = [[UIBarButtonItem alloc] initWithTitle:LOC(@"CLOSE")
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(close)];
    }

    return item;
}

- (UIBarButtonItem *)applyButton {
    UIBarButtonItem *item;

    if (@available(iOS 13, *)) {
        item = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checkmark"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(apply)];
    } else {
        item = [[UIBarButtonItem alloc] initWithTitle:LOC(@"APPLY")
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(apply)];
    }

    return item;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)apply {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"WARNING") message:LOC(@"APPLY_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"YES") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        exit(0);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end

@implementation YTMUltimateSettingsController (Privates)

- (void)toggleMasterSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"YTMUltimateIsEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
