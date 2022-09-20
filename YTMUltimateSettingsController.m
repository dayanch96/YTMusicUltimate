#import "YTMUltimatePrefs.h"
#import "YTMUltimateSettingsController.h"

@implementation YTMUltimateSettingsController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];
    //x
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //y
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    //w
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    //h
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 120)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.textColor = [UIColor redColor];
    headerLabel.text = @"YTMusicUltimate";
    headerLabel.font = [UIFont boldSystemFontOfSize:38];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:headerLabel];
    //x
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //y
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeTop multiplier:1 constant:45]];

    _options = [[[YTMUltimatePrefs alloc] init] settings];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"YTMusicUltimate v1.1.10\n\n© Ginsu 2022";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2 + [self.options count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.row >= self.options.count) {
        if (indexPath.row == self.options.count) {
            cell.textLabel.text = @"Apply";
            cell.detailTextLabel.text = @"Closes the app to apply changes";
        } else {
            cell.textLabel.text = @"Follow me on Twitter";
            cell.detailTextLabel.text = @"Follow me for updates";
        }

        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.detailTextLabel.textColor = [UIColor systemBlueColor];
    } else {
        NSMutableDictionary *cellMetadata = [self.options objectAtIndex:indexPath.row];

        cell.textLabel.text = [cellMetadata objectForKey:@"title"];
        cell.detailTextLabel.text = [cellMetadata objectForKey:@"subtitle"];

        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        switchView.tag = indexPath.row;

        [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:[cellMetadata objectForKey:@"defaultsKey"]] animated:NO];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.options.count){
        @throw NSInternalInconsistencyException;
    } else if (indexPath.row == self.options.count + 1){
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:@"https://twitter.com/ginsudev"]
            options:@{}
            completionHandler:nil];
    }
}

- (void)switchChanged:(UISwitch *)sender{
    NSMutableDictionary *cellMetadata = [self.options objectAtIndex:sender.tag];
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:[cellMetadata objectForKey:@"defaultsKey"]];
}

@end
