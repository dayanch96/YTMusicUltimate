#import "FFMpegDownloader.h"

@implementation FFMpegDownloader {

    Statistics *statistics;

}

- (void)statisticsCallback:(Statistics *)newStatistics {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->statistics = newStatistics;
        [self updateProgressDialog];
    });
}

- (void)downloadAudio:(NSString *)audioURL {
    statistics = nil;
    [MobileFFmpegConfig resetStatistics];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setActive];
    });

    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.label.text = LOC(@"DOWNLOADING");

    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *destinationURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", self.tempName]];
    NSURL *outputURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@.m4a", self.mediaName]];
    NSURL *folderURL = [documentsURL URLByAppendingPathComponent:@"YTMusicUltimate"];
    [[NSFileManager defaultManager] createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];

    [MobileFFmpegConfig setLogDelegate:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int returnCode = [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -c:a aac -b:a 320k %@", audioURL, destinationURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (returnCode == RETURN_CODE_SUCCESS) {
                [self.hud hideAnimated:YES];
                BOOL isMoved = [[NSFileManager defaultManager] moveItemAtURL:destinationURL toURL:outputURL error:nil];

                if (isMoved) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadDataNotification" object:nil];
                    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    self.hud.mode = MBProgressHUDModeCustomView;
                    self.hud.label.text = LOC(@"DONE");
                    self.hud.label.numberOfLines = 0;

                    UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[self imageWithSystemIconNamed:@"checkmark"]];
                    checkmarkImageView.contentMode = UIViewContentModeScaleAspectFit;
                    self.hud.customView = checkmarkImageView;

                    [self.hud hideAnimated:YES afterDelay:3.0];
                }
            } else if (returnCode == RETURN_CODE_CANCEL) {
                [self.hud hideAnimated:YES];

                [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
            } else {
                if (self.hud && self.hud.mode == MBProgressHUDModeAnnularDeterminate) {
                    self.hud.mode = MBProgressHUDModeCustomView;
                    self.hud.label.text = LOC(@"OOPS");
                    self.hud.label.numberOfLines = 0;

                    UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[self imageWithSystemIconNamed:@"xmark"]];
                    checkmarkImageView.contentMode = UIViewContentModeScaleAspectFit;
                    self.hud.customView = checkmarkImageView;

                    [self.hud hideAnimated:YES afterDelay:3.0];
                    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"Command execution failed with rc=%d and output=%@.\n", returnCode, [MobileFFmpegConfig getLastCommandOutput]];
                }

                [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
            }
        });
    });
}

- (void)logCallback:(long)executionId :(int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", message);
    });
}

- (void)setActive {
    [MobileFFmpegConfig setLogDelegate:self];
    [MobileFFmpegConfig setStatisticsDelegate:self];
}

- (void)updateProgressDialog {
    if (statistics == nil) {
        return;
    }

    int timeInMilliseconds = [statistics getTime];
    if (timeInMilliseconds > 0) {
        double totalVideoDuration = self.duration;
        double timeInSeconds = timeInMilliseconds / 1000.0;
        double percentage = timeInSeconds / totalVideoDuration;

        if (self.hud && self.hud.mode == MBProgressHUDModeAnnularDeterminate) {
            self.hud.progress = percentage;
            self.hud.detailsLabel.text = [NSString stringWithFormat:@"%d%%", (int)(percentage * 100)];
            [self.hud.button setTitle:LOC(@"CANCEL") forState:UIControlStateNormal];
            [self.hud.button addTarget:self action:@selector(cancelDownloading:) forControlEvents:UIControlEventTouchUpInside];

            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [cancelButton setTag:998];
            UIImage *cancelImage = [[UIImage systemImageNamed:@"x.circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cancelButton setImage:cancelImage forState:UIControlStateNormal];
            [cancelButton setTintColor:[[UIColor labelColor] colorWithAlphaComponent:0.7]];
            [cancelButton addTarget:self action:@selector(cancelHUD:) forControlEvents:UIControlEventTouchUpInside];

            UIView *buttonSuperview = self.hud.button.superview;
            if (![buttonSuperview viewWithTag:998]) {
                [buttonSuperview addSubview:cancelButton];

                cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[
                    [cancelButton.topAnchor constraintEqualToAnchor:buttonSuperview.topAnchor constant:5.0],
                    [cancelButton.leadingAnchor constraintEqualToAnchor:buttonSuperview.leadingAnchor constant:5.0],
                    [cancelButton.widthAnchor constraintEqualToConstant:17.0],
                    [cancelButton.heightAnchor constraintEqualToConstant:17.0]
                ]];
            }
        }
    }
}

- (void)cancelDownloading:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MobileFFmpeg cancel];
    });
}

- (void)cancelHUD:(UIButton *)sender {
    [self.hud hideAnimated:YES];
}

- (void)downloadImage:(NSURL *)link {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:link];
        UIImage *image = [UIImage imageWithData:imageData];

        if (image) UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.label.text = LOC(@"SAVED_TO_PHOTOS");

        UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[self imageWithSystemIconNamed:@"checkmark"]];
        checkmarkImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.hud.customView = checkmarkImageView;

        [self.hud hideAnimated:YES afterDelay:2.0];
    });
}

- (UIImage *)imageWithSystemIconNamed:(NSString *)iconName {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(36, 36)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        UIImage *iconImage = [UIImage systemImageNamed:iconName];
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.clipsToBounds = YES;
        iconImageView.tintColor = [[UIColor labelColor] colorWithAlphaComponent:0.7f];
        iconImageView.frame = imageView.bounds;

        [imageView addSubview:iconImageView];
        [imageView.layer renderInContext:rendererContext.CGContext];
    }];
    return image;
}

- (void)shareMedia:(NSURL *)mediaURL {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[mediaURL] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];

    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
    }];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
