// YTLiteHeaders.h - Headers for all closed-source YTLite classes
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "YTLite.h"
#import "Utils/YTLUserDefaults.h"

// MARK: - Forward Declarations
@class YTPDownloader, Downloader, DownloadMenuHelper, DownloadingVC;
@class YTPAPIHelper, YTPDB, FFMpegHelper, SRTParser;
@class SBManager, SBPlayerDecorator, SBSegment, SponsorBlockVC, SbWhitelistVC;
@class ToastManager, ToastView, ToastWindow, PlayerToast, CustomHUD;
@class BlurButton, ShareImageViewController, WelcomeVC, AudioManager;
@class YTLHelper, YTLTableViewCell, YTLTableViewController, Statistics;

// MARK: - Protocols

@protocol DownloaderDelegate <NSObject>
- (void)downloadProgress:(float)progress;
- (void)downloadDidFinish:(NSString *)filePath fileName:(NSString *)fileName;
- (void)downloadDidFailureWithError:(NSError *)error;
@end

@protocol StatisticsDelegate <NSObject>
- (void)statisticsCallback:(Statistics *)statistics;
@end

// MARK: - YTPDownloader (Core chunked file downloader)

@interface YTPDownloader : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak) id<DownloaderDelegate> delegate;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSMutableDictionary *downloadedChunks;
@property (nonatomic, assign) long long downloadedSize;
@property (nonatomic, assign) long long totalDownloadedBytes;
@property (nonatomic, assign) long long totalExpectedBytes;
@property (nonatomic, assign) long long totalFileSize;
@property (nonatomic, assign) long long totalChunks;
@property (nonatomic, assign) long long chunkSize;
@property (nonatomic, strong) NSString *chunkMapPath;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) BOOL cancelRequested;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL isVideoDownloaded;

- (void)downloadFileWithURL:(NSURL *)url fileName:(NSString *)fileName fileSize:(long long)fileSize;
- (void)downloadFileWithURL:(NSURL *)url fileName:(NSString *)fileName videoID:(NSString *)videoID fileSize:(long long)fileSize;
- (void)downloadNextChunk;
- (void)continueDownloadingForURL:(NSURL *)url;
- (void)loadChunkMap;
- (void)saveChunkMap;
- (NSString *)hashForFile:(NSString *)file fileSize:(long long)fileSize;
- (void)cancelDownload;

@end

// MARK: - Downloader (High-level download coordinator)

@interface Downloader : NSObject <DownloaderDelegate>

@property (nonatomic, strong) YTPDownloader *downloader;
@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, assign) long long audioSize;
@property (nonatomic, assign) BOOL isAudioOnly;
@property (nonatomic, assign) BOOL downloadWithCaps;
@property (nonatomic, strong) NSString *captions;
@property (nonatomic, strong) NSString *captionsUrl;
@property (nonatomic, assign) long long duration;
@property (nonatomic, strong) NSString *ext;
@property (nonatomic, strong) UIViewController *playerViewController;

- (void)downloadVideoWithUrl:(NSString *)videoUrl audioUrl:(NSString *)audioUrl fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID videoSize:(long long)videoSize audioSize:(long long)audioSize duration:(long long)duration captions:(NSString *)captions playerVC:(UIViewController *)playerVC;
- (void)downloadVideoWithUrl:(NSString *)videoUrl audioUrl:(NSString *)audioUrl fileName:(NSString *)fileName format:(NSString *)format videoID:(NSString *)videoID videoSize:(long long)videoSize audioSize:(long long)audioSize duration:(long long)duration captions:(NSString *)captions;
- (void)downloadVideoWithFormat:(NSDictionary *)format audioFormat:(NSDictionary *)audioFormat fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID playerVC:(UIViewController *)playerVC sender:(id)sender;
- (void)downloadVideoWithFormat:(NSDictionary *)format withAudioFormats:(NSArray *)audioFormats fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID playerVC:(UIViewController *)playerVC sender:(id)sender;
- (void)downloadAudioWithUrl:(NSString *)audioUrl fileName:(NSString *)fileName videoID:(NSString *)videoID audioSize:(long long)audioSize duration:(long long)duration;
- (void)checkSpaceAvailabilityForMedia:(long long)mediaSize completion:(void (^)(BOOL available))completion;

