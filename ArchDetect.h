#ifndef ArchDetect_h
#define ArchDetect_h

#import <Foundation/Foundation.h>

@interface ArchDetect : NSObject

+ (void)initialize;
+ (NSString *)getCpuArch;
+ (NSString *)getArch;
+ (int)isLTSBuild;

@end

#endif /* ArchDetect_h */
