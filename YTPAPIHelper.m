#import "YTPAPIHelper.h"

@implementation YTPAPIHelper

+ (void)fetchChannelImageWithChannelID:(NSString *)channelID completion:(void (^)(UIImage *image))completion {
    NSString *urlString = @"https://youtubei.googleapis.com/youtubei/v1/browse?key=AIzaSyA8eiZmM1FaDVjRy_df2KTyQ_vz_yYM39w";

    NSDictionary *context = @{
        @"client": @{
            @"clientName": @"IOS",
            @"clientVersion": @"17.33.2",
            @"deviceModel": @"iPhone14,3",
            @"userAgent": @"com.google.ios.youtube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)",
            @"hl": @"en",
            @"gl": @"US"
        }
    };

    NSDictionary *body = @{
        @"context": context,
        @"browseId": channelID
    };

    NSError *serializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&serializationError];

    if (serializationError != nil) {
        NSLog(@"YTP - Serialization issue %@", serializationError);
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data == nil) {
            if (completion) {
                completion(nil);
            }
            return;
        }

        NSError *parseError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

        if (parseError != nil || responseDict == nil) {
            if (completion) {
                completion(nil);
            }
            return;
        }

        NSDictionary *header = [responseDict objectForKey:@"header"];
        NSDictionary *pageHeaderRenderer = [header objectForKey:@"pageHeaderRenderer"];
        NSDictionary *content = [pageHeaderRenderer objectForKey:@"content"];
        NSDictionary *pageHeaderViewModel = [content objectForKey:@"pageHeaderViewModel"];
        NSDictionary *image = [pageHeaderViewModel objectForKey:@"image"];
        NSDictionary *decoratedAvatarViewModel = [image objectForKey:@"decoratedAvatarViewModel"];
        NSDictionary *avatar = [decoratedAvatarViewModel objectForKey:@"avatar"];
        NSDictionary *avatarViewModel = [avatar objectForKey:@"avatarViewModel"];
        NSDictionary *avatarImage = [avatarViewModel objectForKey:@"image"];
        NSArray *sources = [avatarImage objectForKey:@"sources"];

        if (sources == nil || [sources count] == 0) {
            if (completion) {
                completion(nil);
            }
            return;
        }

        NSDictionary *firstSource = [sources objectAtIndex:0];
        NSString *imageURLString = [firstSource objectForKey:@"url"];

        if (imageURLString == nil) {
            if (completion) {
                completion(nil);
            }
            return;
        }

        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];

        if (imageData == nil) {
            if (completion) {
                completion(nil);
            }
            return;
        }

        UIImage *channelImage = [UIImage imageWithData:imageData];
        if (completion) {
            completion(channelImage);
        }
    }];

    [task resume];
}

@end
