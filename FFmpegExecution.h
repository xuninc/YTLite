#ifndef FFmpegExecution_h
#define FFmpegExecution_h

#import <Foundation/Foundation.h>

@class MobileFFmpeg;

@interface FFmpegExecution : NSObject

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) long long executionId;
@property (nonatomic, strong) NSString *command;

- (instancetype)initWithExecutionId:(long long)executionId andArguments:(id)arguments;
- (NSDate *)getStartTime;
- (long long)getExecutionId;
- (NSString *)getCommand;

@end

#endif
