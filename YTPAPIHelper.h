#ifndef YTPAPIHelper_h
#define YTPAPIHelper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTPAPIHelper : NSObject

+ (void)fetchChannelImageWithChannelID:(NSString *)channelID completion:(void (^)(UIImage *image))completion;

@end

#endif /* YTPAPIHelper_h */
