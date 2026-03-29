#import "AudioManager.h"

@implementation AudioManager

static AudioManager *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error != nil) {
            NSLog(@"YTPlus - Unable to set category: %@", [error localizedDescription]);
        }

        NSString *path = [[NSBundle mainBundle] pathForResource:@"SponsorAudio" ofType:@"m4a"];
        NSURL *url = [NSURL fileURLWithPath:path];
        error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error != nil) {
            NSLog(@"YTPlus - Unable to init player: %@", [error localizedDescription]);
            return nil;
        }
        [self setAudioPlayer:player];
        [[self audioPlayer] setDelegate:self];
        [[self audioPlayer] prepareToPlay];
    }
    return self;
}

- (void)playAudio {
    if ([[self audioPlayer] isPlaying]) {
        return;
    }
    [[self audioPlayer] play];
}

- (void)stopAudio {
    if ([[self audioPlayer] isPlaying]) {
        [[self audioPlayer] stop];
        [[self audioPlayer] setCurrentTime:0];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    return;
}

- (void)dealloc {
    _audioPlayer = nil;
}

@end
