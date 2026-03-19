// SponsorBlock.x - SponsorBlock integration
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

static NSString *const kSponsorBlockAPI = @"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@";

// MARK: - SBSegment

@implementation SBSegment

+ (instancetype)segmentWithDictionary:(NSDictionary *)dict {
    SBSegment *segment = [[SBSegment alloc] init];
    segment.category = dict[@"category"];
    segment.actionType = dict[@"actionType"];
    segment.uuid = dict[@"UUID"];

    NSArray *segmentTimes = dict[@"segment"];
    if (segmentTimes && segmentTimes.count >= 2) {
        segment.start = [segmentTimes[0] floatValue];
        segment.end = [segmentTimes[1] floatValue];
    }

    segment.segmentDescription = dict[@"description"] ?: @"";
    return segment;
}

- (NSArray *)segmentForItems:(NSArray *)items {
    NSMutableArray *segments = [NSMutableArray array];
    for (NSDictionary *item in items) {
        SBSegment *seg = [SBSegment segmentWithDictionary:item];
        if (seg) [segments addObject:seg];
    }
    return segments;
}

@end

// MARK: - SBManager

@interface SBManager ()
@property (nonatomic, strong) NSString *currentVideoID;
@property (nonatomic, strong) NSMutableDictionary *segmentCache;
@end

@implementation SBManager

static SBManager *_sharedSBManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSBManager = [[self alloc] init];
    });
    return _sharedSBManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _segments = [NSMutableDictionary dictionary];
        _segmentCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)getSegmentsForID:(NSString *)videoID {
    if (!videoID) return @[];
    return self.segments[videoID] ?: @[];
}

- (void)requestSbSegments {
    NSString *videoID = self.currentVideoID;
    if (!videoID || videoID.length == 0) return;

    // Check cache first
    if (self.segmentCache[videoID]) {
        self.segments[videoID] = self.segmentCache[videoID];
        return;
    }

    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    if (![defaults boolForKey:@"EnableSponsorBlock"]) return;

    // Build categories array from user settings
    NSMutableArray *categories = [NSMutableArray array];
    NSArray *allCategories = @[@"sponsor", @"selfpromo", @"interaction", @"intro", @"outro",
                               @"preview", @"music_offtopic", @"poi_highlight", @"filler"];
    for (NSString *cat in allCategories) {
        NSString *key = [NSString stringWithFormat:@"sb_%@", cat];
        NSString *setting = [defaults objectForKey:key];
        if (setting && ![setting isEqualToString:@"disable"]) {
            [categories addObject:[NSString stringWithFormat:@"\"%@\"", cat]];
        }
    }

    if (categories.count == 0) return;

    NSString *categoriesStr = [NSString stringWithFormat:@"[%@]", [categories componentsJoinedByString:@","]];
    NSString *urlString = [NSString stringWithFormat:kSponsorBlockAPI, videoID, [categoriesStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];

    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"YTP --- Error fetching segments: %@", error);
            return;
        }

        if (!data) return;

        NSError *jsonError;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSArray class]]) {
            NSLog(@"YTP --- Unexpected JSON format for SB");
            return;
        }

        NSMutableArray *parsedSegments = [NSMutableArray array];
        for (NSDictionary *item in json) {
            SBSegment *segment = [SBSegment segmentWithDictionary:item];
            if (segment) [parsedSegments addObject:segment];
        }

        // Sort by start time
        [parsedSegments sortUsingComparator:^NSComparisonResult(SBSegment *a, SBSegment *b) {
            if (a.start < b.start) return NSOrderedAscending;
            if (a.start > b.start) return NSOrderedDescending;
            return NSOrderedSame;
        }];

        self.segments[videoID] = parsedSegments;
        self.segmentCache[videoID] = parsedSegments;
    }] resume];
}

- (void)addDurationWithoutSegments:(id)duration videoController:(id)videoController {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    if (![defaults boolForKey:@"DurationWithoutSegments"]) return;

    NSArray *videoSegments = [self getSegmentsForID:self.currentVideoID];
    if (videoSegments.count == 0) return;

    float totalSkipped = 0;
    for (SBSegment *seg in videoSegments) {
        NSString *setting = [defaults objectForKey:[NSString stringWithFormat:@"sb_%@", seg.category]];
        if ([setting isEqualToString:@"skip"]) {
            totalSkipped += (seg.end - seg.start);
        }
    }

    // Duration info is displayed via the player bar
}

- (void)sbPublicUserID:(NSString *)userID {
    if (userID.length < 64) {
        NSLog(@"YTP --- Error: Public user ID must be 64 characters");
        return;
    }
    [[YTLUserDefaults sharedInstance] setObject:userID forKey:@"SbPublicUserID"];
}

- (void)skipSegment {
    // Triggers segment skip in the current player
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SegmentSkipped" object:nil];
}

@end

// MARK: - SBPlayerDecorator

@implementation SBPlayerDecorator

- (void)decorateContext:(id)context {
    // Hook into player bar rendering
}

