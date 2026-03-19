// ToastSystem.x - Toast/HUD notification system
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"
#import <objc/runtime.h>

// MARK: - ToastWindow

@implementation ToastWindow

static ToastWindow *_sharedToastWindow = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }
        if (scene) {
            _sharedToastWindow = [[self alloc] initWithWindowScene:scene];
        } else {
            _sharedToastWindow = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        _sharedToastWindow.windowLevel = UIWindowLevelAlert + 1;
        _sharedToastWindow.backgroundColor = [UIColor clearColor];
        _sharedToastWindow.hidden = YES;
        _sharedToastWindow.userInteractionEnabled = YES;
    });
    return _sharedToastWindow;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)windowControlsStatusBarOrientation {
    return NO;
}

- (BOOL)ignoresFullscreenOpacity {
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil; // Pass through touches that don't hit toast
    return hitView;
}

@end

// MARK: - ToastManager

@implementation ToastManager

static ToastManager *_sharedToastManager = nil;

+ (instancetype)sharedToast {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedToastManager = [[self alloc] init];
    });
    return _sharedToastManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toasts = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)showToast:(ToastView *)toast {
    if (!toast) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide existing toast if any
        [self hideToast];

        [self registerToast:toast];

        ToastWindow *window = [ToastWindow sharedInstance];
        [window addSubview:toast];
        window.toastView = toast;
        window.hidden = NO;

        // Layout toast at bottom
        toast.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [toast.leadingAnchor constraintEqualToAnchor:window.leadingAnchor constant:16],
            [toast.trailingAnchor constraintEqualToAnchor:window.trailingAnchor constant:-16],
            [toast.bottomAnchor constraintEqualToAnchor:window.safeAreaLayoutGuide.bottomAnchor constant:-16],
            [toast.heightAnchor constraintGreaterThanOrEqualToConstant:50]
        ]];

        // Animate in
        toast.alpha = 0;
        toast.transform = CGAffineTransformMakeTranslation(0, 20);
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toast.alpha = 1;
            toast.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
}

- (void)hideToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        ToastWindow *window = [ToastWindow sharedInstance];
        if (window.toastView) {
            [self unregisterToast:window.toastView];
            [UIView animateWithDuration:0.2 animations:^{
                window.toastView.alpha = 0;
                window.toastView.transform = CGAffineTransformMakeTranslation(0, 20);
            } completion:^(BOOL finished) {
                [window.toastView removeFromSuperview];
                window.toastView = nil;
                window.hidden = YES;
            }];
        }
    });
}

- (void)registerToast:(ToastView *)toast {
    if (![self.toasts containsObject:toast]) {
        [self.toasts addObject:toast];
    }
}

- (void)unregisterToast:(ToastView *)toast {
    [self.toasts removeObject:toast];
}

- (void)updateAllToasts {
    // Recalculate positions for all active toasts
}

- (void)calculateToastParametersWithKeyboardHeight:(CGFloat)keyboardHeight bottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale {
    // Adjust toast position based on keyboard
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self calculateToastParametersWithKeyboardHeight:keyboardFrame.size.height bottomOffset:0 topOffset:0 scale:1.0];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self calculateToastParametersWithKeyboardHeight:0 bottomOffset:0 topOffset:0 scale:1.0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

// MARK: - ToastView

@implementation ToastView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupBaseUI];
    }
    return self;
}

