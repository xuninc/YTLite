#ifndef AudioManager_h
#define AudioManager_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)playAudio;
- (void)stopAudio;
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

#endif
