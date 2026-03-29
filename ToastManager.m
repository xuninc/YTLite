#import "ToastManager.h"

@implementation ToastManager

static ToastManager *_sharedManager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ToastManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toasts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess {
    ToastView *toastView = [[ToastView alloc] init];
    [[ToastManager sharedManager] registerToast:toastView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [toastView showMessageWithText:text isSuccess:isSuccess];
    });
}

- (void)registerToast:(ToastView *)toast {
    if (toast != nil) {
        @synchronized (self.toasts) {
            if (![self.toasts containsObject:toast]) {
                [self.toasts addObject:toast];
                [self updateAllToasts];
            }
        }
    }
}

- (void)unregisterToast:(ToastView *)toast {
    if (toast != nil) {
        @synchronized (self.toasts) {
            [self.toasts removeObject:toast];
            [self updateAllToasts];
        }
    }
}

- (void)updateAllToasts {
    @synchronized (self.toasts) {
        for (ToastView *toast in self.toasts) {
            [toast updateLayout];
        }
    }
}

- (void)dealloc {
    _toasts = nil;
}

@end
