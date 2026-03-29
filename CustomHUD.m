#import "CustomHUD.h"

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
    Class MPVolumeHUDControllerClass = NSClassFromString(@"MPVolumeHUDController");
    if (MPVolumeHUDControllerClass) {
        id hudController = [MPVolumeHUDControllerClass sharedInstance];
        [hudController addController:self];
    }
}

- (void)removeFromController {
    Class MPVolumeHUDControllerClass = NSClassFromString(@"MPVolumeHUDController");
    if (MPVolumeHUDControllerClass) {
        id hudController = [MPVolumeHUDControllerClass sharedInstance];
        [hudController removeController:self];
    }
}

- (void)setVolumeLevel:(float)level {
    [self.controller setVolumeValue:level];
}

- (float)volumeLevel {
    return [self.controller volumeValue];
}

- (UIWindowScene *)windowSceneForVolumeDisplay {
    UIApplication *app = [UIApplication sharedApplication];
    NSSet<UIScene *> *connectedScenes = [app connectedScenes];
    UIWindowScene *scene = (UIWindowScene *)[connectedScenes anyObject];
    return scene;
}

- (NSString *)volumeAudioCategory {
    return [self.controller volumeAudioCategory];
}

- (void)dealloc {
    self.controller = nil;
}

@end