- (void)setupBaseUI {
    self.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.95];
    self.layer.cornerRadius = 12;
    self.layer.cornerCurve = kCACornerCurveContinuous;
    self.clipsToBounds = YES;

    // Toast icon
    _toastIcon = [[UIImageView alloc] init];
    _toastIcon.contentMode = UIViewContentModeScaleAspectFit;
    _toastIcon.tintColor = [UIColor whiteColor];
    _toastIcon.translatesAutoresizingMaskIntoConstraints = NO;

    // Toast label
    _toastLabel = [[UILabel alloc] init];
    _toastLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _toastLabel.textColor = [UIColor whiteColor];
    _toastLabel.numberOfLines = 0;
    _toastLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Toast sublabel
    _toastSubLabel = [[UILabel alloc] init];
    _toastSubLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _toastSubLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _toastSubLabel.numberOfLines = 0;
    _toastSubLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Progress view
    _toastProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _toastProgress.translatesAutoresizingMaskIntoConstraints = NO;
    _toastProgress.trackTintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    _toastProgress.progressTintColor = [UIColor systemBlueColor];
    _toastProgress.hidden = YES;

    // Stop button
    _toastButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_toastButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    _toastButton.tintColor = [UIColor whiteColor];
    _toastButton.translatesAutoresizingMaskIntoConstraints = NO;
    _toastButton.hidden = YES;

    [self addSubview:_toastIcon];
    [self addSubview:_toastLabel];
    [self addSubview:_toastSubLabel];
    [self addSubview:_toastProgress];
    [self addSubview:_toastButton];

    [NSLayoutConstraint activateConstraints:@[
        [_toastIcon.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
        [_toastIcon.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_toastIcon.widthAnchor constraintEqualToConstant:24],
        [_toastIcon.heightAnchor constraintEqualToConstant:24],

        [_toastLabel.leadingAnchor constraintEqualToAnchor:_toastIcon.trailingAnchor constant:8],
        [_toastLabel.trailingAnchor constraintEqualToAnchor:_toastButton.leadingAnchor constant:-8],
        [_toastLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],

        [_toastSubLabel.leadingAnchor constraintEqualToAnchor:_toastLabel.leadingAnchor],
        [_toastSubLabel.trailingAnchor constraintEqualToAnchor:_toastLabel.trailingAnchor],
        [_toastSubLabel.topAnchor constraintEqualToAnchor:_toastLabel.bottomAnchor constant:2],

        [_toastProgress.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_toastProgress.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_toastProgress.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_toastProgress.heightAnchor constraintEqualToConstant:3],

        [_toastButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [_toastButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_toastButton.widthAnchor constraintEqualToConstant:28],
        [_toastButton.heightAnchor constraintEqualToConstant:28],

        [self.bottomAnchor constraintGreaterThanOrEqualToAnchor:_toastSubLabel.bottomAnchor constant:10]
    ]];
}

#pragma mark - Public API

- (void)showText:(NSString *)text {
    [self showMessageWithText:text isSuccess:YES duration:2.0];
}

- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess {
    [self showMessageWithText:text isSuccess:isSuccess duration:2.5];
}

- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess duration:(NSTimeInterval)duration {
    [self setupInterfaceWithText:text progress:-1 withStop:NO isStatus:YES isSuccess:isSuccess withWait:NO];
    [self hideWithDelay:duration];
}

- (void)showProgressWithText:(NSString *)text progress:(float)progress withStop:(BOOL)withStop stopCompletion:(void (^)(void))stopCompletion {
    [self setupInterfaceWithText:text progress:progress withStop:withStop isStatus:NO isSuccess:NO withWait:NO];

    if (withStop && stopCompletion) {
        [_toastButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_toastButton addTarget:self action:@selector(stopButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, @selector(stopCompletion), stopCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionIcon:(UIImage *)actionIcon actionCompletion:(void (^)(void))actionCompletion {
    [self showProgressiveToastWithText:text duration:duration actionIcon:actionIcon ignoresPan:NO actionCompletion:actionCompletion];
}

- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionIcon:(UIImage *)actionIcon ignoresPan:(BOOL)ignoresPan actionCompletion:(void (^)(void))actionCompletion {
    [self setupInterfaceWithText:text progress:0 withStop:actionIcon != nil isStatus:NO isSuccess:NO withWait:NO];

    if (actionIcon) {
        [_toastButton setImage:actionIcon forState:UIControlStateNormal];
        _toastButton.hidden = NO;
    }

    if (actionCompletion) {
        [_toastButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_toastButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, @selector(actionCompletion), actionCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    [self hideWithDelay:duration];
}

- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionTitle:(NSString *)actionTitle actionCompletion:(void (^)(void))actionCompletion {
    [self setupInterfaceWithText:text progress:0 withStop:NO isStatus:NO isSuccess:NO withWait:NO];

    if (actionTitle && actionCompletion) {
        [_toastButton setImage:nil forState:UIControlStateNormal];
        [_toastButton setTitle:actionTitle forState:UIControlStateNormal];
        _toastButton.hidden = NO;
        [_toastButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_toastButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, @selector(actionCompletion), actionCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    [self hideWithDelay:duration];
}

- (void)updateText:(NSString *)text progress:(float)progress {
    [self updateText:text progress:progress animated:NO];
}

- (void)updateText:(NSString *)text progress:(float)progress animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (text) self.toastLabel.text = text;

        if (progress >= 0) {
            self.toastProgress.hidden = NO;
            if (animated) {
                [self.toastProgress setProgress:progress animated:YES];
            } else {
                self.toastProgress.progress = progress;
            }

            // Update sublabel with percentage
            self.toastSubLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
        }
    });
}

- (void)hideAnimatedWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, 20);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[ToastManager sharedToast] unregisterToast:self];
        ToastWindow *window = [ToastWindow sharedInstance];
        if (window.toastView == self) {
            window.toastView = nil;
            window.hidden = YES;
        }
        if (completion) completion();
    }];
}

- (void)hideWithCompletion:(void (^)(void))completion {
    [self hideAnimatedWithCompletion:completion];
}

- (void)hideWithDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideAnimatedWithCompletion:nil];
    });
}

- (void)configureToastAppearanceWithBottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale width:(CGFloat)width alpha:(CGFloat)alpha animationDuration:(NSTimeInterval)animationDuration completion:(void (^)(void))completion {
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = alpha;
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)configureToastAppearanceWithBottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale width:(CGFloat)width animationDuration:(NSTimeInterval)animationDuration {
    [self configureToastAppearanceWithBottomOffset:bottomOffset topOffset:topOffset scale:scale width:width alpha:1.0 animationDuration:animationDuration completion:nil];
}

- (void)setupInterfaceWithText:(NSString *)text progress:(float)progress withStop:(BOOL)withStop isStatus:(BOOL)isStatus isSuccess:(BOOL)isSuccess withWait:(BOOL)withWait {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.toastLabel.text = text;

        if (isStatus) {
            self.toastIcon.image = [UIImage systemImageNamed:isSuccess ? @"checkmark.circle.fill" : @"xmark.circle.fill"];
            self.toastIcon.tintColor = isSuccess ? [UIColor systemGreenColor] : [UIColor systemRedColor];
            self.toastProgress.hidden = YES;
            self.toastButton.hidden = YES;
            self.toastSubLabel.text = nil;
        } else {
            self.toastIcon.image = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
            self.toastIcon.tintColor = [UIColor systemBlueColor];
            self.toastProgress.hidden = (progress < 0);
            self.toastButton.hidden = !withStop;

            if (progress >= 0) {
                self.toastProgress.progress = progress;
                self.toastSubLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
            }
        }

        if (withWait) {
            // Show activity indicator
        }
    });
}

#pragma mark - Actions

- (void)stopButtonTapped {
    void (^completion)(void) = objc_getAssociatedObject(self, @selector(stopCompletion));
    if (completion) completion();
    [[ToastManager sharedToast] hideToast];
}

- (void)actionButtonTapped {
    void (^completion)(void) = objc_getAssociatedObject(self, @selector(actionCompletion));
    if (completion) completion();
    [[ToastManager sharedToast] hideToast];
}

// Associated object key stubs
- (void)stopCompletion {}
- (void)actionCompletion {}

@end

// MARK: - PlayerToast

@implementation PlayerToast

- (void)showPlayerToastWithText:(NSString *)text value:(NSString *)value style:(NSInteger)style isCompact:(BOOL)isCompact {
    dispatch_async(dispatch_get_main_queue(), ^{
        ToastView *toast = [[ToastView alloc] init];
        NSString *fullText = value ? [NSString stringWithFormat:@"%@: %@", text, value] : text;
        [toast showMessageWithText:fullText isSuccess:YES duration:1.5];
        [[ToastManager sharedToast] showToast:toast];
    });
}

- (void)updateToastText:(NSString *)text value:(NSString *)value {
    ToastWindow *window = [ToastWindow sharedInstance];
    if (window.toastView) {
        NSString *fullText = value ? [NSString stringWithFormat:@"%@: %@", text, value] : text;
        [window.toastView updateText:fullText progress:-1];
    }
}

@end

// MARK: - CustomHUD (Volume HUD)

@interface CustomHUD ()
@property (nonatomic, strong, readwrite) id controller;
@end

@implementation CustomHUD

- (void)addVolumeDisplay:(id)display {
    // Hook into system volume display
}

- (void)removeVolumeDisplay:(id)display {
    // Remove from system volume display
}

@end
