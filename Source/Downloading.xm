//YTGlobalConfig.h

// #import <UIKit/UIKit.h>

// @interface YTMAutoOfflineController : NSObject
// @end

// @interface YTMTOfflineSettingsViewController: NSObject
// @end

// @interface YTMTOfflineMixtapeSettingsView: NSObject
// @end

// @interface YTMPerformantDownloadStateBadgeView: NSObject
// @end

// @interface YTMOfflinePlaylistSyncWorker: NSObject
// @end

// @interface YTMOfflineControllerWrapper: NSObject
// @end

// @interface YTMMusicContainerDownloadStatusModel: NSObject
// @end

// @interface YTMHintController: NSObject
// @end

// @interface YTMAutoOfflineSyncWorker: NSObject
// @end


// %group Offline
// %hook YTColdConfig
// - (BOOL)allOfflineContentOnCommuteShelfEnabled {
//     return YES;
// }

// - (void)setAllOfflineContentOnCommuteShelfEnabled:(_Bool)arg1 {
//     %orig(YES);
// }

// - (BOOL)musicClientConfigIosMusicEnableSmartDownloads {
//     return YES;
// }

// - (BOOL)musicClientConfigEnableSmartDownloadRecentMusic {
//     return YES;
// }
// %end

// %hook YTIBrowseResponse
// + (BOOL)offlineVideosAreDisplayable:(id)arg1 {
//     return YES;
// }
// %end

// %hook YTMAppResponder
// - (BOOL)allowsOfflineTransition {
//     return YES;
// }
// %end

// %hook YTHotConfig
// - (BOOL)isDownloadsPageCommuteEntryPointEnabled {
//     return YES;
// }

// - (void)setIsDownloadsPageCommuteEntryPointEnabled:(BOOL)enabled {
//     %orig(YES);
// }

// - (BOOL)enableDownloadsPageDRMVideosDecoration {
//     return NO;
// }

// - (BOOL)enableOfflineOrchestrationAPIForDRM {
//     return NO;
// }
// %end

// %hook YTMXSDKContentController
// - (BOOL)prefetchDownloadsEnabled {
//     return YES;
// }

// - (void)setPrefetchDownloadsEnabled:(BOOL)enabled {
//     %orig(YES);
// }
// %end

// %hook YTOfflineVideoDownloader
// - (BOOL)canDownloadVideo {
//     return YES;
// }
// %end

// %hook YTMOfflineContentAvailabilityController
// + (BOOL)offlineMixtapeEnabled {
//     return YES;
// }
// %end

// %hook YTOfflineVideo
// - (BOOL)isPlayableForOfflineStateDateSkewCheckForDate:(id)arg1 upsell:(id *)arg2 {
//     return YES;
// }

// - (BOOL)isPlayableForOfflineExpiryCheckForDate:(id)arg1 upsell:(id *)arg2 {
//     return YES;
// }

// - (BOOL)isPlayableForStatusWithUpsell:(id *)arg1 {
//     return YES;
// }

// - (BOOL)isPlayableForPlayabilityStatusWithUpsell:(id *)arg1 {
//     return YES;
// }

// - (BOOL)isPlayableForOfflineActionWithUpsell:(id *)arg1 {
//     return YES;
// }

// - (BOOL)isPlayableForManualDeletionCheckWithUpsell:(id *)arg1 {
//     return YES;
// }

// - (BOOL)isPlayableOfflineWithUpsell:(id *)arg1 {
//     return YES;
// }

// - (BOOL)isPlayableOfflineWithReason:(id *)arg1 {
//     return YES;
// }
// %end

// %hook YTIOfflineState
// - (BOOL)isPlayableOffline {
//     return YES;
// }

// - (id)offlineUpsell {
//     return nil;
// }

// - (BOOL)hasOfflineUpsell {
//     return NO;
// }

// - (BOOL)isOfflineSharingAllowed {
//     return YES;
// }

// - (BOOL)hasIsOfflineSharingAllowed {
//     return YES;
// }

// - (BOOL)hasOfflineFutureUnplayableInfo {
//     return NO;
// }

// - (BOOL)hasOfflinePlaybackDisabledReason {
//     return NO;
// }
// %end

// %hook YTOfflineFutureUnplayableInfoModel
// - (BOOL)hasUnplayableReason {
//     return NO;
// }

// - (BOOL)becomesUnplayableInSeconds {
//     return NO;
// }

// - (BOOL)hasBecomesUnplayableInSeconds {
//     return NO;
// }
// %end

// %hook YTOfflineVideoController
// - (void)reportNotPlayableOfflineWithPlayerResponse:(id)arg1 responseBlock:(id)arg2 {
//     return;
// }
// %end

// %hook YTOfflineVideoPolicyEntityModel
// - (BOOL)hasOfflinePlaybackDisabledReason {
//     return NO;
// }
// %end

// %hook YTMStatusViewSectionController
// - (id)initWithStyle:(int)arg1 allowsOfflineTransition:(_Bool)arg2 delegate:(id)arg3 parentResponder:(id)arg4 shouldShowCancelButton:(_Bool)arg5 {
//     return %orig(arg1, YES, arg3, arg4, arg5);
// }
// %end

// %hook YTMOfflineBrowseViewController
// - (BOOL)allowsOfflineTransition {
//     return YES;
// }
// %end

