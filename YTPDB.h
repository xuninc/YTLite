#ifndef YTPDB_h
#define YTPDB_h

#import <Foundation/Foundation.h>

@interface YTPDB : NSObject

+ (id)thanks;
+ (id)clip;
+ (id)report;
+ (id)hype;
+ (id)stopAds;
+ (NSArray *)supportedLanguages;
+ (NSString *)langCodeForIndex:(long long)index;
+ (unsigned long long)indexOfPreferredLanguage;

@end

#endif
