#import <Foundation/Foundation.h>

@interface Statistics : NSObject

@property (nonatomic, assign) long long executionId;
@property (nonatomic, assign) int videoFrameNumber;
@property (nonatomic, assign) float videoFps;
@property (nonatomic, assign) float videoQuality;
@property (nonatomic, assign) long long size;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) double bitrate;
@property (nonatomic, assign) double speed;

- (instancetype)initWithId:(long long)executionId
         videoFrameNumber:(int)videoFrameNumber
                      fps:(float)fps
                  quality:(float)quality
                     size:(long long)size
                     time:(int)time
                  bitrate:(double)bitrate
                    speed:(double)speed;
- (void)update:(Statistics *)statistics;

@end
