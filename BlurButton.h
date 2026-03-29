#ifndef BlurButton_h
#define BlurButton_h

#import <UIKit/UIKit.h>

@interface BlurButton : UIButton

@property (nonatomic, strong) UIImageView *buttonImageView;

+ (instancetype)createButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action
                                 menu:(id)menu;
+ (instancetype)createButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action;
- (void)setHighlighted:(BOOL)highlighted;

@end

#endif
