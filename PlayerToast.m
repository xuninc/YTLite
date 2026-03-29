#import "PlayerToast.h"
#import "CustomHUD.h"

static PlayerToast *_sharedInstance = nil;
static dispatch_once_t _sharedOnceToken;

@implementation PlayerToast

+ (instancetype)sharedToast {
    dispatch_once(&_sharedOnceToken, ^{
        _sharedInstance = [[PlayerToast alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];

    self = [super init];

    if (self) {
        self.volumeHUD = [CustomHUD new];

        self.activeConstraints = [NSMutableArray array];

        [self setAlpha:0.0];

        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self setUserInteractionEnabled:NO];

        UIColor *whiteColor = [UIColor whiteColor];
        CGColorRef whiteCGColor = [whiteColor CGColor];

        CALayer *layer = [self layer];
        [layer setBackgroundColor:whiteCGColor];

        layer = [self layer];
        [layer setShadowOffset:CGSizeMake(0.0, 2.0)];

        layer = [self layer];
        [layer setShadowRadius:12.0];

        layer = [self layer];
        [layer setShadowOpacity:0.3];

        self.toastView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

        [[self.toastView layer] setCornerRadius:18.0];

        CALayer *toastViewLayer = [self.toastView layer];
        [toastViewLayer setCornerCurve:kCACornerCurveContinuous];

        [self.toastView setClipsToBounds:YES];

        self.toastImage = [[UIImageView alloc] init];

        [self.toastImage setTintColor:[UIColor whiteColor]];

        [self.toastImage setContentMode:UIViewContentModeScaleAspectFit];

        [self.toastImage setUserInteractionEnabled:NO];

        self.toastLabel = [[UILabel alloc] init];

        [self.toastLabel setTextColor:[UIColor whiteColor]];

        UIFont *boldFont = [UIFont systemFontOfSize:13.0 weight:UIFontWeightBold];
        [self.toastLabel setFont:boldFont];

        [self.toastLabel setTextAlignment:NSTextAlignmentCenter];

        [self.toastLabel setUserInteractionEnabled:NO];

        self.toastSubLabel = [[UILabel alloc] init];

        [self.toastSubLabel setTextColor:[UIColor whiteColor]];

        UIFont *regularFont = [UIFont systemFontOfSize:13.0 weight:UIFontWeightRegular];
        [self.toastSubLabel setFont:regularFont];

        [self.toastSubLabel setTextAlignment:NSTextAlignmentCenter];

        [self.toastSubLabel setUserInteractionEnabled:NO];

        self.toastProgress = [[UIProgressView alloc] init];

        [self.toastProgress setProgressTintColor:[UIColor whiteColor]];

        UIColor *trackColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
        [self.toastProgress setTrackTintColor:trackColor];
    }

    return self;
}

- (void)showPlayerToastWithText:(id)text value:(double)value style:(long long)style isCompact:(BOOL)isCompact {
    self.style = style;
    self.isCompact = isCompact;
    // Sets up toast image, label, sub-label, constraints, and animation
}

- (void)prepareForPresentation {
    id snapshot = [[self snapshotViewAfterScreenUpdates:NO] retain];
    [snapshot removeFromSuperview];
    [snapshot release];
    [self setHidden:YES];
    self.alpha = 0.0;
}

- (void)updateToastText:(id)text value:(double)value {
    id toastImage = self.toastImage;
    id retainedText = [text retain];

    // Get the current image from toastImage and update it
    id currentImage = [[toastImage image] retain];
    [self.toastImage setImage:currentImage];
    [currentImage release];

    // Update progress bar
    [self.toastProgress setProgress:(float)(value / 100.0)];

    // If compact mode, don't set main label text
    id labelText = retainedText;
    if (self.isCompact) {
        labelText = nil;
    }
    [self.toastLabel setText:labelText];
    [retainedText release];

    // Format and set sub-label text based on style
    long long currentStyle = self.style;
    id formattedSubText = [[self formatValueText:value forStyle:currentStyle] retain];
    [self.toastSubLabel setText:formattedSubText];
    [formattedSubText release];

    // Update accessibility value
    [self updateAccessibilityValue:value forStyle:currentStyle];

    // Get new image for current value
    id newImage = [[self imageForValue:value] retain];
    id currentToastImage = [[self.toastImage image] retain];
    BOOL isSameImage = [currentToastImage isEqual:newImage];
    [currentToastImage release];

    if (!isSameImage) {
        id capturedImage = [newImage retain];
        [UIView transitionWithView:self.toastImage
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.toastImage setImage:capturedImage];
                        }
                        completion:nil];
        [capturedImage release];
    }

    [newImage release];
}

