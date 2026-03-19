// Downloader.x - High-level download coordinator
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

@interface Downloader ()
@property (nonatomic, strong) YTPDownloader *videoDownloader;
@property (nonatomic, strong) YTPDownloader *audioDownloader;
@property (nonatomic, assign) BOOL videoDownloaded;
@property (nonatomic, assign) BOOL audioDownloaded;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSString *audioFilePath;
@property (nonatomic, strong) NSString *outputFileName;
@property (nonatomic, strong) ToastView *progressToast;
@end

@implementation Downloader

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoDownloader = [[YTPDownloader alloc] init];
        _videoDownloader.delegate = self;
        _audioDownloader = [[YTPDownloader alloc] init];
        _audioDownloader.delegate = self;
        _videoDownloaded = NO;
        _audioDownloaded = NO;
    }
    return self;
}

- (void)downloadVideoWithFormat:(NSDictionary *)format audioFormat:(NSDictionary *)audioFormat fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID playerVC:(UIViewController *)playerVC sender:(id)sender {
    NSString *videoUrl = format[@"url"];
    NSString *audioUrl = audioFormat[@"url"];
    long long videoSize = [format[@"contentLength"] longLongValue];
    long long audioSize = [audioFormat[@"contentLength"] longLongValue];
    long long duration = [format[@"approxDurationMs"] longLongValue] / 1000;

    [self downloadVideoWithUrl:videoUrl audioUrl:audioUrl fileName:fileName extension:extension videoID:videoID videoSize:videoSize audioSize:audioSize duration:duration captions:nil playerVC:playerVC];
}

- (void)downloadVideoWithFormat:(NSDictionary *)format withAudioFormats:(NSArray *)audioFormats fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID playerVC:(UIViewController *)playerVC sender:(id)sender {
    if (!audioFormats || audioFormats.count == 0) {
        [self downloadVideoWithFormat:format audioFormat:nil fileName:fileName extension:extension videoID:videoID playerVC:playerVC sender:sender];
        return;
    }

    // Show audio track selector if multiple tracks
    if (audioFormats.count > 1) {
        DownloadMenuHelper *menuHelper = [[DownloadMenuHelper alloc] init];
        [menuHelper showAudioTrackSelector:audioFormats sender:sender playerVC:playerVC completion:^(NSDictionary *selectedFormat) {
            [self downloadVideoWithFormat:format audioFormat:selectedFormat fileName:fileName extension:extension videoID:videoID playerVC:playerVC sender:sender];
        }];
    } else {
        [self downloadVideoWithFormat:format audioFormat:audioFormats.firstObject fileName:fileName extension:extension videoID:videoID playerVC:playerVC sender:sender];
    }
}

- (void)downloadVideoWithUrl:(NSString *)videoUrl audioUrl:(NSString *)audioUrl fileName:(NSString *)fileName extension:(NSString *)extension videoID:(NSString *)videoID videoSize:(long long)videoSize audioSize:(long long)audioSize duration:(long long)duration captions:(NSString *)captions playerVC:(UIViewController *)playerVC {
    self.videoUrl = videoUrl;
    self.audioUrl = audioUrl;
    self.videoID = videoID;
    self.audioSize = audioSize;
    self.duration = duration;
    self.captions = captions;
    self.ext = extension;
    self.playerViewController = playerVC;
    self.outputFileName = fileName;
    self.videoDownloaded = NO;
    self.audioDownloaded = NO;
    self.isAudioOnly = NO;

    long long totalSize = videoSize + audioSize;
    [self checkSpaceAvailabilityForMedia:totalSize completion:^(BOOL available) {
        if (!available) return;

        NSString *localizedDownloading = [[NSBundle mainBundle] localizedStringForKey:@"DownloadingVideo" value:@"Downloading video" table:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            ToastView *toast = [[ToastView alloc] init];
            [toast showProgressWithText:localizedDownloading progress:0 withStop:YES stopCompletion:^{
                [self cancelDownload];
            }];
            self.progressToast = toast;
            [[ToastManager sharedToast] showToast:toast];
        });

        // Start downloading video
        NSString *videoFileName = [NSString stringWithFormat:@"%@_v.mp4", videoID];
        NSURL *videoURL = [NSURL URLWithString:videoUrl];
        [self.videoDownloader downloadFileWithURL:videoURL fileName:videoFileName videoID:videoID fileSize:videoSize];

        // Start downloading audio if present
        if (audioUrl && audioUrl.length > 0) {
            NSString *audioFileName = [NSString stringWithFormat:@"%@_a.m4a", videoID];
            NSURL *audioURL = [NSURL URLWithString:audioUrl];
            [self.audioDownloader downloadFileWithURL:audioURL fileName:audioFileName videoID:videoID fileSize:audioSize];
        } else {
            self.audioDownloaded = YES;
        }
    }];
}

