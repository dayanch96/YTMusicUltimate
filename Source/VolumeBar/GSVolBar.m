#include "GSVolBar.h"
#include <objc/runtime.h>

@implementation GSVolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        circleView.layer.cornerRadius = 6;
        circleView.backgroundColor = [UIColor whiteColor];

        [self.volumeSlider setThumbImage:[self imageWithView:circleView] forState:UIControlStateNormal];
        self.volumeSlider.minimumTrackTintColor = [UIColor whiteColor];
    }
    return self;
}

- (CGRect)volumeSliderRectForBounds:(CGRect)bounds {
    return bounds;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];

    if ([[subview class] isEqual:objc_getClass("MPButton")]) {
        [subview removeFromSuperview];
    }
}

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
