#import "YTMUltimatePrefs.h"
#import "YTMUltimateSettingsController.h"

const NSString *version = @"1.2.8";

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
extern NSBundle *YTMusicUltimateBundle();

@implementation YTMUltimateSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [self closeButton];

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
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *tweakBundle = YTMusicUltimateBundle();

    switch (section) {
        case 0:
            return LOC(@"Settings");
        case 1:
            return LOC(@"Links");
        default:
            return @"Section";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return [NSString stringWithFormat:@"YTMusicUltimate %@\n\n© Ginsu (@ginsudev) 2021-2023", version];
    }

    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [self.options count] + 1;
        case 1:
            return [self.links count];
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == self.options.count) {
            cell.textLabel.text = LOC(@"Apply");
            cell.detailTextLabel.text = LOC(@"Closes_the_app_to_apply_changes");
            cell.textLabel.textColor = [UIColor systemBlueColor];
            cell.detailTextLabel.textColor = [UIColor systemBlueColor];
        } else {
            NSMutableDictionary *cellMetadata = [self.options objectAtIndex:indexPath.row];
            cell.textLabel.text = [cellMetadata objectForKey:@"title"];
            cell.detailTextLabel.text = [cellMetadata objectForKey:@"subtitle"];
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchView.tag = indexPath.row;
            [cell setAccessoryView:switchView];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:[cellMetadata objectForKey:@"defaultsKey"]] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
    } else if (indexPath.section == 1) {
        NSMutableDictionary *cellMetadata = [self.links objectAtIndex:indexPath.row];
        cell.textLabel.text = [cellMetadata objectForKey:@"title"];
        cell.detailTextLabel.text = [cellMetadata objectForKey:@"subtitle"];
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.detailTextLabel.textColor = [UIColor systemBlueColor];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == self.options.count) {
        @throw NSInternalInconsistencyException;
    } else if (indexPath.section == 1) {
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
        item = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
                            style:UIBarButtonItemStylePlain 
                            target:self 
                            action:@selector(close)];
    }

    return item;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