- (void)downloadVideoWithUrl:(NSString *)videoUrl audioUrl:(NSString *)audioUrl fileName:(NSString *)fileName format:(NSString *)format videoID:(NSString *)videoID videoSize:(long long)videoSize audioSize:(long long)audioSize duration:(long long)duration captions:(NSString *)captions {
    [self downloadVideoWithUrl:videoUrl audioUrl:audioUrl fileName:fileName extension:format videoID:videoID videoSize:videoSize audioSize:audioSize duration:duration captions:captions playerVC:nil];
}

- (void)downloadAudioWithUrl:(NSString *)audioUrl fileName:(NSString *)fileName videoID:(NSString *)videoID audioSize:(long long)audioSize duration:(long long)duration {
    self.audioUrl = audioUrl;
    self.videoID = videoID;
    self.audioSize = audioSize;
    self.duration = duration;
    self.outputFileName = fileName;
    self.isAudioOnly = YES;
    self.videoDownloaded = YES; // No video to download

    [self checkSpaceAvailabilityForMedia:audioSize completion:^(BOOL available) {
        if (!available) return;

        NSString *localizedDownloading = [[NSBundle mainBundle] localizedStringForKey:@"DownloadingAudio" value:@"Downloading audio" table:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            ToastView *toast = [[ToastView alloc] init];
            [toast showProgressWithText:localizedDownloading progress:0 withStop:YES stopCompletion:^{
                [self cancelDownload];
            }];
            self.progressToast = toast;
            [[ToastManager sharedToast] showToast:toast];
        });

        NSString *audioFileName = [NSString stringWithFormat:@"%@.m4a", videoID];
        NSURL *audioURL = [NSURL URLWithString:audioUrl];
        [self.audioDownloader downloadFileWithURL:audioURL fileName:audioFileName videoID:videoID fileSize:audioSize];
    }];
}

#pragma mark - Space Check

- (void)checkSpaceAvailabilityForMedia:(long long)mediaSize completion:(void (^)(BOOL available))completion {
    long long freeSpace = [YTLHelper freeDeviceStorageBytes];
    // Need at least the media size + some buffer for processing
    long long requiredSpace = mediaSize + (50 * 1024 * 1024); // +50MB buffer

    if (freeSpace < requiredSpace) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *requiredStr = [NSByteCountFormatter stringFromByteCount:requiredSpace countStyle:NSByteCountFormatterCountStyleFile];
            NSString *availableStr = [NSByteCountFormatter stringFromByteCount:freeSpace countStyle:NSByteCountFormatterCountStyleFile];
            NSString *localizedError = [[NSBundle mainBundle] localizedStringForKey:@"Error.NoSpace" value:@"Insufficient space on the device.\n\nAt least %@ additional free space is required. Available free space: %@" table:nil];
            NSString *message = [NSString stringWithFormat:localizedError, requiredStr, availableStr];

            ToastView *toast = [[ToastView alloc] init];
            [toast showMessageWithText:message isSuccess:NO];
            [[ToastManager sharedToast] showToast:toast];
        });
        if (completion) completion(NO);
        return;
    }
    if (completion) completion(YES);
}

#pragma mark - DownloaderDelegate

