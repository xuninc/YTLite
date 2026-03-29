#ifndef CustomHUD_h
#define CustomHUD_h

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomHUD : NSObject

@property (nonatomic, strong) MPVolumeController *controller;

- (instancetype)init;
- (void)addToController;
- (void)removeFromController;
- (void)setVolumeLevel:(float)level;
- (float)volumeLevel;
- (UIWindowScene *)windowSceneForVolumeDisplay;
- (NSString *)volumeAudioCategory;

@end

#endif
