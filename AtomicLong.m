#import "AtomicLong.h"

@implementation AtomicLong

- (instancetype)initWithInitialValue:(long long)initialValue {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _value = initialValue;
    }
    return self;
}

- (long long)incrementAndGet {
    [self.lock lock];
    long long result = ++_value;
    [self.lock unlock];
    return result;
}

@end
