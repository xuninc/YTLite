#import "Statistics.h"

@implementation Statistics

- (instancetype)init {
    self = [super init];
    if (self) {
        _executionId = 0;
        _videoFrameNumber = 0;
        _videoFps = 0.0f;
        _videoQuality = 0.0f;
        _size = 0;
        _time = 0;
        _bitrate = 0.0;
        _speed = 0.0;
    }
    return self;
}

- (instancetype)initWithId:(long long)executionId
         videoFrameNumber:(int)videoFrameNumber
                      fps:(float)fps
                  quality:(float)quality
                     size:(long long)size
                     time:(int)time
                  bitrate:(double)bitrate
                    speed:(double)speed {
    self = [super init];
    if (self) {
        _executionId = executionId;
        _videoFrameNumber = videoFrameNumber;
        _videoFps = fps;
        _videoQuality = quality;
        _size = size;
        _time = time;
        _bitrate = bitrate;
        _speed = speed;
    }
    return self;
}

- (void)update:(Statistics *)statistics {
    if (!statistics) return;

    _executionId = statistics.executionId;

    if (statistics.videoFrameNumber > 0) _videoFrameNumber = statistics.videoFrameNumber;
    if (statistics.videoFps > 0.0f) _videoFps = statistics.videoFps;
    if (statistics.videoQuality > 0.0f) _videoQuality = statistics.videoQuality;
    if (statistics.size > 0) _size = statistics.size;
    if (statistics.time > 0) _time = statistics.time;
    if (statistics.bitrate > 0.0) _bitrate = statistics.bitrate;
    if (statistics.speed > 0.0) _speed = statistics.speed;
}

@end
