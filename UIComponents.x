// UIComponents.x - UI components (BlurButton, ShareImageViewController, WelcomeVC, AudioManager, YTLHelper)
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"
#import <objc/runtime.h>
#import <SystemConfiguration/SystemConfiguration.h>

// MARK: - BlurButton

@implementation BlurButton

+ (UIButton *)createOverlayButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = accessibilityLabel;

    UIImage *image = [UIImage systemImageNamed:icon];
    if (!image) image = [YTLHelper ytlImageWithName:icon];

    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];

    // Add blur background
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = CGRectMake(0, 0, 40, 40);
    blurView.layer.cornerRadius = 20;
    blurView.clipsToBounds = YES;
    blurView.userInteractionEnabled = NO;
    [button insertSubview:blurView atIndex:0];

    button.frame = CGRectMake(0, 0, 40, 40);

    return button;
}

+ (UIButton *)createYTQTMButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon selector:(SEL)selector {
    return [self createYTQTMButton:name accessibilityLabel:accessibilityLabel buttonLabel:buttonLabel icon:icon size:40 selector:selector];
}

+ (UIButton *)createYTQTMButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon size:(CGFloat)size selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = accessibilityLabel;

    UIImage *image = [UIImage systemImageNamed:icon];
    if (!image) image = [YTLHelper ytlImageWithName:icon];

    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:size * 0.5 weight:UIImageSymbolWeightMedium];
    if (image && [image respondsToSelector:@selector(imageByApplyingSymbolConfiguration:)]) {
        image = [image imageByApplyingSymbolConfiguration:config];
    }

    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(0, 0, size, size);

    return button;
}

@end

// MARK: - AudioManager

@implementation AudioManager

static AudioManager *_sharedAudioManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAudioManager = [[self alloc] init];
    });
    return _sharedAudioManager;
}

- (void)playAudio {
    if (!self.audioPlayer) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SponsorAudio" ofType:@"m4a"];
        if (!path) {
            // Try YTLite bundle
            NSBundle *ytlBundle = [NSBundle bundleWithPath:@"/Library/Application Support/YTLite.bundle"];
            path = [ytlBundle pathForResource:@"SponsorAudio" ofType:@"m4a"];
        }

        if (path) {
            NSError *error;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
            if (error) {
                NSLog(@"YTPlus --- Unable to init player: %@", error);
                return;
            }
        }
    }

    NSError *catError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&catError];
    if (catError) {
        NSLog(@"YTPlus --- Unable to set category: %@", catError);
    }

    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)stopAudio {
    [self.audioPlayer stop];
    self.audioPlayer.currentTime = 0;
}

@end

// MARK: - ShareImageViewController

@implementation ShareImageViewController

- (instancetype)initWithSelectedImageURL:(NSURL *)selectedImageURL updatedImageURL:(NSURL *)updatedImageURL {
    self = [super init];
    if (self) {
        if (updatedImageURL) {
            NSData *data = [NSData dataWithContentsOfURL:updatedImageURL];
            if (data) _fullImage = [UIImage imageWithData:data];
        } else if (selectedImageURL) {
            NSData *data = [NSData dataWithContentsOfURL:selectedImageURL];
            if (data) _fullImage = [UIImage imageWithData:data];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    if (self.fullImage) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.fullImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = self.view.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:imageView];
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionsheetShareImage)];
}

- (void)genImageFromLayer:(CALayer *)layer backgroundColor:(UIColor *)backgroundColor completionHandler:(void (^)(UIImage *image))completionHandler {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:layer.bounds.size];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        if (backgroundColor) {
            [backgroundColor setFill];
            [ctx fillRect:layer.bounds];
        }
        [layer renderInContext:ctx.CGContext];
    }];
    if (completionHandler) completionHandler(image);
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

- (void)shareMedia:(id)media {
    if (!media) return;
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[media] applicationActivities:nil];
    if (activityVC.popoverPresentationController) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = self.view.bounds;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)actionsheetShareImage {
    if (self.fullImage) {
        [self shareMedia:self.fullImage];
    }
}

@end

// MARK: - WelcomeVC

@implementation WelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
}

