#import "ToastWindow.h"
#import <objc/runtime.h>

@implementation ToastWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    UIView *originalHitView = hitView;

    BOOL shouldPassThrough;

    if (hitView == nil) {
        hitView = nil;
        shouldPassThrough = YES;
    } else {
        UIView *currentView = hitView;
        while (currentView != nil) {
            // Check if the hit view is a ToastView
            if ([currentView isKindOfClass:[ToastView class]]) {
                shouldPassThrough = NO;
                break;
            }

            // Check if the hit view's view controller is a YTActionSheetDialogViewController
            UIViewController *vc1 = [currentView nextResponder];
            if ([vc1 isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
                [vc1 self];
                shouldPassThrough = NO;
                break;
            }

            // Check if the hit view's view controller is a YTDefaultSheetController
            UIViewController *vc2 = [currentView nextResponder];
            if ([vc2 isKindOfClass:NSClassFromString(@"YTDefaultSheetController")]) {
                [vc2 self];
                [vc1 self];
                shouldPassThrough = NO;
                break;
            }

            // Check if the hit view's view controller is a YTActionSheetDialogViewController (again)
            UIViewController *vc3 = [currentView nextResponder];
            if ([vc3 isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
                [vc3 self];
                [vc2 self];
                [vc1 self];
                shouldPassThrough = NO;
                break;
            }

            // Check if the hit view's view controller is a YTBottomSheetController
            UIViewController *vc4 = [currentView nextResponder];
            BOOL isBottomSheet = [vc4 isKindOfClass:NSClassFromString(@"YTBottomSheetController")];
            if (isBottomSheet) {
                [vc4 self];
                [vc3 self];
                [vc2 self];
                [vc1 self];
                shouldPassThrough = NO;
                break;
            }

            // Check if the hit view itself is a YTTouchForwardingView
            BOOL isTouchForwarding = [currentView isKindOfClass:NSClassFromString(@"YTTouchForwardingView")];

            if (isTouchForwarding) {
                shouldPassThrough = NO;
                break;
            }

            // Walk up the view hierarchy
            UIView *parentView = [currentView superview];
            currentView = parentView;
        }

        if (currentView == nil) {
            shouldPassThrough = YES;
        }
    }

    // If the hit view is not self, check further
    if (originalHitView != self) {
        UIWindow *keyWindow = [self keyWindow];
        UIView *rootView = [keyWindow rootViewController].view;
        if (originalHitView == rootView) {
            shouldPassThrough = YES;
        }
    }

    if (shouldPassThrough) {
        return nil;
    }

    return originalHitView;
}

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene {
    self = [super initWithWindowScene:windowScene];
    if (self != nil) {
        self.windowLevel = UIWindowLevelAlert - 1.0;
        UIColor *color = [UIColor clearColor];
        self.backgroundColor = color;
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (void)makeKeyAndVisible {
    [super makeKeyAndVisible];
    if ([self isKeyWindow]) {
        [self resignKeyWindow];
    }
}

- (BOOL)shouldAffectStatusBarAppearance {
    return NO;
}

- (BOOL)_windowControlsStatusBarOrientation {
    return NO;
}

- (BOOL)_canBecomeKeyWindow {
    return NO;
}

+ (UIWindow *)appKeyWindow {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray<UIWindow *> *windows = [app windows];

    for (UIWindow *window in windows) {
        if ([window isKeyWindow]) {
            return window;
        }
    }

    return nil;
}

+ (void)initialize {
    // Step 1: Create a mangled selector name from a prefix string
    NSString *mangledShouldAffect = [NSString stringWithFormat:@"_%@", @"shouldAffectStatusBarAppearance"];
    SEL newShouldAffectSel = NSSelectorFromString(mangledShouldAffect);

    // Get the original -shouldAffectStatusBarAppearance method
    Method shouldAffectMethod = class_getInstanceMethod(self, @selector(shouldAffectStatusBarAppearance));
    IMP shouldAffectIMP = method_getImplementation(shouldAffectMethod);
    const char *shouldAffectTypes = method_getTypeEncoding(shouldAffectMethod);

    // Add the method under the mangled selector name
    class_addMethod(self, newShouldAffectSel, shouldAffectIMP, shouldAffectTypes);

    // Step 2: Create a mangled selector name for canBecomeKeyWindow
    NSString *canBecomeKeyStr = NSStringFromSelector(@selector(canBecomeKeyWindow));
    NSString *mangledCanBecomeKey = [NSString stringWithFormat:@"_%@", canBecomeKeyStr];
    SEL newCanBecomeKeySel = NSSelectorFromString(mangledCanBecomeKey);

    // Get the original -canBecomeKeyWindow method
    Method canBecomeKeyMethod = class_getInstanceMethod(self, @selector(canBecomeKeyWindow));
    IMP canBecomeKeyIMP = method_getImplementation(canBecomeKeyMethod);
    const char *canBecomeKeyTypes = method_getTypeEncoding(canBecomeKeyMethod);

    // Add the method under the mangled selector name
    class_addMethod(self, newCanBecomeKeySel, canBecomeKeyIMP, canBecomeKeyTypes);

    [mangledCanBecomeKey release];
    [mangledShouldAffect release];
}

@end