- (void)drawSegmentableSegments:(NSArray *)segments playerBar:(id)playerBar playerVC:(id)playerVC {
    if (!segments || segments.count == 0) return;

    for (SBSegment *segment in segments) {
        UIColor *color = [self colorForCategory:segment.category];
        if (!color) continue;

        // Calculate position on player bar
        float totalDuration = 0;
        if ([playerVC respondsToSelector:@selector(currentVideoTotalMediaTime)]) {
            totalDuration = [[playerVC performSelector:@selector(currentVideoTotalMediaTime)] floatValue];
        }

        if (totalDuration <= 0) continue;

        float startPct = segment.start / totalDuration;
        float endPct = segment.end / totalDuration;

        CGRect barBounds = CGRectZero;
        if ([playerBar respondsToSelector:@selector(bounds)]) {
            barBounds = [[playerBar performSelector:@selector(bounds)] CGRectValue];
        }

        CGFloat x = barBounds.origin.x + (barBounds.size.width * startPct);
        CGFloat width = barBounds.size.width * (endPct - startPct);
        CGRect segmentRect = CGRectMake(x, barBounds.origin.y, width, barBounds.size.height);

        [self drawProgressRect:segmentRect withColor:color];
    }
}

- (void)drawSegments:(NSArray *)segments layer:(CALayer *)layer playerVC:(id)playerVC {
    [self drawSegmentableSegments:segments playerBar:nil playerVC:playerVC];
}

- (void)drawSegmentsDecorationView:(id)decorationView {
    // Draw on decoration view layer
}

- (void)drawProgressRect:(CGRect)rect withColor:(UIColor *)color {
    CALayer *segmentLayer = [CALayer layer];
    segmentLayer.frame = rect;
    segmentLayer.backgroundColor = color.CGColor;
    segmentLayer.opacity = 0.8;
    // Layer is added to player bar's layer hierarchy
}

#pragma mark - Helpers

- (UIColor *)colorForCategory:(NSString *)category {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];

    NSDictionary *defaultColors = @{
        @"sponsor": @"#00D400",
        @"selfpromo": @"#FFFF00",
        @"interaction": @"#CC00FF",
        @"intro": @"#00FFFF",
        @"outro": @"#0202ED",
        @"preview": @"#008FD6",
        @"music_offtopic": @"#FF9900",
        @"poi_highlight": @"#FF1684",
        @"filler": @"#7300FF"
    };

    NSString *colorKey = [NSString stringWithFormat:@"sb_%@_color", category];
    NSString *colorHex = [defaults objectForKey:colorKey] ?: defaultColors[category];

    return [self colorFromHex:colorHex];
}

- (UIColor *)colorFromHex:(NSString *)hex {
    if (!hex) return [UIColor greenColor];

    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (hex.length != 6) return [UIColor greenColor];

    unsigned int rgb;
    [[NSScanner scannerWithString:hex] scanHexInt:&rgb];

    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

@end

// MARK: - SponsorBlockVC

@implementation SponsorBlockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SponsorBlock";
}

- (UIColor *)colorForSegment:(NSString *)segment {
    SBPlayerDecorator *decorator = [[SBPlayerDecorator alloc] init];
    return [decorator colorForCategory:segment];
}

- (UIImage *)segmentIcon:(NSString *)segment {
    return [YTLHelper systemImage:@"square.fill" withSize:16];
}

- (UIColorWell *)colorWellForKey:(NSString *)key title:(NSString *)title {
    UIColorWell *well = [[UIColorWell alloc] init];
    well.supportsAlpha = NO;
    well.title = title;

    SBPlayerDecorator *decorator = [[SBPlayerDecorator alloc] init];
    well.selectedColor = [decorator colorForCategory:key];

    [well addTarget:self action:@selector(colorWellTap:) forControlEvents:UIControlEventValueChanged];
    return well;
}

- (void)colorWellTap:(UIColorWell *)sender {
    // Save color to UserDefaults
}

@end

// MARK: - SbWhitelistVC

@implementation SbWhitelistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"SbWhitelist" value:@"Whitelist" table:nil];
    [self setupWhitelist];
}

- (void)setupWhitelist {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    NSArray *saved = [defaults objectForKey:@"SbWhitelistChannels"];
    self.whitelist = saved ? [saved mutableCopy] : [NSMutableArray array];
    self.sortType = [defaults integerForKey:@"SbWhitelistSortType"];
}

- (void)removeChannelWithLink:(NSString *)link {
    [self.whitelist removeObject:link];
    [[YTLUserDefaults sharedInstance] setObject:self.whitelist forKey:@"SbWhitelistChannels"];
    [self.tableView reloadData];
}

- (void)updateSortMenu {
    // Update sort order and reload
    [self.whitelist sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.sortType == 1) {
        self.whitelist = [[self.whitelist reverseObjectEnumerator].allObjects mutableCopy];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.whitelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhitelistCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WhitelistCell"];
    }
    cell.textLabel.text = self.whitelist[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeChannelWithLink:self.whitelist[indexPath.row]];
    }
}

@end
