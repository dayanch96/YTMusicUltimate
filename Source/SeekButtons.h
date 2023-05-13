#import <UIKit/UIKit.h>

@interface YTMNowPlayingView : UIView
@property (nonatomic, strong) UIButton *dislikeButton;
@property (nonatomic, strong) UIButton *likeButton;
- (void)didTapDislikeButton;
- (void)didTapLikeButton;
- (void)didTapSeekBackwardButton;
- (void)didTapSeekForwardButton;
//- (UIView *)playerControlsView;
@end

/* in case if I/You decide to keep original icons
@interface UIView (YTMPlayerControlsView)
- (UIView *)playerControlsView;
@end

@implementation UIView (YTMPlayerControlsView)
- (UIView *)playerControlsView {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"YTMPlayerControlsView")]) {
            return subview;
        }
    }
    return nil;
}
@end

@interface UIView (YTMSeekButton)
- (UIButton *)seekBackwardButton;
- (UIButton *)seekForwardButton;
@end

@implementation UIView (YTMSeekButton)
- (UIButton *)seekBackwardButton {
    UIView *playerControlsView = [self playerControlsView];
    if (playerControlsView) {
        for (UIView *subview in playerControlsView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                UIImage *image = [button imageForState:UIControlStateNormal];
                if (image && CGSizeEqualToSize(image.size, CGSizeMake(24.0, 24.0))) {
                    return button;
                }
            }
        }
    }
    return nil;
}

- (UIButton *)seekForwardButton {
    UIView *playerControlsView = [self playerControlsView];
    if (playerControlsView) {
        for (UIView *subview in playerControlsView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                UIImage *image = [button imageForState:UIControlStateNormal];
                if (image && CGSizeEqualToSize(image.size, CGSizeMake(24.0, 24.0))) {
                    return button;
                }
            }
        }
    }
    return nil;
}
@end */