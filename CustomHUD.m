#import "CustomHUD.h"

@implementation CustomHUD

- (instancetype)init {
    self = [super init];
    if (self) {
        self.controller = [[MPVolumeController alloc] init];
    }
    return self;
}

- (void)addToController {
    MPVolumeHUDController *hudController = [MPVolumeHUDController sharedInstance];
    [hudController addController:self];
}

- (void)removeFromController {
    MPVolumeHUDController *hudController = [MPVolumeHUDController sharedInstance];
    [hudController removeController:self];
}

- (void)setVolumeLevel:(float)level {
    [self.controller setVolumeValue:level];
}

- (float)volumeLevel {
    return [self.controller volumeValue];
}

- (UIWindowScene *)windowSceneForVolumeDisplay {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray<UIScene *> *connectedScenes = [app connectedScenes];
    UIWindowScene *scene = [connectedScenes anyObject];
    return scene;
}

- (NSString *)volumeAudioCategory {
    return [self.controller volumeAudioCategory];
}

- (void)dealloc {
    self.controller = nil;
}

@end
