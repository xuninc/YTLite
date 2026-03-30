#ifndef SBPlayerDecorator_h
#define SBPlayerDecorator_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SBManager;
@class SBSegment;

@interface SBPlayerDecorator : NSObject

- (void)addDurationWithoutSegments:(id)overlay videoController:(id)videoController;
- (void)drawSegmentsDecorationView:(UIView *)decorationView;
- (void)drawSegments:(NSArray *)segments layer:(CALayer *)layer playerVC:(id)playerVC;
- (void)drawSegmentableSegments:(NSArray *)segments playerBar:(id)playerBar playerVC:(id)playerVC;

@end

#endif /* SBPlayerDecorator_h */
