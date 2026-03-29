#ifndef ToastWindow_h
#define ToastWindow_h

#import <UIKit/UIKit.h>

@class ToastView;

@interface ToastWindow : UIWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene;
- (BOOL)canBecomeKeyWindow;
- (void)makeKeyAndVisible;
- (BOOL)shouldAffectStatusBarAppearance;
- (BOOL)_windowControlsStatusBarOrientation;
- (BOOL)_canBecomeKeyWindow;
+ (UIWindow *)appKeyWindow;
+ (void)initialize;

@end

#endif
