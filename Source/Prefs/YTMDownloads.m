#import "YTMDownloads.h"

@implementation YTMDownloads

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0];
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];

    [self maybeShowEmptyState];
    [self refreshAudioFiles];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadDataNotification" object:nil];
}

- (void)maybeShowEmptyState {
    if (self.audioFiles.count == 0) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yt_outline_audio_48pt" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView addSubview:self.imageView];

        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.text = LOC(@"EMPTY");
        self.label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        self.label.numberOfLines = 0;
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.label sizeToFit];
        [self.tableView addSubview:self.label];

        [NSLayoutConstraint activateConstraints:@[
            [self.imageView.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor],
            [self.imageView.bottomAnchor constraintEqualToAnchor:self.tableView.centerYAnchor constant:-30],
            [self.imageView.widthAnchor constraintEqualToConstant:48],
            [self.imageView.heightAnchor constraintEqualToConstant:48],

            [self.label.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor],
            [self.label.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:20],
            [self.label.leadingAnchor constraintEqualToAnchor:self.tableView.leadingAnchor constant:20],
            [self.label.trailingAnchor constraintEqualToAnchor:self.tableView.trailingAnchor constant:-20],
        ]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData {
    [self refreshAudioFiles];
    [self.tableView reloadData];
}

- (void)refreshAudioFiles {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *downloadsURL = [documentsURL URLByAppendingPathComponent:@"YTMusicUltimate"];

    NSError *error;
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadsURL.path error:&error];

    if (error) {
        NSLog(@"Error reading contents of directory: %@", error.localizedDescription);
        return;
    }

    NSPredicate *mp3Predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.mp3'"];
    self.audioFiles = [NSMutableArray arrayWithArray:[allFiles filteredArrayUsingPredicate:mp3Predicate]];

    self.imageView.tintColor = self.audioFiles.count == 0 ? [[UIColor whiteColor] colorWithAlphaComponent:0.8] : [UIColor clearColor];
    self.label.textColor = self.audioFiles.count == 0 ? [[UIColor whiteColor] colorWithAlphaComponent:0.8] : [UIColor clearColor];
}

#pragma mark - Table view stuff
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"\n\n" : nil; //Temporary, see YTMTab.x
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return section == 1 ? @"\n\n\n" : nil; //Temporary, see YTMTab.x
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && self.audioFiles.count == 0) {
        return 0;
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.audioFiles.count;
    }

    if (section == 1) {
        return 2;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    if (indexPath.section == 0 && indexPath.row < self.audioFiles.count) {
        cell.textLabel.text = [self.audioFiles[indexPath.row] stringByDeletingPathExtension];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25];

        NSString *imageName = [NSString stringWithFormat:@"%@.png", [self.audioFiles[indexPath.row] stringByDeletingPathExtension]];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        UIImage *image = [UIImage imageWithContentsOfFile:[[documentsDirectory stringByAppendingPathComponent:@"YTMusicUltimate"] stringByAppendingPathComponent:imageName]];
        CGFloat targetSize = 37.5;
        CGFloat scaleFactor = targetSize / MAX(image.size.width, image.size.height);
        CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
        UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height) cornerRadius:6] addClip];
        [image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
        UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        roundedImage = [roundedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.imageView.image = roundedImage;
    }

    else if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell0"];
        NSArray *settingsData = @[
            @{@"title": LOC(@"SHARE_ALL"), @"icon": @"square.and.arrow.up.on.square"},
            @{@"title": LOC(@"REMOVE_ALL"), @"icon": @"trash"},
        ];

        NSDictionary *data = settingsData[indexPath.row];

        cell.textLabel.text = data[@"title"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.imageView.image = [UIImage systemImageNamed:data[@"icon"]];
        cell.imageView.tintColor = indexPath.row == 1 ? [UIColor redColor] : [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
        cell.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25];
    }

    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIContextualAction *shareAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self showActivityViewControllerForIndexPath:indexPath];
            completionHandler(YES);
        }];
        shareAction.image = [UIImage systemImageNamed:@"square.and.arrow.up"];
        shareAction.backgroundColor = [UIColor systemBlueColor];

        UIContextualAction *renameAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self renameFileForIndexPath:indexPath];
            completionHandler(YES);
        }];
        renameAction.image = [UIImage systemImageNamed:@"pencil"];
        renameAction.backgroundColor = [UIColor systemOrangeColor];

        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self deleteFileForIndexPath:indexPath];
            completionHandler(YES);
        }];
        deleteAction.image = [UIImage systemImageNamed:@"trash"];

        UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, renameAction, shareAction]];
        configuration.performsFirstActionWithFullSwipe = YES;

        return configuration;
    } else {
        return nil;
    }
}

