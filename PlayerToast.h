#ifndef PlayerToast_h
#define PlayerToast_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CustomHUD;

@interface PlayerToast : UIView

@property (nonatomic, strong) CustomHUD *volumeHUD;
@property (nonatomic, strong) NSMutableArray *activeConstraints;
@property (nonatomic, strong) UIVisualEffectView *toastView;
@property (nonatomic, strong) UIImageView *toastImage;
@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, strong) UILabel *toastSubLabel;
@property (nonatomic, strong) UIProgressView *toastProgress;
@property (nonatomic, assign) long long style;
@property (nonatomic, assign) BOOL isCompact;

+ (instancetype)sharedToast;
- (instancetype)init;
- (void)showPlayerToastWithText:(id)text value:(double)value style:(long long)style isCompact:(BOOL)isCompact;
- (void)prepareForPresentation;
- (void)updateToastText:(id)text value:(double)value;
- (void)hideToast;
- (void)setupConstraints;
- (void)clearConstraints;
- (NSString *)formatValueText:(double)value forStyle:(long long)style;
- (void)updateAccessibilityValue:(double)value forStyle:(long long)style;
- (UIImage *)imageForValue:(double)value;
- (UIImage *)imgForVal:(double)value;
- (NSString *)subLabelForVal:(double)value style:(NSInteger)style;
- (void)setupSubForStyle:(NSInteger)style;
- (void)setValue:(double)value forEventWithStyle:(NSInteger)style;
- (UIView *)sourceView;
- (BOOL)isLandscape;

@end

#endif