@end

// MARK: - DownloadMenuHelper (Download sheet UI)

@interface DownloadMenuHelper : NSObject

- (void)showDownloadSheet:(id)playerResponse withSender:(id)sender;
- (void)showDownloadSheetShorts:(id)playerResponse withSender:(id)sender;
- (void)showVideoSheet:(id)playerResponse withSender:(id)sender;
- (void)showCaptionsSheet:(id)playerResponse withSender:(id)sender;
- (void)showImagesSheet:(id)playerResponse withSender:(id)sender;
- (void)showTranscriptSheet:(id)playerResponse withSender:(id)sender;
- (void)showInformationSheet:(id)playerResponse withSender:(id)sender;
- (void)showExtPlayerSheet:(id)playerResponse withSender:(id)sender;
- (void)showAudioTrackSelector:(NSArray *)audioFormats sender:(id)sender playerVC:(UIViewController *)playerVC completion:(void (^)(NSDictionary *selectedFormat))completion;
- (void)getCaptionsUrlSheet:(id)playerResponse sender:(id)sender completion:(void (^)(NSString *captionsUrl))completion;
- (void)askForAction:(NSString *)action;

@end

// MARK: - DownloadingVC (Download progress UI)

@interface DownloadingVC : UIViewController

@property (nonatomic, strong) UIProgressView *progressbar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *toastButton;
@property (nonatomic, assign) BOOL isProcessing;

- (void)setupInterfaceWithText:(NSString *)text progress:(float)progress withStop:(BOOL)withStop isStatus:(BOOL)isStatus isSuccess:(BOOL)isSuccess withWait:(BOOL)withWait;
- (void)updateText:(NSString *)text progress:(float)progress;
- (void)updateText:(NSString *)text progress:(float)progress animated:(BOOL)animated;
- (void)updateProgressDialog;

@end

// MARK: - YTPAPIHelper (YouTube API parsing)

@interface YTPAPIHelper : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getVideoFormatsArray:(id)playerResponse isShorts:(BOOL)isShorts;
- (NSArray *)getAudioFormatsArray:(id)playerResponse;
- (NSDictionary *)getBestAudioFormat:(id)playerResponse playerVC:(UIViewController *)playerVC;
- (NSDictionary *)getDefaultAudioTrack:(id)playerResponse;
- (NSDictionary *)getEnglishAudioTrack:(id)playerResponse;
- (NSString *)getExtension:(NSDictionary *)format;
- (NSString *)getResoForQuality:(NSDictionary *)format;
- (NSString *)getThumbnail:(id)playerResponse;
- (void)fetchChannelImageWithChannelID:(NSString *)channelID completion:(void (^)(UIImage *image))completion;
- (void)handleResponse:(id)response error:(NSError *)error completion:(void (^)(NSDictionary *result))completion;
- (void)handleLegacyResponse:(id)response error:(NSError *)error completion:(void (^)(NSDictionary *result))completion;
- (void)handleResponse:(id)response withCompletion:(void (^)(NSDictionary *result))completion;
- (NSArray *)adaptiveFormatsArray;
- (NSDictionary *)streamingData;
- (NSArray *)thumbnailsArray;

@end

// MARK: - YTPDB (Download database)

@interface YTPDB : NSObject

+ (instancetype)sharedInstance;

@end

// MARK: - FFMpegHelper

@interface FFMpegHelper : NSObject

+ (void)mergeVideo:(NSString *)videoPath withAudio:(NSString *)audioPath captions:(NSString *)captionsPath duration:(long long)duration completion:(void (^)(BOOL success, NSString *outputPath))completion;
+ (void)cutAudio:(NSString *)audioPath duration:(long long)duration completion:(void (^)(BOOL success, NSString *outputPath))completion;
+ (NSString *)getCommandWithVideoURL:(NSString *)videoURL audioURL:(NSString *)audioURL captionsURL:(NSString *)captionsURL thumbnailURL:(NSString *)thumbnailURL duration:(long long)duration outputURL:(NSString *)outputURL;
+ (void)closeFFmpegPipe:(NSString *)pipe;
+ (NSString *)createTempDirectoryIfNeeded;

