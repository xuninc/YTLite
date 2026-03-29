#import "CustomHUD.h"
#import <objc/message.h>

@implementation CustomHUD

- (instancetype)init {
    self = [super init];
    if (self) {
        Class MPVolumeControllerClass = NSClassFromString(@"MPVolumeController");
        if (MPVolumeControllerClass) {
            self.controller = [[MPVolumeControllerClass alloc] init];
        }
    }
    return self;
}

- (void)addToController {
    Class cls = NSClassFromString(@"MPVolumeHUDController");
    if (cls) {
        id hudController = ((id(*)(id, SEL))objc_msgSend)(cls, sel_registerName("sharedInstance"));
        ((void(*)(id, SEL, id))objc_msgSend)(hudController, sel_registerName("addController:"), self);
    }
}

- (void)removeFromController {
    Class cls = NSClassFromString(@"MPVolumeHUDController");
    if (cls) {
        id hudController = ((id(*)(id, SEL))objc_msgSend)(cls, sel_registerName("sharedInstance"));
        ((void(*)(id, SEL, id))objc_msgSend)(hudController, sel_registerName("removeController:"), self);
    }
}

- (void)setVolumeLevel:(float)level {
    ((void(*)(id, SEL, float))objc_msgSend)(self.controller, sel_registerName("setVolumeValue:"), level);
}

- (float)volumeLevel {
    return ((float(*)(id, SEL))objc_msgSend)(self.controller, sel_registerName("volumeValue"));
}

- (UIWindowScene *)windowSceneForVolumeDisplay {
    NSSet<UIScene *> *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
    return (UIWindowScene *)[connectedScenes anyObject];
}

- (NSString *)volumeAudioCategory {
    return ((id(*)(id, SEL))objc_msgSend)(self.controller, sel_registerName("volumeAudioCategory"));
}

- (void)dealloc {
    self.controller = nil;
}

@end
