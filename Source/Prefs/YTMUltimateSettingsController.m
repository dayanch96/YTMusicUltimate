#import "YTMUltimatePrefs.h"
#import "YTMUltimateSettingsController.h"
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import <rootless.h>

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
extern NSBundle *YTMusicUltimateBundle();

static NSString *GinsuPath;
static NSString *Dayanch96Path;
static NSString *DiscordPath;
static NSString *GithubPath;

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
    [self.view addSubview:_tableView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

    _options = [[[YTMUltimatePrefs alloc] init] settings];
    _links = [[[YTMUltimatePrefs alloc] init] links];
}

#pragma mark - Table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *tweakBundle = YTMusicUltimateBundle();

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
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    if (section == 0) {
        return LOC(@"RESTART_FOOTER");
    } if (section == 2) {
        return [NSString stringWithFormat:@"YTMusicUltimate %@\n\n© Ginsu (@ginsudev) 2021-2023", @(OS_STRINGIFY(TWEAK_VERSION))];
    }

    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [self.options count];
        case 1:
            return 4;
        case 2:
            return [self.links count];
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSBundle *tweakBundle = YTMusicUltimateBundle();

    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        NSMutableDictionary *cellMetadata = [self.options objectAtIndex:indexPath.row];
        cell.textLabel.text = [cellMetadata objectForKey:@"title"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        if (@available(iOS 13, *)) {
            cell.textLabel.textColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
            cell.imageView.image = [UIImage systemImageNamed:@"power"];
            cell.imageView.tintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0];
        } else {
            cell.textLabel.textColor = [UIColor systemRedColor];
        }
            
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.tag = indexPath.row;
        [cell setAccessoryView:switchView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:[cellMetadata objectForKey:@"defaultsKey"]] animated:NO];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    } if (indexPath.section == 1) {
        if (indexPath.row == 0) {
        cell.textLabel.text = LOC(@"PREMIUM_SETTINGS");
        cell.detailTextLabel.numberOfLines = 0;

        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage systemImageNamed:@"flame"];
        } else {
            cell.imageView.image = nil;
        }

        } else if (indexPath.row == 1) {
        cell.textLabel.text = LOC(@"PLAYER_SETTINGS");
        cell.detailTextLabel.numberOfLines = 0;

        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage systemImageNamed:@"ipad.landscape.badge.play"];
        } else {
            cell.imageView.image = nil;
        }

        } else if (indexPath.row == 2) {
        cell.textLabel.text = LOC(@"THEME_SETTINGS");
        cell.detailTextLabel.numberOfLines = 0;

        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage systemImageNamed:@"photo.on.rectangle.angled"];
        } else {
            cell.imageView.image = nil;
        }

        } else if (indexPath.row == 3) {
        cell.textLabel.text = LOC(@"NAVBAR_SETTINGS");
        cell.detailTextLabel.numberOfLines = 0;

        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage systemImageNamed:@"sidebar.trailing"];
        } else {
            cell.imageView.image = nil;
        }

        }
    } if (indexPath.section == 2) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell2"];

    NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
    if (tweakBundlePath) {
        NSBundle *tweakBundle = [NSBundle bundleWithPath:tweakBundlePath];
        GinsuPath = [tweakBundle pathForResource:@"ginsu-24@2x" ofType:@"png"];
        Dayanch96Path = [tweakBundle pathForResource:@"dayanch96-24@2x" ofType:@"png"];
        DiscordPath = [tweakBundle pathForResource:@"discord-24@2x" ofType:@"png"];
        GithubPath = [tweakBundle pathForResource:@"github-24@2x" ofType:@"png"];
    } else {
        GinsuPath = ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle/ginsu-24@2x.png");
        Dayanch96Path = ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle/dayanch96-24@2x.png");
        DiscordPath = ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle/discord-24@2x.png");
        GithubPath = ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle/github-24@2x.png");
    }

    NSMutableDictionary *cellMetadata = [self.links objectAtIndex:indexPath.row];
    cell.textLabel.text = [cellMetadata objectForKey:@"title"];
    cell.detailTextLabel.text = [cellMetadata objectForKey:@"subtitle"];
    cell.textLabel.textColor = [UIColor systemBlueColor];

    if (indexPath.row == 0) {
        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:GinsuPath];
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        }
    } else if (indexPath.row == 1) {
        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:Dayanch96Path];
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        }
    } else if (indexPath.row == 2) {
        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:DiscordPath];
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        }
    } else if (indexPath.row == 3) {
        if (@available(iOS 13, *)) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:GithubPath];
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        }
    }
}
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
        PremiumSettingsController *premiumSettingsController = [[PremiumSettingsController alloc] init];
        [self.navigationController pushViewController:premiumSettingsController animated:YES];        
        } else if (indexPath.row == 1) {
        PlayerSettingsController *playerSettingsController = [[PlayerSettingsController alloc] init];
        [self.navigationController pushViewController:playerSettingsController animated:YES];
        } else if (indexPath.row == 2) {
        ThemeSettingsController *themeSettingsController = [[ThemeSettingsController alloc] init];
        [self.navigationController pushViewController:themeSettingsController animated:YES];
        } else if (indexPath.row == 3) {
        NavBarSettingsController *navBarSettingsController = [[NavBarSettingsController alloc] init];
        [self.navigationController pushViewController:navBarSettingsController animated:YES];
        }
    } else if (indexPath.section == 2) {
        NSMutableDictionary *cellMetadata = [self.links objectAtIndex:indexPath.row];
        NSString *url = [cellMetadata objectForKey:@"url"];

        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:url]
            options:@{}
            completionHandler:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchChanged:(UISwitch *)sender{
    NSMutableDictionary *cellMetadata = [self.options objectAtIndex:sender.tag];
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:[cellMetadata objectForKey:@"defaultsKey"]];
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
        NSBundle *tweakBundle = YTMusicUltimateBundle();
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
        NSBundle *tweakBundle = YTMusicUltimateBundle();
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
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"WARNING") message:LOC(@"APPLY_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"YES") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        exit(0);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
