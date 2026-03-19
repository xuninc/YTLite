// YTPAPIHelper.x - YouTube API parsing for video/audio formats
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

@implementation YTPAPIHelper

static YTPAPIHelper *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Video Format Extraction

- (NSArray *)getVideoFormatsArray:(id)playerResponse isShorts:(BOOL)isShorts {
    NSDictionary *streamingData = [self streamingDataFromResponse:playerResponse];
    if (!streamingData) return @[];

    NSArray *adaptiveFormats = streamingData[@"adaptiveFormats"];
    if (!adaptiveFormats) return @[];

    NSMutableArray *videoFormats = [NSMutableArray array];

    for (NSDictionary *format in adaptiveFormats) {
        NSString *mimeType = format[@"mimeType"];
        if (!mimeType || ![mimeType hasPrefix:@"video/"]) continue;

        NSString *url = format[@"url"];
        if (!url || url.length == 0) continue;

        NSString *qualityLabel = format[@"qualityLabel"];
        NSNumber *contentLength = format[@"contentLength"];

        if (!contentLength || [contentLength longLongValue] == 0) continue;

        NSMutableDictionary *formatDict = [format mutableCopy];
        if (qualityLabel) formatDict[@"qualityLabel"] = qualityLabel;

        [videoFormats addObject:formatDict];
    }

    // Sort by quality (highest first)
    [videoFormats sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        NSInteger heightA = [a[@"height"] integerValue];
        NSInteger heightB = [b[@"height"] integerValue];
        return heightB - heightA;
    }];

    // For Shorts, filter to only mp4 with best quality
    if (isShorts) {
        NSMutableArray *shortsFormats = [NSMutableArray array];
        for (NSDictionary *format in videoFormats) {
            NSString *mimeType = format[@"mimeType"];
            if ([mimeType containsString:@"video/mp4"]) {
                [shortsFormats addObject:format];
                break; // Best quality mp4 only for Shorts
            }
        }
        return shortsFormats.count > 0 ? shortsFormats : videoFormats;
    }

    return videoFormats;
}

- (NSArray *)getAudioFormatsArray:(id)playerResponse {
    NSDictionary *streamingData = [self streamingDataFromResponse:playerResponse];
    if (!streamingData) return @[];

    NSArray *adaptiveFormats = streamingData[@"adaptiveFormats"];
    if (!adaptiveFormats) return @[];

    NSMutableArray *audioFormats = [NSMutableArray array];

    for (NSDictionary *format in adaptiveFormats) {
        NSString *mimeType = format[@"mimeType"];
        if (!mimeType || ![mimeType hasPrefix:@"audio/"]) continue;

        NSString *url = format[@"url"];
        if (!url || url.length == 0) continue;

        [audioFormats addObject:format];
    }

    // Sort by bitrate (highest first)
    [audioFormats sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        NSInteger bitrateA = [a[@"bitrate"] integerValue];
        NSInteger bitrateB = [b[@"bitrate"] integerValue];
        return bitrateB - bitrateA;
    }];

    return audioFormats;
}

- (NSDictionary *)getBestAudioFormat:(id)playerResponse playerVC:(UIViewController *)playerVC {
    NSArray *audioFormats = [self getAudioFormatsArray:playerResponse];
    if (audioFormats.count == 0) return nil;

    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    BOOL preferDrc = [defaults boolForKey:@"AudioDRC"];

    // Try to find preferred audio track
    NSDictionary *preferred = [self getDefaultAudioTrack:playerResponse];
    if (preferred) return preferred;

    // Filter by DRC preference
    if (preferDrc) {
        for (NSDictionary *format in audioFormats) {
            if ([format[@"isDrc"] boolValue]) return format;
        }
    }

    // Return highest bitrate
    return audioFormats.firstObject;
}

- (NSDictionary *)getDefaultAudioTrack:(id)playerResponse {
    NSArray *audioFormats = [self getAudioFormatsArray:playerResponse];

    for (NSDictionary *format in audioFormats) {
        NSDictionary *audioTrack = format[@"audioTrack"];
        if (audioTrack && [audioTrack[@"audioIsDefault"] boolValue]) {
            return format;
        }
    }

    return audioFormats.firstObject;
}

- (NSDictionary *)getEnglishAudioTrack:(id)playerResponse {
    NSArray *audioFormats = [self getAudioFormatsArray:playerResponse];

    for (NSDictionary *format in audioFormats) {
        NSDictionary *audioTrack = format[@"audioTrack"];
        NSString *trackId = audioTrack[@"id"];
        if (trackId && ([trackId hasPrefix:@"en"] || [trackId containsString:@".en"])) {
            return format;
        }
    }

    return nil;
}

#pragma mark - Format Helpers

