#import "SRTParser.h"

@implementation SRTParser

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.entries = [NSMutableArray array];
        self.srtLines = [NSMutableArray array];
        self.subtitleIndex = 1;
        self.currentText = [NSMutableString string];
    }
    return self;
}

#pragma mark - Public Parse Methods

- (void)parseXMLFromURL:(NSURL *)url
            forLanguage:(NSString *)language
                videoID:(NSString *)videoID
             completion:(void (^)(NSString *srt, NSError *error))completion {
    self.isTranscriptMode = NO;
    self.srtLines = [NSMutableArray array];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        } else {
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            [parser setDelegate:self];
            BOOL success = [parser parse];

            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *parserError = [parser parserError];
                    completion(nil, parserError);
                });
            } else {
                NSError *srtError = nil;
                NSURL *srtResult = [self srtForLanguage:language videoID:videoID error:&srtError];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion((NSString *)srtResult, srtError);
                });
            }
        }
    }];
    [task resume];
}

- (NSURL *)srtForLanguage:(NSString *)language
                   videoID:(NSString *)videoID
                     error:(NSError **)error {
    NSString *tempDir = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:tempDir isDirectory:&isDirectory];

    if (!exists || !isDirectory) {
        [fileManager createDirectoryAtPath:tempDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:error];
        if (error != nil && *error != nil) {
            NSLog(@"[YTPlus] Error creating temporary directory: %@", [*error localizedDescription]);
            return nil;
        }
    }

    NSString *videoDir = [NSTemporaryDirectory() stringByAppendingPathComponent:videoID];
    [fileManager createDirectoryAtPath:videoDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    NSString *srtFilename = [NSString stringWithFormat:@"%@.srt", language];
    NSString *srtPath = [videoDir stringByAppendingPathComponent:srtFilename];
    NSURL *srtURL = [NSURL fileURLWithPath:srtPath];

    NSString *srtContent = [self.srtLines componentsJoinedByString:@"\n"];
    BOOL written = [srtContent writeToURL:srtURL atomically:YES encoding:NSUTF8StringEncoding error:error];

    if (!written) {
        if (error != nil && *error != nil) {
            NSLog(@"[YTPlus] Error while creating srt file: %@", [*error localizedDescription]);
        }
        return nil;
    }

    return srtURL;
}

- (void)parseTranscriptFromURL:(NSURL *)url
                    completion:(void (^)(NSString *transcript, NSError *error))completion {
    self.isTranscriptMode = YES;
    self.srtLines = [NSMutableArray array];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, error);
                }
            });
        } else {
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            [parser setDelegate:self];
            BOOL parseSuccess = [parser parse];

            if (!parseSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        NSError *parserError = [parser parserError];
                        completion(nil, parserError);
                    }
                });
            } else {
                NSString *transcript = [self.srtLines componentsJoinedByString:@" "];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(transcript, nil);
                    }
                });
            }
        }
    }];
    [task resume];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {

    if ([elementName isEqualToString:@"text"]) {
        NSString *startStr = [attributeDict objectForKey:@"start"];
        self.startTime = [startStr doubleValue];

        NSString *durStr = [attributeDict objectForKey:@"dur"];
        self.duration = [durStr doubleValue];

        self.endTime = self.startTime + self.duration;

        [self.currentText setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName {

    if ([elementName isEqualToString:@"text"]) {
        NSString *decoded = [self decodeHTMLChars:self.currentText];
        NSCharacterSet *whitespaceNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [decoded stringByTrimmingCharactersInSet:whitespaceNewline];

        if (!self.isTranscriptMode) {
            [self generateSRTWithText:trimmed];
        } else {
            [self generateTranscriptWithText:trimmed];
        }
    }
}

#pragma mark - SRT/Transcript Generation

- (void)generateSRTWithText:(NSString *)text {
    NSString *startFormatted = [self formatTime:self.startTime];
    NSString *endFormatted = [self formatTime:self.endTime];

    NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)self.subtitleIndex];
    [self.srtLines addObject:indexStr];

    NSString *timeRange = [NSString stringWithFormat:@"%@ --> %@", startFormatted, endFormatted];
    [self.srtLines addObject:timeRange];

    [self.srtLines addObject:text];
    [self.srtLines addObject:@""];

    self.subtitleIndex = self.subtitleIndex + 1;
}

- (void)generateTranscriptWithText:(NSString *)text {
    NSString *cleaned = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSCharacterSet *whitespaceNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [cleaned stringByTrimmingCharactersInSet:whitespaceNewline];
    [self.srtLines addObject:trimmed];
}

#pragma mark - Utilities

- (NSString *)formatTime:(double)timeInSeconds {
    long totalMilliseconds = (long)(timeInSeconds * 1000);
    long hours = totalMilliseconds / 3600000;
    long minutes = (totalMilliseconds % 3600000) / 60000;
    long seconds = (totalMilliseconds % 60000) / 1000;
    long millis = totalMilliseconds % 1000;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld,%03ld", hours, minutes, seconds, millis];
}

- (NSString *)decodeHTMLChars:(NSString *)text {
    NSMutableString *result = [NSMutableString stringWithString:text];

    NSDictionary *htmlEntities = @{
        @"&amp;"  : @"&",
        @"&lt;"   : @"<",
        @"&gt;"   : @">",
        @"&quot;" : @"\"",
        @"&#39;"  : @"'",
        @"&apos;" : @"'"
    };

    for (NSString *entity in htmlEntities) {
        NSString *replacement = [htmlEntities objectForKey:entity];
        [result replaceOccurrencesOfString:entity
                                withString:replacement
                                   options:0
                                     range:NSMakeRange(0, result.length)];
    }

    return result;
}

@end