@end

// MARK: - MobileFFmpeg (from mobile-ffmpeg library)

@interface MobileFFmpeg : NSObject
+ (int)execute:(NSString *)command;
+ (int)execute:(NSString *)command delimiter:(NSString *)delimiter;
+ (void)executeAsync:(NSString *)command withCallback:(id)callback;
+ (void)executeAsync:(NSString *)command withCallback:(id)callback andDispatchQueue:(dispatch_queue_t)queue;
+ (int)executeWithArguments:(NSArray *)arguments;
+ (void)executeWithArgumentsAsync:(NSArray *)arguments withCallback:(id)callback;
+ (void)executeWithArgumentsAsync:(NSArray *)arguments withCallback:(id)callback andDispatchQueue:(dispatch_queue_t)queue;
+ (void)cancel;
+ (NSString *)registerNewFFmpegPipe;
+ (void)closeFFmpegPipe:(NSString *)pipe;
+ (NSString *)argumentsToString:(NSArray *)arguments;
@end

@interface MobileFFmpegConfig : NSObject
+ (void)setLogLevel:(int)level;
+ (void)setLogDelegate:(id)delegate;
+ (void)setStatisticsDelegate:(id)delegate;
+ (void)setFontDirectory:(NSString *)directory with:(NSDictionary *)mapping;
+ (void)setFontconfigConfigurationPath:(NSString *)path;
+ (NSString *)getLastCommandOutput;
+ (int)getLastReturnCode;
+ (void)resetStatistics;
+ (Statistics *)getLastReceivedStatistics;
@end

@interface FFmpegExecution : NSObject
@property (nonatomic, assign) long executionId;
@property (nonatomic, strong) NSArray *arguments;
- (instancetype)initWithExecutionId:(long)executionId andArguments:(NSArray *)arguments;
@end

// MARK: - SRTParser (Subtitle parsing)

@interface SRTParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *srtLines;
@property (nonatomic, strong) id rootNode;
@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, strong) NSMutableArray *currentTextSuggestions;

- (NSString *)generateSRTWithText:(NSArray *)text;
- (NSString *)generateTranscriptWithText:(NSArray *)text;
- (NSString *)srtForLanguage:(NSString *)language videoID:(NSString *)videoID error:(NSError **)error;
- (void)parseTranscriptFromURL:(NSString *)url completion:(void (^)(NSArray *result))completion;
- (void)parseXMLFromURL:(NSString *)url forLanguage:(NSString *)language videoID:(NSString *)videoID completion:(void (^)(NSString *srtContent))completion;
- (NSArray *)captionsForDownloading:(id)playerResponse;
- (NSString *)titleForCaption:(id)caption;
- (NSString *)codeForCaps:(id)caption;

@end

// MARK: - SBSegment (SponsorBlock segment model)

@interface SBSegment : NSObject

@property (nonatomic, strong) NSString *actionType;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *segmentDescription;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) float start;
@property (nonatomic, assign) float end;

+ (instancetype)segmentWithDictionary:(NSDictionary *)dict;
- (NSArray *)segmentForItems:(NSArray *)items;

@end

// MARK: - SBManager (SponsorBlock manager)

@interface SBManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *segments;

+ (instancetype)sharedInstance;

- (NSArray *)getSegmentsForID:(NSString *)videoID;
- (void)requestSbSegments;
- (void)addDurationWithoutSegments:(id)duration videoController:(id)videoController;
- (void)sbPublicUserID:(NSString *)userID;
- (void)skipSegment;

@end

// MARK: - SBPlayerDecorator (SponsorBlock player bar decorator)

@interface SBPlayerDecorator : NSObject