- (void)downloadProgress:(float)progress {
    // Determine which downloader is reporting
    float overallProgress;
    if (self.isAudioOnly) {
        overallProgress = progress;
    } else if (self.audioUrl && self.audioUrl.length > 0) {
        // Weight video and audio progress
        float videoWeight = 0.7;
        float audioWeight = 0.3;
        float videoProg = self.videoDownloaded ? 1.0 : (self.videoDownloader.downloading ? progress : 0.0);
        float audioProg = self.audioDownloaded ? 1.0 : (self.audioDownloader.downloading ? progress : 0.0);
        overallProgress = videoProg * videoWeight + audioProg * audioWeight;
    } else {
        overallProgress = progress;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressToast updateText:nil progress:overallProgress animated:YES];
    });
}

- (void)downloadDidFinish:(NSString *)filePath fileName:(NSString *)fileName {
    // Determine which download finished
    if ([fileName hasSuffix:@"_v.mp4"]) {
        self.videoDownloaded = YES;
        self.videoFilePath = filePath;
    } else {
        self.audioDownloaded = YES;
        self.audioFilePath = filePath;
    }

    // Check if both are done
    if (self.videoDownloaded && self.audioDownloaded) {
        [self mergeAndFinalize];
    }
}

- (void)downloadDidFailureWithError:(NSError *)error {
    NSLog(@"YTPlus --- Error while downloading: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressToast showMessageWithText:error.localizedDescription isSuccess:NO];
    });
}

#pragma mark - Merge & Finalize

- (void)mergeAndFinalize {
    if (self.isAudioOnly) {
        // Audio only - cut if needed then save
        NSString *localizedConverting = [[NSBundle mainBundle] localizedStringForKey:@"Converting" value:@"Converting" table:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressToast updateText:localizedConverting progress:1.0];
        });

        [FFMpegHelper cutAudio:self.audioFilePath duration:self.duration completion:^(BOOL success, NSString *outputPath) {
            if (success) {
                [self saveToFiles:outputPath fileName:[NSString stringWithFormat:@"%@.m4a", self.outputFileName]];
            } else {
                // If cut fails, save original
                [self saveToFiles:self.audioFilePath fileName:[NSString stringWithFormat:@"%@.m4a", self.outputFileName]];
            }
        }];
        return;
    }

    // Video + Audio merge
    NSString *localizedConverting = [[NSBundle mainBundle] localizedStringForKey:@"Converting" value:@"Converting" table:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressToast updateText:localizedConverting progress:1.0];
    });

    [FFMpegHelper mergeVideo:self.videoFilePath withAudio:self.audioFilePath captions:self.captions duration:self.duration completion:^(BOOL success, NSString *outputPath) {
        if (success) {
            NSString *ext = self.ext ?: @"mp4";
            [self saveToFiles:outputPath fileName:[NSString stringWithFormat:@"%@.%@", self.outputFileName, ext]];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *localizedError = [[NSBundle mainBundle] localizedStringForKey:@"Error" value:@"Error" table:nil];
                [self.progressToast showMessageWithText:localizedError isSuccess:NO];
            });
        }
    }];
}

- (void)saveToFiles:(NSString *)sourcePath fileName:(NSString *)fileName {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    NSInteger postAction = [defaults integerForKey:@"PostDownloadAction"];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *localizedCompleted = [[NSBundle mainBundle] localizedStringForKey:@"DownloadCompleted" value:@"Download completed" table:nil];
        [self.progressToast showMessageWithText:localizedCompleted isSuccess:YES];
    });

    if (postAction == 1) {
        // Save to Photos
        NSURL *fileURL = [NSURL fileURLWithPath:sourcePath];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypeVideo fileURL:fileURL options:nil];
        } completionHandler:^(BOOL success, NSError *error) {
            [self cleanupTempFiles];
        }];
    } else {
        // Present document picker / share sheet
        NSURL *fileURL = [NSURL fileURLWithPath:sourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
            UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
            [presenter presentViewController:activityVC animated:YES completion:nil];
        });
    }
}

- (void)cancelDownload {
    [self.videoDownloader cancelDownload];
    [self.audioDownloader cancelDownload];
    [self cleanupTempFiles];
}

- (void)cleanupTempFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (self.videoFilePath) [fm removeItemAtPath:self.videoFilePath error:nil];
    if (self.audioFilePath) [fm removeItemAtPath:self.audioFilePath error:nil];
}

@end
