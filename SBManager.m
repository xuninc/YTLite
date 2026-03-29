#import "SBManager.h"
#import "SBSegment.h"

@implementation SBManager

static SBManager *_sharedManager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SBManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Serialize SponsorBlock category list to JSON
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self sponsorBlockCategories]
                                                          options:0
                                                            error:nil];
        // Create string from JSON data
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // URL-encode the string
        NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSString *encodedString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        // Store encoded categories string
        _encodedCategories = encodedString;
        // Create mutable dictionary for segment cache
        _segments = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)getSegmentsForID:(NSString *)videoID {
    // Check if SponsorBlock is enabled
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"sponsorBlock_enabled"]) {
        return;
    }
    // Build URL string
    NSString *urlString = [NSString stringWithFormat:
        @"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@",
        videoID, self.encodedCategories];
    // Create URL and request
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // Get shared URL session and create data task
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleSegmentsResponse:data error:error videoID:videoID];
    }];
    [task resume];
}

- (void)handleSegmentsResponse:(NSData *)data error:(NSError *)error videoID:(NSString *)videoID {
    if (data == nil || error != nil) {
        NSLog(@"YTP - Error fetching segments: %@", error);
        return;
    }
    // Parse JSON
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError != nil || ![jsonObject isKindOfClass:[NSArray class]]) {
        NSLog(@"YTP - Error fetching segments: %@", jsonError);
        return;
    }
    // Create mutable array of SBSegment objects
    NSArray *jsonArray = (NSArray *)jsonObject;
    NSMutableArray *segmentArray = [NSMutableArray array];
    // For each dictionary in array, create SBSegment and add if non-nil
    for (NSDictionary *dict in jsonArray) {
        SBSegment *segment = [SBSegment segmentWithDictionary:dict];
        if (segment != nil) {
            [segmentArray addObject:segment];
        }
    }
    // Store in segments cache
    [self.segments setObject:segmentArray forKey:videoID];
}

@end