- (void)showDonationReminder:(UIViewController *)presenter {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    if ([defaults boolForKey:@"NoDonationReminder"]) return;

    NSString *localizedMessage = [[NSBundle mainBundle] localizedStringForKey:@"DonationReminder" value:@"Your support helps to make YouTube Plus even better." table:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"YouTube Plus" message:localizedMessage preferredStyle:UIAlertControllerStyleAlert];

    NSString *localizedSupport = [[NSBundle mainBundle] localizedStringForKey:@"SupportMe" value:@"Support me" table:nil];
    [alert addAction:[UIAlertAction actionWithTitle:localizedSupport style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showDonationSheet:presenter];
    }]];

    NSString *localizedDismiss = [[NSBundle mainBundle] localizedStringForKey:@"NoDonationReminder" value:@"Disable donation reminder" table:nil];
    [alert addAction:[UIAlertAction actionWithTitle:localizedDismiss style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [defaults setBool:YES forKey:@"NoDonationReminder"];
    }]];

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [alert addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)showDonationSheet:(UIViewController *)presenter {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"SupportDevelopment" value:@"Support development" table:nil] message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSDictionary *links = @{
        @"GitHub Sponsors": @"https://github.com/sponsors/dayanch96",
        @"Patreon": @"https://www.patreon.com/dayanch96",
        @"Buy Me a Coffee": @"https://www.buymeacoffee.com/dayanch96",
        @"Boosty": @"https://boosty.to/dayanch96"
    };

    for (NSString *title in links) {
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:links[title]] options:@{} completionHandler:nil];
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil] style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = presenter.view;
        sheet.popoverPresentationController.sourceRect = presenter.view.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

@end

// MARK: - YTLHelper

@implementation YTLHelper

+ (UIViewController *)topViewControllerForPresenting {
    UIWindow *window = [self appKeyWindow];
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc visibleViewController] ?: vc;
    }
    return vc;
}

+ (UIViewController *)closestViewController:(UIView *)view {
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

+ (UIWindow *)appKeyWindow {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) return window;
            }
        }
    }
    return nil;
}

+ (NSString *)appName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] ?: @"YouTube";
}

+ (NSString *)shortAppName {
    return @"YTPlus";
}

+ (NSString *)appID {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)bundleId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)bundleSeedID {
    NSDictionary *query = @{
        (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassGenericPassword,
        (__bridge NSString *)kSecAttrAccount: @"bundleSeedID",
        (__bridge NSString *)kSecAttrService: @"",
        (__bridge NSString *)kSecReturnAttributes: @YES
    };
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);

    if (status == errSecItemNotFound) {
        NSDictionary *addQuery = @{
            (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassGenericPassword,
            (__bridge NSString *)kSecAttrAccount: @"bundleSeedID",
            (__bridge NSString *)kSecAttrService: @"",
            (__bridge NSString *)kSecReturnAttributes: @YES
        };
        status = SecItemAdd((__bridge CFDictionaryRef)addQuery, (CFTypeRef *)&result);
    }

    if (status == noErr && result) {
        NSDictionary *dict = (__bridge_transfer NSDictionary *)result;
        NSString *accessGroup = dict[(__bridge NSString *)kSecAttrAccessGroup];
        NSArray *components = [accessGroup componentsSeparatedByString:@"."];
        return components.firstObject ?: @"";
    }

    return @"";
}

+ (NSString *)sharedAccessGroup {
    NSString *seed = [self bundleSeedID];
    NSString *bundleId = [self bundleId];
    return [NSString stringWithFormat:@"%@.%@", seed, bundleId];
}

+ (BOOL)isFromAppStore {
    return [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"_CodeSignature"]];
}

+ (BOOL)isiPad {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)isRTL {
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

+ (BOOL)isLandscape {
    UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        return UIInterfaceOrientationIsLandscape(scene.interfaceOrientation);
    }
    return NO;
}

+ (BOOL)isConnectedToWiFi {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com");
    if (!reachability) return NO;

    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(reachability, &flags)) {
        CFRelease(reachability);
        return NO;
    }
    CFRelease(reachability);

    BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    BOOL isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;

    return isReachable && !isWWAN;
}

+ (long long)freeDeviceStorageBytes {
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [attrs[NSFileSystemFreeSize] longLongValue];
}

