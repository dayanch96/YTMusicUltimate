#include "GSVolBar.h"
#include <objc/runtime.h>

@implementation GSVolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

@end