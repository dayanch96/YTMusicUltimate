#import "Headers/YTMBrowseViewController.h"
#import "Headers/YTPivotBarView.h"
#import "Headers/YTIPivotBarSupportedRenderers.h"
#import "Headers/YTAssetLoader.h"
#import "Prefs/YTMDownloads.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

%hook YTMPivotBarItemStyle
- (UIImage *)pivotBarItemIconImageWithIconType:(int)type color:(UIColor *)color useNewIcons:(BOOL)isNew selected:(BOOL)isSelected {

    // Create image
    NSString *imageName = isSelected ? @"icons/downloads_selected" : @"icons/downloads";

    YTAssetLoader *al = [[%c(YTAssetLoader) alloc] initWithBundle:NSBundle.ytmu_defaultBundle];

    // Set our image if icon type is 1
    return type == 1 ? [al imageNamed:imageName] : %orig;
}
%end

// https://gist.github.com/BandarHL/dce564ab717bed93d479fe849d654c75
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    YTIBrowseEndpoint *endPoint = [[%c(YTIBrowseEndpoint) alloc] init];
    [endPoint setBrowseId:@"BHdownloadsVC"];
    YTICommand *command = [[%c(YTICommand) alloc] init];
    [command setBrowseEndpoint:endPoint];

    YTIPivotBarItemRenderer *itemBar = [[%c(YTIPivotBarItemRenderer) alloc] init];
    [itemBar setPivotIdentifier:@"BHdownloadsVC"];
    YTIIcon *icon = [itemBar icon];
    [icon setIconType:1];
    [itemBar setNavigationEndpoint:command];

    YTIFormattedString *formatString = [%c(YTIFormattedString) formattedStringWithString:LOC(@"DOWNLOADS")];
    [itemBar setTitle:formatString];

    YTIPivotBarSupportedRenderers *barSupport = [[%c(YTIPivotBarSupportedRenderers) alloc] init];
    [barSupport setPivotBarItemRenderer:itemBar];

    if (YTMU(@"YTMUltimateIsEnabled") && !YTMU(@"hideDownloadsTab")) [renderer.itemsArray addObject:barSupport];

    %orig(renderer);
}
%end

%hook YTMBrowseViewController
- (void)viewDidLoad {
    %orig;

    @try {
        YTICommand *navEndpoint = [self valueForKey:@"_navEndpoint"];
        if ([navEndpoint.browseEndpoint.browseId isEqualToString:@"BHdownloadsVC"]) {
            UIViewController *downloadPageController = [[YTMDownloads alloc] init];
            [self addChildViewController:downloadPageController];
            // FIXME: View issues
            [downloadPageController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
            [self.view addSubview:downloadPageController.view];
            [self.view endEditing:YES];
            [downloadPageController didMoveToParentViewController:self];
        }
    } @catch (NSException *exception) {
        NSLog(@"Cannot show downloads vc, why? %@", exception.reason);
    }
}
%end