+ (NSString *)formatTime:(long long)time {
    long long hours = time / 3600;
    long long minutes = (time % 3600) / 60;
    long long seconds = time % 60;

    if (hours > 0) {
        return [NSString stringWithFormat:@"%lld:%02lld:%02lld", hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%lld:%02lld", minutes, seconds];
}

+ (NSString *)darkFormatTime:(long long)time {
    return [self formatTime:time]; // Same format, different styling in UI
}

+ (NSString *)decodeHTML:(NSString *)html {
    if (!html) return nil;
    NSString *decoded = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"'"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return decoded;
}

+ (UIImage *)ytlImageWithName:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/YTLite.bundle"];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (UIImage *)cellImageWithName:(NSString *)name {
    UIImage *image = [self ytlImageWithName:name];
    if (!image) image = [UIImage systemImageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)imageWithName:(NSString *)name {
    return [self ytlImageWithName:name] ?: [UIImage systemImageNamed:name];
}

+ (UIImage *)imageNamed:(NSString *)name withSize:(CGFloat)size {
    UIImage *image = [self imageWithName:name];
    if (!image) return nil;

    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:size];
    if ([image respondsToSelector:@selector(imageByApplyingSymbolConfiguration:)]) {
        return [image imageByApplyingSymbolConfiguration:config];
    }

    return [self resizeImage:image toSize:CGSizeMake(size, size)];
}

+ (UIImage *)systemImage:(NSString *)name withSize:(CGFloat)size {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:size];
    return [[UIImage systemImageNamed:name] imageByApplyingSymbolConfiguration:config];
}

+ (UIImage *)originalImageWithName:(NSString *)name {
    UIImage *image = [self ytlImageWithName:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (UIImage *)iconImageNamed:(NSString *)name {
    return [self imageNamed:name withSize:22];
}

+ (UIImage *)iconCheckWithColor:(UIColor *)color {
    UIImage *check = [UIImage systemImageNamed:@"checkmark"];
    return [check imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

+ (void)fireHapticFeedback {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator impactOccurred];
}

+ (void)prepareHapticFeedback {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator prepare];
}

+ (NSString *)systemLanguage {
    return [[NSLocale preferredLanguages] firstObject] ?: @"en";
}

+ (NSArray *)supportedLanguages {
    return @[@"en", @"ru", @"ar", @"es", @"fr", @"it", @"ja", @"ko", @"pl", @"tr", @"vi", @"zh-Hans", @"zh-Hant"];
}

+ (void)clearCache:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *contents = [fm subpathsOfDirectoryAtPath:cachePath error:nil];

        for (NSString *item in contents) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:item];
            [fm removeItemAtPath:fullPath error:nil];
        }

        // Also clear temp downloads
        NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"YTLiteDownloads"];
        [fm removeItemAtPath:tempDir error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    });
}

+ (void)getCacheSizeWithCompletion:(void (^)(NSString *size))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *contents = [fm subpathsOfDirectoryAtPath:cachePath error:nil];

        unsigned long long totalSize = 0;
        for (NSString *item in contents) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:item];
            NSDictionary *attrs = [fm attributesOfItemAtPath:fullPath error:nil];
            totalSize += [attrs fileSize];
        }

        NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(sizeStr);
        });
    });
}

+ (void)presentDocumentPicker:(UIViewController *)presenter {
    NSArray *types = @[@"public.data"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    picker.delegate = (id)presenter;
    [presenter presentViewController:picker animated:YES completion:nil];
}

@end

// MARK: - YTLTableViewCell

@implementation YTLTableViewCell
@end

// MARK: - YTPDB

@implementation YTPDB

static YTPDB *_sharedYTPDB = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedYTPDB = [[self alloc] init];
    });
    return _sharedYTPDB;
}

@end

// MARK: - Statistics

@implementation Statistics

- (instancetype)initWithId:(long)executionId videoFrameNumber:(long)videoFrameNumber fps:(float)fps quality:(float)quality size:(long long)size time:(int)time bitrate:(double)bitrate speed:(double)speed {
    self = [super init];
    if (self) {
        _statisticsFrameNumber = videoFrameNumber;
        _statisticsFps = fps;
        _statisticsQuality = quality;
        _statisticsSize = size;
        _statisticsTime = time;
        _statisticsBitrate = bitrate;
        _statisticsSpeed = speed;
    }
    return self;
}

@end

// MARK: - InitWorkaround

@implementation InitWorkaround
@end
