#import "YTLUserDefaultsFull.h"
#import <CommonCrypto/CommonDigest.h>

static YTLUserDefaults *_sharedInstance = nil;

@implementation YTLUserDefaults

#pragma mark - Singleton

+ (instancetype)standardUserDefaults {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YTLUserDefaults alloc] init];
        [_sharedInstance registerDefaults];
    });
    return _sharedInstance;
}

#pragma mark - Reset

- (void)reset {
    [self registerDefaults];
}

#pragma mark - Register Defaults

- (void)registerDefaults {
    NSDictionary *defaults = @{
        // Core features
        @"noAds":               @YES,
        @"backgroundPlayback":  @YES,
        @"downloadManager":     @YES,
        @"removeDownloadMenu":  @YES,
        @"frostedPivot":        @YES,

        // Audio/Download settings
        @"ytlAudioIndex":       @0,
        @"ytlButtonIndex":      @0,
        @"startupAnimation":    @0,

        // Playback settings
        @"speedIndex":          @3,
        @"autoSpeedIndex":      @4,
        @"wiFiQualityIndex":    @0,
        @"cellQualityIndex":    @0,

        // Gesture settings
        @"leftGestureIndex":    @0,
        @"rightGestureIndex":   @0,
        @"seekMethodIndex":     @0,
        @"gestWideness":        @5,
        @"seekSensitivity":     @7,

        // UI settings
        @"startupTab":          @"FEwhat_to_watch",
        @"idiomIndex":          @0,
        @"miniPlayerIndex":     @0,
        @"activeTabs":          @[],
        @"inactiveTabs":        @[],
        @"progressBarIndex":    @3,

        // Color settings (archived UIColor objects)
        @"progressMainColor":       [NSKeyedArchiver archivedDataWithRootObject:[UIColor redColor] requiringSecureCoding:NO error:nil],
        @"progressGradientColor":   [NSKeyedArchiver archivedDataWithRootObject:[UIColor redColor] requiringSecureCoding:NO error:nil],
        @"scrubberColor":           [NSKeyedArchiver archivedDataWithRootObject:[UIColor redColor] requiringSecureCoding:NO error:nil],
        @"customTrack":             @NO,
        @"customCaption":           @NO,

        // SponsorBlock settings
        @"sponsorBlock":            @YES,
        @"sbNotifications":         @YES,
        @"sbDuration":              @1,
        @"sbSkippedDuration":       @1,
        @"sb_sponsor":              @3,

        // SponsorBlock segment colors (archived UIColor objects)
        @"sb_sponsor_color":        [NSKeyedArchiver archivedDataWithRootObject:[UIColor greenColor] requiringSecureCoding:NO error:nil],
        @"sb_intro_color":          [NSKeyedArchiver archivedDataWithRootObject:[UIColor cyanColor] requiringSecureCoding:NO error:nil],
        @"sb_outro_color":          [NSKeyedArchiver archivedDataWithRootObject:[UIColor blueColor] requiringSecureCoding:NO error:nil],
        @"sb_interaction_color":    [NSKeyedArchiver archivedDataWithRootObject:[UIColor magentaColor] requiringSecureCoding:NO error:nil],
        @"sb_selfpromo_color":      [NSKeyedArchiver archivedDataWithRootObject:[UIColor yellowColor] requiringSecureCoding:NO error:nil],
        @"sb_music_offtopic_color": [NSKeyedArchiver archivedDataWithRootObject:[UIColor orangeColor] requiringSecureCoding:NO error:nil],
        @"sb_preview_color":        [NSKeyedArchiver archivedDataWithRootObject:[UIColor purpleColor] requiringSecureCoding:NO error:nil],
        @"sb_poi_highlight_color":  [NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor] requiringSecureCoding:NO error:nil],
        @"sb_filler_color":         [NSKeyedArchiver archivedDataWithRootObject:[UIColor grayColor] requiringSecureCoding:NO error:nil],

        // SponsorBlock user IDs
        @"sbPrivateUserID":         [[NSUUID UUID] UUIDString],
        @"sbPublicUserID":          @"",
    };

    [self registerDefaults:defaults];
}

#pragma mark - Color for Segment

- (UIColor *)colorForSegment:(NSString *)segment {
    NSString *key = [NSString stringWithFormat:@"sb_%@_color", segment];
    NSData *colorData = [self objectForKey:key];

    if (colorData == nil) {
        return nil;
    }

    NSError *error = nil;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                       fromData:colorData
                                                          error:&error];
    return color;
}

#pragma mark - SponsorBlock User IDs

- (NSString *)sbPrivateUserID {
    NSString *privateID = [self stringForKey:@"sbPrivateUserID"];

    if (privateID == nil || [privateID length] == 0) {
        privateID = [[NSUUID UUID] UUIDString];
        [self setObject:privateID forKey:@"sbPrivateUserID"];
    }

    return privateID;
}

- (NSString *)sbPublicUserID:(NSString *)privateID {
    if (privateID == nil || [privateID length] == 0) {
        return @"";
    }

    NSData *data = [privateID dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], hash);

    NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", hash[i]];
    }

    return [hashString copy];
}

#pragma mark - Import/Export Settings

- (void)importYtlSettings:(void (^)(BOOL success))completion {
    self.prefsPickerCompletion = completion;

    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[@"com.apple.property-list"]
        inMode:UIDocumentPickerModeImport];
    picker.delegate = self;

    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    [topVC presentViewController:picker animated:YES completion:nil];
}

- (void)presentDocumentPicker:(UIViewController *)viewController {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[@"com.apple.property-list"]
        inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    [viewController presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfURL:url];

    if (settings != nil) {
        for (NSString *key in settings) {
            id value = [settings objectForKey:key];
            [self setObject:value forKey:key];
        }
        if (self.prefsPickerCompletion) {
            self.prefsPickerCompletion(YES);
        }
    } else {
        if (self.prefsPickerCompletion) {
            self.prefsPickerCompletion(NO);
        }
    }
}

- (void)exportYtlSettings:(UIViewController *)viewController {
    NSDictionary *allSettings = [self dictionaryRepresentation];

    NSMutableDictionary *ytlSettings = [NSMutableDictionary dictionary];
    for (NSString *key in allSettings) {
        id value = [allSettings objectForKey:key];
        [ytlSettings setObject:value forKey:key];
    }

    NSString *tempDir = NSTemporaryDirectory();
    NSString *filePath = [tempDir stringByAppendingPathComponent:@"YTLiteSettings.plist"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:ytlSettings
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                                 options:0
                                                                   error:&error];
    if (plistData != nil) {
        [plistData writeToURL:fileURL atomically:YES];

        UIActivityViewController *activityVC = [[UIActivityViewController alloc]
            initWithActivityItems:@[fileURL]
            applicationActivities:nil];

        [viewController presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - Reset User Defaults

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [self removePersistentDomainForName:appDomain];
    [self registerDefaults];
}

@end
