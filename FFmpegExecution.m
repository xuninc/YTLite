#import "FFmpegExecution.h"

@implementation FFmpegExecution

- (instancetype)initWithExecutionId:(long long)execId andArguments:(id)arguments {
    self = [super init];
    if (self) {
        self.startTime = [NSDate date];
        self.executionId = execId;
        self.command = [MobileFFmpeg argumentsToString:arguments];
    }
    return self;
}

- (NSDate *)getStartTime {
    return self.startTime;
}

- (long long)getExecutionId {
    return self.executionId;
}

- (NSString *)getCommand {
    return self.command;
}

- (void)dealloc {
    _command = nil;
    _startTime = nil;
}

@end
