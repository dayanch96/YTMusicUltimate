#import "DiscordSettingsController.h"
#import "../Discord/YTMUDiscordDefaults.h"
#import "../Discord/YTMUDiscordRPC.h"

typedef NS_ENUM(NSInteger, DiscordSettingsSection) {
    DiscordSettingsSectionEnable = 0,
    DiscordSettingsSectionAccount,
    DiscordSettingsSectionApplication,
    DiscordSettingsSectionAppearance,
    DiscordSettingsSectionPaused,
    DiscordSettingsSectionText,
    DiscordSettingsSectionCount
};

// Tags let one -textFieldDidEndEditing: serve every text field on the page.
typedef NS_ENUM(NSInteger, DiscordSettingsField) {
    DiscordSettingsFieldAppID = 100,
    DiscordSettingsFieldActivityName,
    DiscordSettingsFieldDetails,
    DiscordSettingsFieldState
};

@implementation DiscordSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = LOC(@"DISCORD_RPC_SETTINGS");
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discordStateDidChange)
                                                 name:YTMUDiscordStateDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)discordStateDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view stuff

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DiscordSettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case DiscordSettingsSectionAccount: return 2;
        case DiscordSettingsSectionAppearance: return 5;
        case DiscordSettingsSectionText: return 2;
        default: return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case DiscordSettingsSectionAccount: return LOC(@"DISCORD_RPC_ACCOUNT");
        case DiscordSettingsSectionApplication: return LOC(@"DISCORD_RPC_APPLICATION");
        case DiscordSettingsSectionAppearance: return LOC(@"DISCORD_RPC_APPEARANCE");
        case DiscordSettingsSectionText: return LOC(@"DISCORD_RPC_TEXT");
        default: return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == DiscordSettingsSectionApplication) {
        return [NSString stringWithFormat:LOC(@"DISCORD_RPC_APPLICATION_FOOTER"), YTMUDiscordCallbackURL];
    }

    if (section == DiscordSettingsSectionText) {
        return LOC(@"DISCORD_RPC_TEXT_FOOTER");
    }

    if (section == DiscordSettingsSectionAccount) {
        NSString *error = YTMUDiscordRPC.sharedInstance.lastErrorMessage;
        return error.length > 0 ? error : nil;
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    if (indexPath.section == DiscordSettingsSectionEnable) {
        cell.textLabel.text = LOC(@"DISCORD_RPC");
        cell.detailTextLabel.text = LOC(@"DISCORD_RPC_DESC");
        cell.accessoryView = [self switchForKey:YTMUDiscordPrefEnabled action:@selector(toggleEnabled:)];

        return cell;
    }

    if (indexPath.section == DiscordSettingsSectionAccount) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LOC(@"DISCORD_RPC_STATUS");

            UILabel *status = [[UILabel alloc] init];
            status.text = [self statusText];
            status.textColor = [UIColor secondaryLabelColor];
            status.font = [UIFont systemFontOfSize:16];
            status.textAlignment = NSTextAlignmentRight;
            [status sizeToFit];
            cell.accessoryView = status;

            return cell;
        }

        BOOL signedIn = YTMUDiscordRPC.sharedInstance.hasStoredCredentials;
        cell.textLabel.text = signedIn ? LOC(@"DISCORD_RPC_DISCONNECT") : LOC(@"DISCORD_RPC_CONNECT");
        cell.textLabel.textColor = signedIn ? [UIColor systemRedColor] : [UIColor systemBlueColor];

        return cell;
    }

    if (indexPath.section == DiscordSettingsSectionApplication) {
        cell.textLabel.text = LOC(@"DISCORD_RPC_APP_ID");
        // Left empty the built-in application is used, so show that as the
        // placeholder rather than a made-up number.
        cell.accessoryView = [self textFieldWithTag:DiscordSettingsFieldAppID
                                               text:YTMUDiscordPrefString(YTMUDiscordPrefAppID)
                                        placeholder:YTMUDiscordApplicationID()
                                       numericInput:YES];

        return cell;
    }

    if (indexPath.section == DiscordSettingsSectionAppearance) {
        switch (indexPath.row) {
            case 0: {
                // Four segments need the full row, so the label is dropped and
                // the section header carries the meaning.
                UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[
                    LOC(@"DISCORD_RPC_LISTENING"),
                    LOC(@"DISCORD_RPC_PLAYING"),
                    LOC(@"DISCORD_RPC_WATCHING"),
                    LOC(@"DISCORD_RPC_COMPETING")
                ]];
                control.selectedSegmentIndex = YTMUDiscordPrefInteger(YTMUDiscordPrefActivityType);
                [control addTarget:self action:@selector(activityTypeChanged:) forControlEvents:UIControlEventValueChanged];

                [cell.contentView addSubview:control];
                control.translatesAutoresizingMaskIntoConstraints = NO;
                [control.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = YES;
                [control.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:5.0].active = YES;
                [control.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-5.0].active = YES;

                return cell;
            }

            case 1:
                cell.textLabel.text = LOC(@"DISCORD_RPC_ACTIVITY_NAME");
                cell.accessoryView = [self textFieldWithTag:DiscordSettingsFieldActivityName
                                                       text:YTMUDiscordPrefString(YTMUDiscordPrefActivityName)
                                                placeholder:@"YouTube Music"
                                               numericInput:NO];
                return cell;

            case 2:
                cell.textLabel.text = LOC(@"DISCORD_RPC_ARTWORK");
                cell.accessoryView = [self switchForKey:YTMUDiscordPrefShowArtwork action:@selector(toggleArtwork:)];
                return cell;

            case 3:
                cell.textLabel.text = LOC(@"DISCORD_RPC_TIMESTAMPS");
                cell.accessoryView = [self switchForKey:YTMUDiscordPrefShowTimestamps action:@selector(toggleTimestamps:)];
                return cell;

            default:
                cell.textLabel.text = LOC(@"DISCORD_RPC_BUTTONS");
                cell.accessoryView = [self switchForKey:YTMUDiscordPrefShowButtons action:@selector(toggleButtons:)];
                return cell;
        }
    }

    if (indexPath.section == DiscordSettingsSectionPaused) {
        cell.textLabel.text = LOC(@"DISCORD_RPC_PAUSED");

        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[
            LOC(@"DISCORD_RPC_PAUSED_KEEP"),
            LOC(@"DISCORD_RPC_PAUSED_CLEAR")
        ]];
        control.selectedSegmentIndex = YTMUDiscordPrefBool(YTMUDiscordPrefClearWhenPaused) ? 1 : 0;
        [control addTarget:self action:@selector(pausedBehaviorChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = control;

        return cell;
    }

    if (indexPath.section == DiscordSettingsSectionText) {
        BOOL isDetails = indexPath.row == 0;
        cell.textLabel.text = isDetails ? LOC(@"DISCORD_RPC_DETAILS") : LOC(@"DISCORD_RPC_STATE");
        cell.accessoryView = [self textFieldWithTag:(isDetails ? DiscordSettingsFieldDetails : DiscordSettingsFieldState)
                                               text:YTMUDiscordPrefString(isDetails ? YTMUDiscordPrefDetailsTemplate : YTMUDiscordPrefStateTemplate)
                                        placeholder:(isDetails ? @"{song.name}" : @"{artist.name}")
                                       numericInput:NO];

        return cell;
    }

    return cell;
}

