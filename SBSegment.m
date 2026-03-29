#import "SBSegment.h"

@implementation SBSegment

+ (instancetype)segmentWithDictionary:(NSDictionary *)dictionary {
    if (dictionary == nil) {
        return nil;
    }

    // Retrieve the "segment" value and validate it is an NSArray of length 2
    NSArray *segmentArray = [dictionary objectForKey:@"segment"];
    BOOL isArray = [segmentArray isKindOfClass:[NSArray class]];
    if (!isArray || [segmentArray count] != 2) {
        return nil;
    }

    SBSegment *segment = [[SBSegment alloc] init];

    // Set UUID
    NSString *uuidValue = [dictionary objectForKey:@"UUID"];
    segment.uuid = uuidValue;

    // Set category
    NSString *categoryValue = [dictionary objectForKey:@"category"];
    segment.category = categoryValue;

    // Set actionType
    NSString *actionTypeValue = [dictionary objectForKey:@"actionType"];
    segment.actionType = actionTypeValue;

    // Set description
    NSString *descriptionValue = [dictionary objectForKey:@"description"];
    segment.segmentDescription = descriptionValue;

    // Set start time from segment array index 0
    NSNumber *startValue = [segmentArray objectAtIndex:0];
    double startTime = [startValue doubleValue];
    segment.start = startTime;

    // Set end time from segment array index 1
    NSNumber *endValue = [segmentArray objectAtIndex:1];
    double endTime = [endValue doubleValue];
    segment.end = endTime;

    // Set video duration
    NSNumber *videoDurationValue = [dictionary objectForKey:@"videoDuration"];
    double videoDurationTime = [videoDurationValue doubleValue];
    segment.videoDuration = videoDurationTime;

    // Set locked
    NSNumber *lockedValue = [dictionary objectForKey:@"locked"];
    BOOL lockedBool = [lockedValue boolValue];
    segment.locked = lockedBool;

    // Set votes
    NSNumber *votesValue = [dictionary objectForKey:@"votes"];
    long long votesInt = [votesValue longLongValue];
    segment.votes = votesInt;

    // Mark as available
    segment.available = YES;

    return segment;
}

- (void)dealloc {
    _segmentDescription = nil;
    _actionType = nil;
    _category = nil;
    _uuid = nil;
}

@end
