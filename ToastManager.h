#ifndef ToastManager_h
#define ToastManager_h

#import <Foundation/Foundation.h>

@class ToastView;

@interface ToastManager : NSObject

@property (nonatomic, strong) NSMutableArray *toasts;

+ (instancetype)sharedManager;
- (instancetype)init;
- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess;
- (void)registerToast:(ToastView *)toast;
- (void)unregisterToast:(ToastView *)toast;
- (void)updateAllToasts;

@end

#endif
