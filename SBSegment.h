#ifndef SBSegment_h
#define SBSegment_h

#import <Foundation/Foundation.h>

@interface SBSegment : NSObject

@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *actionType;
@property (nonatomic, strong) NSString *segmentDescription;
@property (nonatomic, assign) double start;
@property (nonatomic, assign) double end;
@property (nonatomic, assign) double videoDuration;
@property (nonatomic, assign) long long votes;

+ (instancetype)segmentWithDictionary:(NSDictionary *)dictionary;

@end

#endif
