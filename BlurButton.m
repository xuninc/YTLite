#import "BlurButton.h"

@implementation BlurButton

+ (instancetype)createButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action
                                 menu:(UIMenu *)menu {
    BlurButton *button = [[BlurButton alloc] initWithFrame:CGRectMake(0, 0, 28.0, 28.0)];

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    [effectView setFrame:[button bounds]];
    effectView.layer.cornerRadius = 14.0;
    effectView.clipsToBounds = YES;
    effectView.userInteractionEnabled = NO;

    [button addSubview:effectView];

    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18.0, 18.0)];
    button.buttonImageView = imgView;

    [imgView setCenter:[effectView center]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [imgView setImage:image];

    UIColor *tintColor = [UIColor whiteColor];
    [imgView setTintColor:tintColor];

    UIView *contentView = [effectView contentView];
    [contentView addSubview:imgView];

    if (menu == nil) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        if (@available(iOS 14.0, *)) {
            [button setMenu:menu];
            [button setShowsMenuAsPrimaryAction:YES];
        }
    }

    return button;
}

+ (instancetype)createButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action {
    return [self createButtonWithImage:image target:target action:action menu:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CGFloat alpha = highlighted ? 0.25 : 1.0;
    [self.buttonImageView setAlpha:alpha];
}

- (void)dealloc {
    self.buttonImageView = nil;
}

@end