#pragma mark - Cell helpers

- (ABCSwitch *)switchForKey:(NSString *)key action:(SEL)action {
    ABCSwitch *control = [[NSClassFromString(@"ABCSwitch") alloc] init];
    control.onTintColor = [UIColor colorWithRed:30.0 / 255.0 green:150.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    control.on = YTMUDiscordPrefBool(key);
    [control addTarget:self action:action forControlEvents:UIControlEventValueChanged];

    return control;
}

- (UITextField *)textFieldWithTag:(NSInteger)tag
                             text:(NSString *)text
                      placeholder:(NSString *)placeholder
                     numericInput:(BOOL)numericInput {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 32)];
    textField.text = text;
    textField.placeholder = placeholder;
    textField.font = [UIFont systemFontOfSize:13.0];
    textField.textAlignment = NSTextAlignmentRight;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = numericInput ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.inputAccessoryView = [self keyboardToolbar];
    textField.delegate = self;
    textField.tag = tag;

    return textField;
}

- (UIView *)keyboardToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
    [toolbar setItems:@[flexibleSpace, done]];

    return toolbar;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (NSString *)statusText {
    switch (YTMUDiscordRPC.sharedInstance.connectionState) {
        case YTMUDiscordConnectionStateConnected: {
            NSString *username = YTMUDiscordRPC.sharedInstance.username;
            return username.length > 0 ? username : LOC(@"DISCORD_RPC_STATUS_CONNECTED");
        }
        case YTMUDiscordConnectionStateConnecting:
            return LOC(@"DISCORD_RPC_STATUS_CONNECTING");
        default:
            return LOC(@"DISCORD_RPC_STATUS_DISCONNECTED");
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == DiscordSettingsSectionAccount && indexPath.row == 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section != DiscordSettingsSectionAccount || indexPath.row != 1) return;

    if (YTMUDiscordRPC.sharedInstance.hasStoredCredentials) {
        [YTMUDiscordRPC.sharedInstance logout];
        [self.tableView reloadData];
        return;
    }

    if (YTMUDiscordApplicationID().length == 0) {
        [self showAlertWithMessage:LOC(@"DISCORD_RPC_NO_APP_ID")];
        return;
    }

    [YTMUDiscordRPC.sharedInstance authorizeFromViewController:self completion:^(BOOL success, NSError *error) {
        if (!success && error) {
            [self showAlertWithMessage:error.localizedDescription];
        }
        [self.tableView reloadData];
    }];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"DISCORD_RPC_SETTINGS")
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CLOSE") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (void)toggleEnabled:(UISwitch *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefEnabled, @(sender.isOn));
    [YTMUDiscordRPC.sharedInstance synchronizeConnection];
    [self.tableView reloadData];
}