- (NSString *)getExtension:(NSDictionary *)format {
    NSString *mimeType = format[@"mimeType"];
    if (!mimeType) return @"mp4";

    if ([mimeType containsString:@"video/mp4"] || [mimeType containsString:@"audio/mp4"]) return @"mp4";
    if ([mimeType containsString:@"audio/webm"]) return @"webm";
    if ([mimeType containsString:@"video/webm"]) return @"webm";
    if ([mimeType containsString:@"audio/mp4a"]) return @"m4a";

    return @"mp4";
}

- (NSString *)getResoForQuality:(NSDictionary *)format {
    NSString *qualityLabel = format[@"qualityLabel"];
    if (qualityLabel) return qualityLabel;

    NSInteger height = [format[@"height"] integerValue];
    if (height > 0) return [NSString stringWithFormat:@"%ldp", (long)height];

    return @"Unknown";
}

#pragma mark - Thumbnail

- (NSString *)getThumbnail:(id)playerResponse {
    NSArray *thumbnails = [self thumbnailsFromResponse:playerResponse];
    if (!thumbnails || thumbnails.count == 0) return nil;

    // Get highest quality thumbnail
    NSDictionary *best = thumbnails.lastObject;
    return best[@"url"];
}

#pragma mark - Channel Image

- (void)fetchChannelImageWithChannelID:(NSString *)channelID completion:(void (^)(UIImage *image))completion {
    if (!channelID || channelID.length == 0) {
        if (completion) completion(nil);
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"https://youtubei.googleapis.com/youtubei/v1/browse?key=AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w"];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{
        @"context": @{
            @"client": @{
                @"clientName": @"IOS",
                @"clientVersion": @"19.29.1"
            }
        },
        @"browseId": channelID
    };

    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [request setHTTPBody:bodyData];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSLog(@"YTP --- Failed to fetch: %@", error);
            if (completion) completion(nil);
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"YTP --- Serialization issue: %@", jsonError);
            if (completion) completion(nil);
            return;
        }

        // Extract avatar URL from response
        NSDictionary *header = json[@"header"][@"c4TabbedHeaderRenderer"];
        NSString *avatarUrl = header[@"avatar"][@"thumbnails"].lastObject[@"url"];

        if (avatarUrl) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]];
            UIImage *image = imageData ? [UIImage imageWithData:imageData] : nil;
            if (completion) completion(image);
        } else {
            NSLog(@"YTP --- Pfp not found");
            if (completion) completion(nil);
        }
    }] resume];
}

#pragma mark - Response Handling

- (void)handleResponse:(id)response error:(NSError *)error completion:(void (^)(NSDictionary *result))completion {
    if (error) {
        NSLog(@"YTP --- Request failed: %@", error);
        if (completion) completion(nil);
        return;
    }
    [self handleResponse:response withCompletion:completion];
}

- (void)handleLegacyResponse:(id)response error:(NSError *)error completion:(void (^)(NSDictionary *result))completion {
    [self handleResponse:response error:error completion:completion];
}

- (void)handleResponse:(id)response withCompletion:(void (^)(NSDictionary *result))completion {
    if (!response) {
        if (completion) completion(nil);
        return;
    }

    if ([response isKindOfClass:[NSDictionary class]]) {
        if (completion) completion(response);
    } else if ([response isKindOfClass:[NSData class]]) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
        if (error) {
            NSLog(@"YTP --- Serialization issue: %@", error);
            if (completion) completion(nil);
        } else {
            if (completion) completion(json);
        }
    } else {
        NSLog(@"YTP --- Unexpected JSON format for SB");
        if (completion) completion(nil);
    }
}

#pragma mark - Internal Helpers

- (NSDictionary *)streamingDataFromResponse:(id)playerResponse {
    if ([playerResponse isKindOfClass:[NSDictionary class]]) {
        return playerResponse[@"streamingData"];
    }

    // Try to access via protobuf-like accessor
    if ([playerResponse respondsToSelector:@selector(streamingData)]) {
        return [playerResponse performSelector:@selector(streamingData)];
    }

    return nil;
}

- (NSArray *)thumbnailsFromResponse:(id)playerResponse {
    if ([playerResponse isKindOfClass:[NSDictionary class]]) {
        return playerResponse[@"videoDetails"][@"thumbnail"][@"thumbnails"];
    }

    if ([playerResponse respondsToSelector:@selector(videoDetails)]) {
        id videoDetails = [playerResponse performSelector:@selector(videoDetails)];
        if ([videoDetails respondsToSelector:@selector(thumbnail)]) {
            id thumbnail = [videoDetails performSelector:@selector(thumbnail)];
            if ([thumbnail respondsToSelector:@selector(thumbnailsArray)]) {
                return [thumbnail performSelector:@selector(thumbnailsArray)];
            }
        }
    }

    return nil;
}

- (NSArray *)adaptiveFormatsArray {
    return nil; // Populated from current playerResponse context
}

- (NSDictionary *)streamingData {
    return nil; // Populated from current playerResponse context
}

- (NSArray *)thumbnailsArray {
    return nil; // Populated from current playerResponse context
}

@end
