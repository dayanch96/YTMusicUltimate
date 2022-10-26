#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MPVolumeSlider : UISlider
@end

@interface MPVolumeView (Private)
@property (nonatomic, strong) MPVolumeSlider *volumeSlider;
@end

@interface GSVolBar : MPVolumeView
@end