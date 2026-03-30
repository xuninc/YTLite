#ifndef SBManager_h
#define SBManager_h

#import <Foundation/Foundation.h>

@class SBSegment;

@interface SBManager : NSObject

@property (nonatomic, strong) NSString *categoriesJSON;
@property (nonatomic, strong) NSString *encodedCategories;
@property (nonatomic, strong) NSMutableDictionary *segments;

+ (instancetype)sharedManager;
- (instancetype)init;
- (NSArray *)sponsorBlockCategories;
- (void)getSegmentsForID:(NSString *)videoID;
- (void)handleSegmentsResponse:(NSData *)data error:(NSError *)error videoID:(NSString *)videoID;

@end

#endif