- (void)showActivityViewControllerForIndexPath:(NSIndexPath *)indexPath {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *audioURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@", self.audioFiles[indexPath.row]]];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[audioURL] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];

    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)renameFileForIndexPath:(NSIndexPath *)indexPath {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *audioURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@", self.audioFiles[indexPath.row]]];
    NSURL *coverURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@.png", [self.audioFiles[indexPath.row] stringByDeletingPathExtension]]];

    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
    textView.layer.cornerRadius = 3.0;
    textView.layer.borderWidth = 1.0;
    textView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    textView.textColor = [UIColor whiteColor];
    textView.text = [self.audioFiles[indexPath.row] stringByDeletingPathExtension];
    textView.editable = YES;
    textView.scrollEnabled = YES;
    textView.textAlignment = NSTextAlignmentNatural;
    textView.font = [UIFont systemFontOfSize:14.0];

    YTAlertView *alertView = [NSClassFromString(@"YTAlertView") confirmationDialogWithAction:^{
        NSString *newName = [textView.text stringByReplacingOccurrencesOfString:@"/" withString:@""];

        NSURL *newAudioURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@.mp3", newName]];
        NSURL *newCoverURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@.png", newName]];

        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtURL:audioURL toURL:newAudioURL error:&error];
        [[NSFileManager defaultManager] moveItemAtURL:coverURL toURL:newCoverURL error:&error];

        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                [[NSClassFromString(@"YTMToastController") alloc] showMessage:LOC(@"DONE")];
            });
        }
    }
    actionTitle:LOC(@"RENAME")];
    alertView.title = @"YTMusicUltimate";

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertView.frameForDialog.size.width - 50, 75)];
    textView.frame = customView.frame;
    [customView addSubview:textView];

    alertView.customContentView = customView;
    [alertView show];
}

- (void)deleteFileForIndexPath:(NSIndexPath *)indexPath {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *audioURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@", self.audioFiles[indexPath.row]]];
    NSURL *coverURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@.png", [self.audioFiles[indexPath.row] stringByDeletingPathExtension]]];

    YTAlertView *alertView = [NSClassFromString(@"YTAlertView") confirmationDialogWithAction:^{
        BOOL audioRemoved = [[NSFileManager defaultManager] removeItemAtURL:audioURL error:nil];
        BOOL coverRemoved = [[NSFileManager defaultManager] removeItemAtURL:coverURL error:nil];

        if (audioRemoved && coverRemoved) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.audioFiles removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self maybeShowEmptyState];
            });
        }
    }
    actionTitle:LOC(@"DELETE")];
    alertView.title = @"YTMusicUltimate";
    alertView.subtitle = [NSString stringWithFormat:LOC(@"DELETE_MESSAGE"), [self.audioFiles[indexPath.row] stringByDeletingPathExtension]];
    [alertView show];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Playing song can conflict with YTMusicPlayer
    if (indexPath.section == 0) {
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *audioURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@", self.audioFiles[indexPath.row]]];
        NSString *imageName = [NSString stringWithFormat:@"%@.png", [self.audioFiles[indexPath.row] stringByDeletingPathExtension]];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        NSString *authorTitleString = [self.audioFiles[indexPath.row] stringByDeletingPathExtension];
        // NSArray *components = [authorTitleString componentsSeparatedByString:@" - "];

        AVAudioSession *audioSession = [AVAudioSession sharedInstance];

        NSError *setCategoryError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];

        if (!success) {
            NSLog(@"Error setting AVAudioSession category: %@", setCategoryError.localizedDescription);
        }

        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];

        if (!success) {
            NSLog(@"Error activating AVAudioSession: %@", activationError.localizedDescription);
        }

        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:audioURL];
        AVMutableMetadataItem *titleMetadataItem = [AVMutableMetadataItem metadataItem];
        titleMetadataItem.key = AVMetadataCommonKeyTitle;
        titleMetadataItem.keySpace = AVMetadataKeySpaceCommon;
        titleMetadataItem.value = authorTitleString;

        // AVMutableMetadataItem *authorMetadataItem = [AVMutableMetadataItem metadataItem];
        // authorMetadataItem.key = AVMetadataCommonKeyAlbumName; // It doesn't works
        // authorMetadataItem.keySpace = AVMetadataKeySpaceCommon;
        // authorMetadataItem.value = components[0];

        AVMutableMetadataItem *artworkMetadataItem = [AVMutableMetadataItem metadataItem];
        artworkMetadataItem.key = AVMetadataCommonKeyArtwork;
        artworkMetadataItem.keySpace = AVMetadataKeySpaceCommon;
        UIImage *artworkImage = [UIImage imageWithContentsOfFile:[[documentsDirectory stringByAppendingPathComponent:@"YTMusicUltimate"] stringByAppendingPathComponent:imageName]];
        artworkMetadataItem.value = UIImagePNGRepresentation(artworkImage);

        playerItem.externalMetadata = @[titleMetadataItem, artworkMetadataItem];

        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        playerViewController.player = player;

        [self presentViewController:playerViewController animated:YES completion:^{
            [player play];
        }];
    }

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self shareAll];
        }

        if (indexPath.row == 1) {
            [self removeAll];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)shareAll {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *audiosFolder = [documentsURL URLByAppendingPathComponent:@"YTMusicUltimate"];

    NSArray<NSURL *> *mp3Files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:audiosFolder
                                                               includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:nil];

    NSPredicate *mp3Predicate = [NSPredicate predicateWithFormat:@"pathExtension.lowercaseString == 'mp3'"];
    mp3Files = [mp3Files filteredArrayUsingPredicate:mp3Predicate];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:mp3Files applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];

    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)removeAll {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *audiosFolder = [documentsURL URLByAppendingPathComponent:@"YTMusicUltimate"];

    YTAlertView *alertView = [NSClassFromString(@"YTAlertView") confirmationDialogWithAction:^{
        BOOL audiosRemoved = [[NSFileManager defaultManager] removeItemAtURL:audiosFolder error:nil];

        if (audiosRemoved) {
            [self.audioFiles removeAllObjects];
            self.imageView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
            self.label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
    actionTitle:LOC(@"DELETE")];
    alertView.title = @"YTMusicUltimate";
    alertView.subtitle = [NSString stringWithFormat:LOC(@"DELETE_MESSAGE"), LOC(@"ALL_DOWNLOADS")];
    [alertView show];
}

@end