- (void)hideToast {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self setHidden:YES];
                             [self.volumeHUD removeFromSuperview];
                         }
                     }];
}

- (void)setupConstraints {
    // Very large constraint setup function
    // Sets up auto layout constraints for toastView, toastImage, toastLabel, toastSubLabel, toastProgress
    // Adjusts sizes based on _isCompact flag
}

- (void)clearConstraints {
    [NSLayoutConstraint deactivateConstraints:self.activeConstraints];
    [self.activeConstraints removeAllObjects];
}

- (UIImage *)imgForVal:(double)value {
    NSString *imageName = nil;
    NSInteger style = self.style;

    if (style == 2) {
        // Volume
        if (value == 0.0) {
            imageName = @"vol_off";
        } else if (value >= 1.0 && value <= 25.0) {
            imageName = @"vol_low";
        } else if (value >= 26.0 && value <= 50.0) {
            imageName = @"vol_mid";
        } else {
            BOOL below = YES;
            BOOL above = NO;
            if (value <= 100.0) {
                below = NO;
                above = YES;
                if (!isnan(value) && !isnan(67.0)) {
                    below = value < 67.0;
                    above = NO;
                }
            }
            imageName = @"vol_max";
            if (below != above) {
                imageName = nil;
            }
        }
    } else if (style == 1) {
        // Speed
        float rounded = (float)((int)(value * 10.0)) / 10.0f;
        if (rounded < 1.0f) {
            imageName = @"speed_slow";
        } else if (rounded == 1.0f) {
            imageName = @"speed_reg";
        } else if ((double)rounded >= 1.5) {
            imageName = @"speed_fast";
        } else {
            imageName = nil;
        }
    } else if (style == 0) {
        // Brightness
        if (value >= 0.0 && value <= 25.0) {
            imageName = @"sun_min";
        } else if (value >= 26.0 && value <= 50.0) {
            imageName = @"sun_mid";
        } else {
            BOOL below = YES;
            BOOL above = NO;
            if (value <= 100.0) {
                below = NO;
                above = YES;
                if (!isnan(value) && !isnan(67.0)) {
                    below = value < 67.0;
                    above = NO;
                }
            }
            imageName = @"sun_max";
            if (below != above) {
                imageName = nil;
            }
        }
    } else {
        imageName = nil;
    }

    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return templateImage;
}

- (NSString *)subLabelForVal:(double)value style:(NSInteger)style {
    NSString *result;
    if (style == 1) {
        NSNumber *number = [NSNumber numberWithFloat:(float)value];
        result = [NSString stringWithFormat:@"%@", number];
    } else {
        result = [NSString stringWithFormat:@"%ld%%", (long)(NSInteger)value];
    }
    return result;
}

- (void)setupSubForStyle:(NSInteger)style {
    CGFloat progressAlpha = 0.0;
    CGFloat subLabelAlpha = 1.0;
    if (style != 1) {
        progressAlpha = 1.0;
        subLabelAlpha = 0.0;
    }
    self.toastProgress.alpha = progressAlpha;
    self.toastSubLabel.alpha = subLabelAlpha;
}

- (void)setValue:(double)value forEventWithStyle:(NSInteger)style {
    if (style == 2) {
        // Volume
        [self.volumeHUD cancelVolumeEvent];
        [self.volumeHUD setVolume:(float)(value / 100.0)];
        return;
    }
    if (style == 0) {
        // Brightness
        UIScreen *mainScreen = [UIScreen mainScreen];
        mainScreen.brightness = value / 100.0;
        [mainScreen release];
        return;
    }
}

- (UIView *)sourceView {
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *keyWindow = [app keyWindow];
    UIView *rootView = [keyWindow rootViewController].view;
    return rootView;
}

- (BOOL)isLandscape {
    UIApplication *app = [UIApplication sharedApplication];
    UIWindowScene *windowScene = [app keyWindow].windowScene;
    UIViewController *rootVC = [windowScene rootViewController];
    id statusBarManager = [rootVC statusBarManager];
    NSInteger orientation = [statusBarManager statusBarOrientation];
    [rootVC release];
    [windowScene release];
    [app release];
    BOOL result = ((NSUInteger)(orientation - 3) < 2);
    [statusBarManager release];
    return result;
}

- (void)dealloc {
    self.volumeHUD = nil;
    self.toastProgress = nil;
    self.toastSubLabel = nil;
    self.toastLabel = nil;
    self.toastImage = nil;
    self.toastView = nil;
    self.activeConstraints = nil;
}

@end
