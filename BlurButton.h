#ifndef BlurButton_h
#define BlurButton_h

#import <UIKit/UIKit.h>

@interface BlurButton : UIButton

@property (nonatomic, strong) UIImageView *imageView;

+ (instancetype)createButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action
                                 menu:(UIMenu *)menu;
- (void)setHighlighted:(BOOL)highlighted;

@end

#endif
