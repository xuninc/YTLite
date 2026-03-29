#import <Foundation/Foundation.h>

@interface AtomicLong : NSObject
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) long long value;
- (instancetype)initWithInitialValue:(long long)initialValue;
- (long long)incrementAndGet;
@end