- (void)decorateContext:(id)context;
- (void)drawSegmentableSegments:(NSArray *)segments playerBar:(id)playerBar playerVC:(id)playerVC;
- (void)drawSegments:(NSArray *)segments layer:(CALayer *)layer playerVC:(id)playerVC;
- (void)drawSegmentsDecorationView:(id)decorationView;
- (void)drawProgressRect:(CGRect)rect withColor:(UIColor *)color;

@end

// MARK: - SponsorBlockVC (SponsorBlock settings view controller)

@interface SponsorBlockVC : UITableViewController

- (UIColor *)colorForSegment:(NSString *)segment;
- (UIImage *)segmentIcon:(NSString *)segment;
- (UIColorWell *)colorWellForKey:(NSString *)key title:(NSString *)title;
- (void)colorWellTap:(UIColorWell *)sender;

@end

// MARK: - SbWhitelistVC (SponsorBlock whitelist view controller)

@interface SbWhitelistVC : UITableViewController

@property (nonatomic, strong) NSMutableArray *whitelist;
@property (nonatomic, assign) NSInteger sortType;

- (void)setupWhitelist;
- (void)removeChannelWithLink:(NSString *)link;
- (void)updateSortMenu;

@end

// MARK: - ToastManager

@interface ToastManager : NSObject

@property (nonatomic, strong) NSMutableArray *toasts;

+ (instancetype)sharedToast;

- (void)showToast:(ToastView *)toast;
- (void)hideToast;
- (void)registerToast:(ToastView *)toast;
- (void)unregisterToast:(ToastView *)toast;
- (void)updateAllToasts;
- (void)calculateToastParametersWithKeyboardHeight:(CGFloat)keyboardHeight bottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale;

@end

// MARK: - ToastView

@interface ToastView : UIView

@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, strong) UILabel *toastSubLabel;
@property (nonatomic, strong) UIImageView *toastIcon;
@property (nonatomic, strong) UIImageView *toastImage;
@property (nonatomic, strong) UIProgressView *toastProgress;
@property (nonatomic, strong) UIButton *toastButton;

- (void)showText:(NSString *)text;
- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess;
- (void)showMessageWithText:(NSString *)text isSuccess:(BOOL)isSuccess duration:(NSTimeInterval)duration;
- (void)showProgressWithText:(NSString *)text progress:(float)progress withStop:(BOOL)withStop stopCompletion:(void (^)(void))stopCompletion;
- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionIcon:(UIImage *)actionIcon actionCompletion:(void (^)(void))actionCompletion;
- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionIcon:(UIImage *)actionIcon ignoresPan:(BOOL)ignoresPan actionCompletion:(void (^)(void))actionCompletion;
- (void)showProgressiveToastWithText:(NSString *)text duration:(NSTimeInterval)duration actionTitle:(NSString *)actionTitle actionCompletion:(void (^)(void))actionCompletion;
- (void)updateText:(NSString *)text progress:(float)progress;
- (void)updateText:(NSString *)text progress:(float)progress animated:(BOOL)animated;
- (void)hideAnimatedWithCompletion:(void (^)(void))completion;
- (void)hideWithCompletion:(void (^)(void))completion;
- (void)hideWithDelay:(NSTimeInterval)delay;
- (void)configureToastAppearanceWithBottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale width:(CGFloat)width alpha:(CGFloat)alpha animationDuration:(NSTimeInterval)animationDuration completion:(void (^)(void))completion;
- (void)configureToastAppearanceWithBottomOffset:(CGFloat)bottomOffset topOffset:(CGFloat)topOffset scale:(CGFloat)scale width:(CGFloat)width animationDuration:(NSTimeInterval)animationDuration;
- (void)setupInterfaceWithText:(NSString *)text progress:(float)progress withStop:(BOOL)withStop isStatus:(BOOL)isStatus isSuccess:(BOOL)isSuccess withWait:(BOOL)withWait;

@end

// MARK: - ToastWindow

@interface ToastWindow : UIWindow

@property (nonatomic, strong) ToastView *toastView;
@property (nonatomic, strong) id toastOffsetController;

+ (instancetype)sharedInstance;

