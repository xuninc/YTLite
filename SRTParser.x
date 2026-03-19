// SRTParser.x - Subtitle/caption parsing
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

@interface SRTParser ()
@property (nonatomic, strong) NSMutableString *currentElement;
@property (nonatomic, strong) NSMutableArray *segments;
@property (nonatomic, assign) float currentStart;
@property (nonatomic, assign) float currentDuration;
@end

@implementation SRTParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _srtLines = [NSMutableArray array];
        _segments = [NSMutableArray array];
        _currentTextSuggestions = [NSMutableArray array];
    }
    return self;
}

#pragma mark - SRT Generation

- (NSString *)generateSRTWithText:(NSArray *)text {
    if (!text || text.count == 0) return nil;

    NSMutableString *srt = [NSMutableString string];
    NSInteger index = 1;

    for (NSDictionary *segment in text) {
        float start = [segment[@"tStartMs"] floatValue] / 1000.0;
        float duration = [segment[@"dDurationMs"] floatValue] / 1000.0;
        float end = start + duration;
        NSString *content = segment[@"segs"] ? [self extractText:segment[@"segs"]] : segment[@"utf8"];

        if (!content || content.length == 0) continue;

        [srt appendFormat:@"%ld\n", (long)index];
        [srt appendFormat:@"%@ --> %@\n", [self formatSRTTime:start], [self formatSRTTime:end]];
        [srt appendFormat:@"%@\n\n", content];

        index++;
    }

    return srt;
}

- (NSString *)generateTranscriptWithText:(NSArray *)text {
    if (!text || text.count == 0) return nil;

    NSMutableString *transcript = [NSMutableString string];

    for (NSDictionary *segment in text) {
        float start = [segment[@"tStartMs"] floatValue] / 1000.0;
        NSString *content = segment[@"segs"] ? [self extractText:segment[@"segs"]] : segment[@"utf8"];

        if (!content || content.length == 0) continue;

        [transcript appendFormat:@"[%@] %@\n", [self formatTranscriptTime:start], content];
    }

    return transcript;
}

- (NSString *)extractText:(NSArray *)segs {
    NSMutableString *text = [NSMutableString string];
    for (NSDictionary *seg in segs) {
        NSString *utf8 = seg[@"utf8"];
        if (utf8) [text appendString:utf8];
    }
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - SRT File Generation

- (NSString *)srtForLanguage:(NSString *)language videoID:(NSString *)videoID error:(NSError **)error {
    NSString *tempDir = [FFMpegHelper createTempDirectoryIfNeeded];
    NSString *srtPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.srt", videoID]];

    NSString *srtContent = [self generateSRTWithText:self.srtLines];
    if (!srtContent) {
        if (error) {
            *error = [NSError errorWithDomain:@"SRTParser" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to generate SRT content"}];
        }
        return nil;
    }

    NSError *writeError;
    [srtContent writeToFile:srtPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    if (writeError) {
        NSLog(@"YTPlus --- Error while creating srt file: %@", writeError);
        if (error) *error = writeError;
        return nil;
    }

    return srtPath;
}

#pragma mark - Caption Parsing

- (void)parseTranscriptFromURL:(NSString *)url completion:(void (^)(NSArray *result))completion {
    if (!url || url.length == 0) {
        if (completion) completion(nil);
        return;
    }

    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sharedSession];

    [[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSLog(@"YTPlus --- Error reading data from URL: %@", error);
            if (completion) completion(nil);
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || !json) {
            // Try XML parsing
            [self parseXMLData:data completion:completion];
            return;
        }

        // JSON format (timedtext)
        NSArray *events = json[@"events"];
        if (completion) completion(events);
    }] resume];
}

- (void)parseXMLFromURL:(NSString *)url forLanguage:(NSString *)language videoID:(NSString *)videoID completion:(void (^)(NSString *srtContent))completion {
    [self parseTranscriptFromURL:url completion:^(NSArray *result) {
        if (result) {
            self.srtLines = [result mutableCopy];
            NSString *srt = [self generateSRTWithText:result];
            if (completion) completion(srt);
        } else {
            if (completion) completion(nil);
        }
    }];
}

- (void)parseXMLData:(NSData *)data completion:(void (^)(NSArray *result))completion {
    self.segments = [NSMutableArray array];

    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];

    if (completion) completion(self.segments);
}

#pragma mark - Caption Track Helpers

- (NSArray *)captionsForDownloading:(id)playerResponse {
    // Extract available caption tracks from player response
    NSArray *captionTracks = nil;

    if ([playerResponse respondsToSelector:@selector(playerCaptionsTracklistRenderer)]) {
        id tracklistRenderer = [playerResponse performSelector:@selector(playerCaptionsTracklistRenderer)];
        if ([tracklistRenderer respondsToSelector:@selector(captionTracksArray)]) {
            captionTracks = [tracklistRenderer performSelector:@selector(captionTracksArray)];
        }
    }

    if (!captionTracks && [playerResponse isKindOfClass:[NSDictionary class]]) {
        captionTracks = playerResponse[@"captions"][@"playerCaptionsTracklistRenderer"][@"captionTracks"];
    }

    return captionTracks;
}

- (NSString *)titleForCaption:(id)caption {
    if ([caption isKindOfClass:[NSDictionary class]]) {
        NSDictionary *name = caption[@"name"];
        return name[@"simpleText"] ?: name[@"runs"][0][@"text"] ?: @"Unknown";
    }

    if ([caption respondsToSelector:@selector(name)]) {
        id name = [caption performSelector:@selector(name)];
        if ([name respondsToSelector:@selector(simpleText)]) {
            return [name performSelector:@selector(simpleText)];
        }
    }

    return @"Unknown";
}

- (NSString *)codeForCaps:(id)caption {
    if ([caption isKindOfClass:[NSDictionary class]]) {
        return caption[@"languageCode"] ?: @"en";
    }

    if ([caption respondsToSelector:@selector(languageCode)]) {
        return [caption performSelector:@selector(languageCode)];
    }

    return @"en";
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"text"]) {
        self.currentElement = [NSMutableString string];
        self.currentStart = [attributeDict[@"start"] floatValue];
        self.currentDuration = [attributeDict[@"dur"] floatValue];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentElement appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"text"] && self.currentElement) {
        NSDictionary *segment = @{
            @"tStartMs": @((long long)(self.currentStart * 1000)),
            @"dDurationMs": @((long long)(self.currentDuration * 1000)),
            @"utf8": [self.currentElement copy]
        };
        [self.segments addObject:segment];
        self.currentElement = nil;
    }
}

#pragma mark - Time Formatting

- (NSString *)formatSRTTime:(float)seconds {
    int hours = (int)seconds / 3600;
    int minutes = ((int)seconds % 3600) / 60;
    int secs = (int)seconds % 60;
    int millis = (int)((seconds - (int)seconds) * 1000);

    return [NSString stringWithFormat:@"%02d:%02d:%02d,%03d", hours, minutes, secs, millis];
}

- (NSString *)formatTranscriptTime:(float)seconds {
    int minutes = (int)seconds / 60;
    int secs = (int)seconds % 60;
    return [NSString stringWithFormat:@"%d:%02d", minutes, secs];
}

@end