- (void)toggleArtwork:(UISwitch *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefShowArtwork, @(sender.isOn));
    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

- (void)toggleTimestamps:(UISwitch *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefShowTimestamps, @(sender.isOn));
    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

- (void)toggleButtons:(UISwitch *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefShowButtons, @(sender.isOn));
    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

- (void)activityTypeChanged:(UISegmentedControl *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefActivityType, @(sender.selectedSegmentIndex));
    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

- (void)pausedBehaviorChanged:(UISegmentedControl *)sender {
    YTMUDiscordSetPref(YTMUDiscordPrefClearWhenPaused, @(sender.selectedSegmentIndex == 1));
    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *value = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    switch (textField.tag) {
        case DiscordSettingsFieldAppID:
            YTMUDiscordSetPref(YTMUDiscordPrefAppID, value);
            // A different application means different external assets and a
            // different OAuth client, so the old session is worthless.
            [YTMUDiscordRPC.sharedInstance synchronizeConnection];
            [self.tableView reloadData];
            return;

        case DiscordSettingsFieldActivityName:
            YTMUDiscordSetPref(YTMUDiscordPrefActivityName, value);
            break;

        case DiscordSettingsFieldDetails:
            YTMUDiscordSetPref(YTMUDiscordPrefDetailsTemplate, value);
            break;

        case DiscordSettingsFieldState:
            YTMUDiscordSetPref(YTMUDiscordPrefStateTemplate, value);
            break;

        default:
            return;
    }

    [YTMUDiscordRPC.sharedInstance invalidateCachedPresence];
}

@end