// %hook YTMAutoOfflineController
// - (id)init {
//     self = %orig;
//     if (self) {
//         [self setValue:[NSNumber numberWithBool:YES] forKey:@"_smartDownloadsEnabled"];
//         NSLog(@"[YTMULT]: YTMAutoOfflineController - init (_smartDownloadsEnabled) = %@", [self valueForKey:@"_smartDownloadsEnabled"] ? @"YES" : @"NO");
//     }
//     return self;
// }
// %end

// // %hook YTIMusicOfflinePreferences
// // - (BOOL)hasAutoDownloadsPreferences {
// //     return YES;
// // }

// // - (BOOL)hasOfflineMixtapePreferences {
// //     return YES;
// // }
// // %end

// // %hook YTIMusicAutoDownloadsPreferences
// // - (BOOL)enabled {
// //     return YES;
// // }

// // - (BOOL)hasEnabled {
// //     return YES;
// // }
// // %end

// // %hook YTIMusicOfflineMixtapePreferences
// // - (BOOL)enabled {
// //     return YES;
// // }

// // - (BOOL)hasEnabled {
// //     return YES;
// // }
// // %end

// %hook YTIMusicAppMetadataRenderer
// // - (BOOL)hasIsAudioCastEnabled {
// //     return YES;
// // }

// // - (BOOL)hasIsAudioOnlyButtonVisible {
// //     return YES;
// // }

// // - (BOOL)hasIsMobileAudioTier {
// //     return YES;
// // }

// // - (BOOL)hasIsOfflineEntryVisible {
// //     return YES;
// // }

// // - (BOOL)hasIsOfflineMixtapeV2Enabled {
// //     return YES;
// // }

// // - (BOOL)hasMatAvodCastEnabled {
// //     return YES;
// // }

// // - (BOOL)isAudioCastEnabled {
// //     return YES;
// // }

// // - (BOOL)isAudioOnlyButtonVisible {
// //     return YES;
// // }

// // - (BOOL)isMobileAudioTier {
// //     return YES;
// // }

// // - (BOOL)isOfflineEntryVisible {
// //     return YES;
// // }

// // - (BOOL)isOfflineMixtapeV2Enabled {
// //     return YES;
// // }

// // - (BOOL)matAvodCastEnabled {
// //     return YES;
// // }
// %end

// %hook YTIMusicAppInfo
// // - (BOOL)autoOfflineEnabled {
// //     return YES;
// // }

// // - (BOOL)hasAutoOfflineEnabled {
// //     return YES;
// // }

// // - (BOOL)hasOfflineMixtapeEnabled {
// //     return YES;
// // }

// - (BOOL)offlineMixtapeEnabled {
//     return YES;
// }
// %end

// %hook YTIOfflineFeatureSettingState
// - (BOOL)hasIsSdEnabled {
//     return YES;
// }

// - (BOOL)isDlrecsEnabled {
//     return YES;
// }

// - (BOOL)isSdEnabled {
//     return YES;
// }

// - (BOOL)hasIsDlrecsEnabled {
//     return YES;
// }
// %end

// %hook YTIAppSettingsSnapshot_AppSettings
// - (BOOL)hasIsOfflineModeEnabled {
//     return YES;
// }

// - (BOOL)hasIsSmartDownloadsEnabled {
//     return YES;
// }

// - (BOOL)isOfflineModeEnabled {
//     return YES;
// }

// - (BOOL)isSmartDownloadsEnabled {
//     return YES;
// }
// %end

// %hook YTIBackgroundOfflineSettingCategoryEntryRenderer
// - (BOOL)hasIs1080PFormatOptionAvailable {
//     return YES;
// }

// - (BOOL)hasIsBackgroundEnabled {
//     return YES;
// }

// - (BOOL)hasIsCrossDeviceOfflineEnabled {
//     return YES;
// }

// - (BOOL)hasIsDownloadQualityEnabled {
//     return YES;
// }

// - (BOOL)hasIsOfflineEnabled {
//     return YES;
// }

// - (BOOL)hasShouldDisplaySmartDownloads {
//     return YES;
// }

// - (BOOL)is1080PFormatOptionAvailable {
//     return YES;
// }

// - (BOOL)isBackgroundEnabled {
//     return YES;
// }

// - (BOOL)isCrossDeviceOfflineEnabled {
//     return YES;
// }

// - (BOOL)isDownloadQualityEnabled {
//     return YES;
// }

// - (BOOL)isOfflineEnabled {
//     return YES;
// }

// - (BOOL)shouldDisplaySmartDownloads {
//     return YES;
// }
// %end

// %hook YTIOfflineHotConfig
// - (BOOL)enableMoreSmartDownloads {
//     return YES;
// }

// - (BOOL)hasEnableMoreSmartDownloads {
//     return YES;
// }
// %end

// %hook YTIMusicDownloadStatusEntity
// - (BOOL)hasIsSmartDownloaded {
//     return YES;
// }

// - (BOOL)isSmartDownloaded {
//     return YES;
// }
// %end

// %hook YTIMusicCoreClientHotConfig
// - (BOOL)hasNitrateTriggeredSmartDownloadsPermission {
//     return YES;
// }

// - (BOOL)nitrateTriggeredSmartDownloadsPermission {
//     return YES;
// }
// %end
// %end

// %ctor {
//     %init(Offline);
// }