- (BOOL)canBecomeKeyWindow;
- (BOOL)windowControlsStatusBarOrientation;
- (BOOL)ignoresFullscreenOpacity;

@end

// MARK: - PlayerToast

@interface PlayerToast : NSObject

- (void)showPlayerToastWithText:(NSString *)text value:(NSString *)value style:(NSInteger)style isCompact:(BOOL)isCompact;
- (void)updateToastText:(NSString *)text value:(NSString *)value;

@end

// MARK: - CustomHUD (Volume HUD replacement)

@interface CustomHUD : UIView

@property (nonatomic, strong, readonly) id controller; // MPVolumeController

- (void)addVolumeDisplay:(id)display;
- (void)removeVolumeDisplay:(id)display;

@end

// MARK: - BlurButton (Overlay button with blur)

@interface BlurButton : UIView

+ (UIButton *)createOverlayButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon selector:(SEL)selector;
+ (UIButton *)createYTQTMButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon selector:(SEL)selector;
+ (UIButton *)createYTQTMButton:(NSString *)name accessibilityLabel:(NSString *)accessibilityLabel buttonLabel:(NSString *)buttonLabel icon:(NSString *)icon size:(CGFloat)size selector:(SEL)selector;

@end

// MARK: - AudioManager

@interface AudioManager : NSObject

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (instancetype)sharedInstance;

- (void)playAudio;
- (void)stopAudio;

@end

// MARK: - ShareImageViewController

@interface ShareImageViewController : UIViewController

@property (nonatomic, strong) UIImage *fullImage;

- (instancetype)initWithSelectedImageURL:(NSURL *)selectedImageURL updatedImageURL:(NSURL *)updatedImageURL;
- (void)genImageFromLayer:(CALayer *)layer backgroundColor:(UIColor *)backgroundColor completionHandler:(void (^)(UIImage *image))completionHandler;
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;
- (void)shareMedia:(id)media;
- (void)actionsheetShareImage;

@end

// MARK: - WelcomeVC

@interface WelcomeVC : UIViewController

- (void)showDonationReminder:(UIViewController *)presenter;
- (void)showDonationSheet:(UIViewController *)presenter;

@end

// MARK: - Statistics (FFmpeg statistics)

@interface Statistics : NSObject

@property (nonatomic, assign) long statisticsFrameNumber;
@property (nonatomic, assign) float statisticsFps;
@property (nonatomic, assign) float statisticsQuality;
@property (nonatomic, assign) long long statisticsSize;
@property (nonatomic, assign) int statisticsTime;
@property (nonatomic, assign) double statisticsBitrate;
@property (nonatomic, assign) double statisticsSpeed;

- (instancetype)initWithId:(long)executionId videoFrameNumber:(long)videoFrameNumber fps:(float)fps quality:(float)quality size:(long long)size time:(int)time bitrate:(double)bitrate speed:(double)speed;

@end

// MARK: - YTLHelper (General helper)

@interface YTLHelper : NSObject

+ (UIViewController *)topViewControllerForPresenting;
+ (UIViewController *)closestViewController:(UIView *)view;
+ (UIWindow *)appKeyWindow;
+ (NSString *)appName;
+ (NSString *)shortAppName;
+ (NSString *)appID;
+ (NSString *)bundleId;
+ (NSString *)bundleSeedID;
+ (NSString *)sharedAccessGroup;
+ (BOOL)isFromAppStore;
+ (BOOL)isiPad;
+ (BOOL)isRTL;
+ (BOOL)isLandscape;
+ (BOOL)isConnectedToWiFi;
+ (long long)freeDeviceStorageBytes;
+ (NSString *)formatTime:(long long)time;
+ (NSString *)darkFormatTime:(long long)time;
+ (NSString *)decodeHTML:(NSString *)html;
+ (UIImage *)ytlImageWithName:(NSString *)name;
+ (UIImage *)cellImageWithName:(NSString *)name;
+ (UIImage *)imageWithName:(NSString *)name;
+ (UIImage *)imageNamed:(NSString *)name withSize:(CGFloat)size;
+ (UIImage *)systemImage:(NSString *)name withSize:(CGFloat)size;
+ (UIImage *)originalImageWithName:(NSString *)name;
+ (UIImage *)iconImageNamed:(NSString *)name;
+ (UIImage *)iconCheckWithColor:(UIColor *)color;
+ (void)fireHapticFeedback;
+ (void)prepareHapticFeedback;
+ (NSString *)systemLanguage;
+ (NSArray *)supportedLanguages;
+ (void)clearCache:(void (^)(void))completion;
+ (void)getCacheSizeWithCompletion:(void (^)(NSString *size))completion;
+ (void)presentDocumentPicker:(UIViewController *)presenter;

