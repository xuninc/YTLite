#ifndef SRTParser_h
#define SRTParser_h

#import <Foundation/Foundation.h>

@interface SRTParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic, strong) NSMutableString *currentText;
@property (nonatomic, strong) NSMutableArray *srtLines;
@property (nonatomic, assign) NSInteger subtitleIndex;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double endTime;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) BOOL isTranscriptMode;

- (instancetype)init;

- (void)parseXMLFromURL:(NSURL *)url
            forLanguage:(NSString *)language
                videoID:(NSString *)videoID
             completion:(void (^)(NSString *srt, NSError *error))completion;

- (NSURL *)srtForLanguage:(NSString *)language
                   videoID:(NSString *)videoID
                     error:(NSError **)error;

- (void)parseTranscriptFromURL:(NSURL *)url
                    completion:(void (^)(NSString *transcript, NSError *error))completion;

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName;

- (void)generateSRTWithText:(NSString *)text;
- (void)generateTranscriptWithText:(NSString *)text;
- (NSString *)formatTime:(double)seconds;
- (NSString *)decodeHTMLChars:(NSString *)string;

@end

#endif /* SRTParser_h */