@end

// MARK: - YTLTableViewCell

@interface YTLTableViewCell : UITableViewCell

@end

// MARK: - YTLTableViewController (Base table view controller for settings)

@interface YTLTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *contentsArray;
@property (nonatomic, strong) NSArray *orderedCategories;
@property (nonatomic, strong) NSMutableDictionary *settingsData;
@property (nonatomic, copy) void (^prefsPickerCompletion)(id result);

- (UISwitch *)switchForKey:(NSString *)key;
- (UISlider *)sliderWithKey:(NSString *)key min:(float)min max:(float)max;
- (UIMenu *)menuButtonWithTitle:(NSString *)title array:(NSArray *)array key:(NSString *)key;
- (void)showSheet:(id)controller title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key;
- (void)setSectionItems:(NSArray *)items forCategory:(NSString *)category title:(NSString *)title icon:(UIImage *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
- (void)setSectionItems:(NSArray *)items forCategory:(NSString *)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
- (void)updateSectionForCategory:(NSString *)category withEntry:(id)entry;
- (void)toggleSwitch:(UISwitch *)sender;
- (void)sliderValueChanged:(UISlider *)sender;
- (UIImage *)devCellImage:(NSString *)name;
- (UIImage *)imgForVal:(id)val;
- (UILabel *)subLabelForVal:(id)val style:(NSInteger)style;
- (void)exportPrefs:(id)sender;
- (void)exportYtlSettings:(id)sender;
- (void)importYtlSettings:(id)sender;
- (void)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle cancelAction:(void (^)(void))cancelAction cancelTitle:(NSString *)cancelTitle;
- (void)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle;

@end

// MARK: - SettingsViewController (Main settings)

@interface SettingsViewController : YTLTableViewController <UIDocumentPickerDelegate>

- (void)initForSettings:(id)settings;
- (void)updateYTLiteSectionWithEntry:(id)entry;
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)entry;
- (void)resetSettings;
- (void)resetUserDefaults;

@end

// MARK: - Settings Sub-VCs

@interface PrefsVC : YTLTableViewController
@end

@interface PlayerVC : YTLTableViewController
@end

@interface FeedVC : YTLTableViewController
@end

@interface ShortsVC : YTLTableViewController
@end

@interface InterfaceVC : YTLTableViewController
@end

@interface NavbarVC : YTLTableViewController
@end

@interface TabbarVC : YTLTableViewController
@property (nonatomic, strong) NSArray *activeTabs;
@property (nonatomic, strong) NSArray *inactiveTabs;
- (void)saveTabsOrder;
- (void)initTabs;
@end

@interface ContributorsVC : YTLTableViewController
@end

@interface ThanksVC : YTLTableViewController
- (void)thanksButtonTapped:(id)sender;
- (void)contactsButtonTapped:(id)sender;
@end

@interface LibsVC : YTLTableViewController
@end

// MARK: - InitWorkaround

@interface InitWorkaround : NSObject
@end

// MARK: - Utility classes from mobile-ffmpeg

@interface CallbackData : NSObject
@property (nonatomic, assign) long executionId;
@property (nonatomic, assign) int logLevel;
@property (nonatomic, strong) NSData *logData;
- (instancetype)initWithId:(long)executionId logLevel:(int)logLevel data:(NSData *)data;
@end

@interface AtomicLong : NSObject
- (instancetype)initWithInitialValue:(long)initialValue;
@end

@interface ArchDetect : NSObject
@end
