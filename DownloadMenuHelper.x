// DownloadMenuHelper.x - Download sheet UI presentation
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

@implementation DownloadMenuHelper

- (void)showDownloadSheet:(id)playerResponse withSender:(id)sender {
    YTPAPIHelper *apiHelper = [YTPAPIHelper sharedInstance];
    NSArray *videoFormats = [apiHelper getVideoFormatsArray:playerResponse isShorts:NO];
    NSArray *audioFormats = [apiHelper getAudioFormatsArray:playerResponse];
    NSArray *captions = [[SRTParser new] captionsForDownloading:playerResponse];
    NSString *thumbnail = [apiHelper getThumbnail:playerResponse];

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"DownloadManager" value:@"Download manager" table:nil];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    // Download Video option
    if (videoFormats.count > 0) {
        NSString *localizedVideo = [[NSBundle mainBundle] localizedStringForKey:@"DownloadVideo" value:@"Download video" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedVideo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showVideoSheet:playerResponse withSender:sender];
        }]];
    }

    // Download Audio option
    if (audioFormats.count > 0) {
        NSString *localizedAudio = [[NSBundle mainBundle] localizedStringForKey:@"DownloadAudio" value:@"Download audio" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedAudio style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self downloadAudioFromResponse:playerResponse];
        }]];
    }

    // Save Thumbnail option
    if (thumbnail) {
        NSString *localizedThumbnail = [[NSBundle mainBundle] localizedStringForKey:@"DownloadThumbnail" value:@"Save thumbnail" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedThumbnail style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self downloadThumbnail:thumbnail];
        }]];
    }

    // Download Captions option
    if (captions.count > 0) {
        NSString *localizedCaptions = [[NSBundle mainBundle] localizedStringForKey:@"DownloadCaptions" value:@"Download captions" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedCaptions style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showCaptionsSheet:playerResponse withSender:sender];
        }]];
    }

    // Copy Information option
    NSString *localizedInfo = [[NSBundle mainBundle] localizedStringForKey:@"CopyInformation" value:@"Copy information" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedInfo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showInformationSheet:playerResponse withSender:sender];
    }]];

    // Play in External Player
    NSString *localizedExtPlayer = [[NSBundle mainBundle] localizedStringForKey:@"PlayInExternalPlayer" value:@"Play in external player" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedExtPlayer style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showExtPlayerSheet:playerResponse withSender:sender];
    }]];

    // Cancel
    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    // iPad popover
    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showDownloadSheetShorts:(id)playerResponse withSender:(id)sender {
    YTPAPIHelper *apiHelper = [YTPAPIHelper sharedInstance];
    NSArray *videoFormats = [apiHelper getVideoFormatsArray:playerResponse isShorts:YES];

    if (videoFormats.count == 0) return;

    // For Shorts, directly download the best MP4
    NSDictionary *bestFormat = videoFormats.firstObject;
    NSDictionary *bestAudio = [apiHelper getBestAudioFormat:playerResponse playerVC:nil];

    NSString *videoID = [self videoIDFromResponse:playerResponse];
    NSString *title = [self videoTitleFromResponse:playerResponse];
    NSString *fileName = [self sanitizeFileName:title];
    NSString *extension = [apiHelper getExtension:bestFormat];

    Downloader *downloader = [[Downloader alloc] init];
    [downloader downloadVideoWithFormat:bestFormat audioFormat:bestAudio fileName:fileName extension:extension videoID:videoID playerVC:nil sender:sender];
}

- (void)showVideoSheet:(id)playerResponse withSender:(id)sender {
    YTPAPIHelper *apiHelper = [YTPAPIHelper sharedInstance];
    NSArray *videoFormats = [apiHelper getVideoFormatsArray:playerResponse isShorts:NO];
    NSArray *audioFormats = [apiHelper getAudioFormatsArray:playerResponse];

    if (videoFormats.count == 0) return;

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"DownloadVideo" value:@"Download video" table:nil];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *videoID = [self videoIDFromResponse:playerResponse];
    NSString *title = [self videoTitleFromResponse:playerResponse];
    NSString *fileName = [self sanitizeFileName:title];

    for (NSDictionary *format in videoFormats) {
        NSString *quality = [apiHelper getResoForQuality:format];
        NSString *extension = [apiHelper getExtension:format];
        long long size = [format[@"contentLength"] longLongValue];
        NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
        NSString *codec = [self shortCodecName:format[@"mimeType"]];

        NSString *actionTitle = [NSString stringWithFormat:@"%@ • %@ • %@", quality, codec, sizeStr];

        [sheet addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            Downloader *downloader = [[Downloader alloc] init];
            [downloader downloadVideoWithFormat:format withAudioFormats:audioFormats fileName:fileName extension:extension videoID:videoID playerVC:presenter sender:sender];
        }]];
    }

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showCaptionsSheet:(id)playerResponse withSender:(id)sender {
    SRTParser *parser = [[SRTParser alloc] init];
    NSArray *captions = [parser captionsForDownloading:playerResponse];

    if (!captions || captions.count == 0) return;

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"DownloadCaptions" value:@"Download captions" table:nil];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *videoID = [self videoIDFromResponse:playerResponse];

    for (id caption in captions) {
        NSString *title = [parser titleForCaption:caption];
        NSString *langCode = [parser codeForCaps:caption];

        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *baseUrl = nil;
            if ([caption isKindOfClass:[NSDictionary class]]) {
                baseUrl = caption[@"baseUrl"];
            } else if ([caption respondsToSelector:@selector(baseUrl)]) {
                baseUrl = [caption performSelector:@selector(baseUrl)];
            }

            if (baseUrl) {
                [parser parseXMLFromURL:baseUrl forLanguage:langCode videoID:videoID completion:^(NSString *srtContent) {
                    if (srtContent) {
                        NSError *error;
                        NSString *srtPath = [parser srtForLanguage:langCode videoID:videoID error:&error];
                        if (srtPath) {
                            [self shareSRT:srtPath sourceView:sender];
                        }
                    }
                }];
            }
        }]];
    }

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showImagesSheet:(id)playerResponse withSender:(id)sender {
    NSString *thumbnail = [[YTPAPIHelper sharedInstance] getThumbnail:playerResponse];
    if (!thumbnail) return;

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"ShowThumbnail" value:@"Show thumbnail" table:nil];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *localizedSave = [[NSBundle mainBundle] localizedStringForKey:@"SaveToPhotos" value:@"Save to photos" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedSave style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self downloadThumbnail:thumbnail];
    }]];

    NSString *localizedCopy = [[NSBundle mainBundle] localizedStringForKey:@"CopyThumbnail" value:@"Copy thumbnail" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCopy style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        downloadImageFromURL([NSURL URLWithString:thumbnail], NO);
    }]];

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showTranscriptSheet:(id)playerResponse withSender:(id)sender {
    SRTParser *parser = [[SRTParser alloc] init];
    NSArray *captions = [parser captionsForDownloading:playerResponse];

    if (!captions || captions.count == 0) return;

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"CopyTranscript" value:@"Copy transcript" table:nil];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (id caption in captions) {
        NSString *title = [parser titleForCaption:caption];

        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *baseUrl = nil;
            if ([caption isKindOfClass:[NSDictionary class]]) {
                baseUrl = caption[@"baseUrl"];
            } else if ([caption respondsToSelector:@selector(baseUrl)]) {
                baseUrl = [caption performSelector:@selector(baseUrl)];
            }

            if (baseUrl) {
                NSString *localizedParsing = [[NSBundle mainBundle] localizedStringForKey:@"ParsingTranscript" value:@"Parsing the transcript" table:nil];
                ToastView *toast = [[ToastView alloc] init];
                [toast showMessageWithText:localizedParsing isSuccess:YES duration:2.0];
                [[ToastManager sharedToast] showToast:toast];

                [parser parseTranscriptFromURL:baseUrl completion:^(NSArray *result) {
                    if (result) {
                        NSString *transcript = [parser generateTranscriptWithText:result];
                        if (transcript) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [UIPasteboard generalPasteboard].string = transcript;
                                NSString *localizedCopied = [[NSBundle mainBundle] localizedStringForKey:@"Copied" value:@"Copied to clipboard" table:nil];
                                ToastView *successToast = [[ToastView alloc] init];
                                [successToast showMessageWithText:localizedCopied isSuccess:YES];
                                [[ToastManager sharedToast] showToast:successToast];
                            });
                        }
                    }
                }];
            }
        }]];
    }

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showInformationSheet:(id)playerResponse withSender:(id)sender {
    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"CopyInformation" value:@"Copy information" table:nil];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *videoID = [self videoIDFromResponse:playerResponse];
    NSString *title = [self videoTitleFromResponse:playerResponse];

    // Copy title
    NSString *localizedCopyTitle = [[NSBundle mainBundle] localizedStringForKey:@"CopyTitle" value:@"Copy title" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCopyTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].string = title;
        [self showCopiedToast];
    }]];

    // Copy description
    NSString *localizedCopyDesc = [[NSBundle mainBundle] localizedStringForKey:@"CopyDescription" value:@"Copy description" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCopyDesc style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *desc = [self videoDescriptionFromResponse:playerResponse];
        if (desc) {
            [UIPasteboard generalPasteboard].string = desc;
            [self showCopiedToast];
        }
    }]];

    // Copy link
    NSString *localizedCopyLink = [[NSBundle mainBundle] localizedStringForKey:@"Copy" value:@"Copy" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ URL", localizedCopyLink] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *url = [NSString stringWithFormat:@"https://youtube.com/watch?v=%@", videoID];
        [UIPasteboard generalPasteboard].string = url;
        [self showCopiedToast];
    }]];

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showExtPlayerSheet:(id)playerResponse withSender:(id)sender {
    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) return;

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"PlayInExternalPlayer" value:@"Play in external player" table:nil];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *videoID = [self videoIDFromResponse:playerResponse];
    NSString *youtubeURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID];

    // System Player
    NSString *localizedSystem = [[NSBundle mainBundle] localizedStringForKey:@"PlayInSystemPlayer" value:@"Play in system player" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedSystem style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        YTPAPIHelper *apiHelper = [YTPAPIHelper sharedInstance];
        NSArray *videoFormats = [apiHelper getVideoFormatsArray:playerResponse isShorts:NO];
        if (videoFormats.count > 0) {
            NSString *url = videoFormats.firstObject[@"url"];
            if (url) {
                AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
                playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
                [presenter presentViewController:playerVC animated:YES completion:^{
                    [playerVC.player play];
                }];
            }
        }
    }]];

    // VLC
    NSString *vlcURL = [NSString stringWithFormat:@"vlc-x-callback://x-callback-url/stream?url=%@", youtubeURL];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vlc-x-callback://"]]) {
        NSString *localizedVLC = [[NSBundle mainBundle] localizedStringForKey:@"PlayInVLC" value:@"Play in VLC" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedVLC style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vlcURL] options:@{} completionHandler:nil];
        }]];
    }

    // Infuse
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"infuse://"]]) {
        NSString *localizedInfuse = [[NSBundle mainBundle] localizedStringForKey:@"PlayInInfuse" value:@"Play in Infuse" table:nil];
        [sheet addAction:[UIAlertAction actionWithTitle:localizedInfuse style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *infuseURL = [NSString stringWithFormat:@"infuse://x-callback-url/play?url=%@", youtubeURL];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:infuseURL] options:@{} completionHandler:nil];
        }]];
    }

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    [presenter presentViewController:sheet animated:YES completion:nil];
}

- (void)showAudioTrackSelector:(NSArray *)audioFormats sender:(id)sender playerVC:(UIViewController *)playerVC completion:(void (^)(NSDictionary *selectedFormat))completion {
    UIViewController *presenter = playerVC ?: [YTLHelper topViewControllerForPresenting];
    if (!presenter) {
        if (completion) completion(audioFormats.firstObject);
        return;
    }

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"SelectAudioTrack" value:@"Select audio track" table:nil];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *format in audioFormats) {
        NSDictionary *audioTrack = format[@"audioTrack"];
        NSString *displayName = audioTrack[@"displayName"] ?: audioTrack[@"id"] ?: @"Audio";
        NSInteger bitrate = [format[@"bitrate"] integerValue] / 1000;
        BOOL isDefault = [audioTrack[@"audioIsDefault"] boolValue];

        NSString *title = [NSString stringWithFormat:@"%@ (%ldkbps)%@", displayName, (long)bitrate, isDefault ? @" ★" : @""];

        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (completion) completion(format);
        }]];
    }

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Default to first format on cancel
        if (completion) completion(audioFormats.firstObject);
    }]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [presenter presentViewController:sheet animated:YES completion:nil];
    });
}

- (void)getCaptionsUrlSheet:(id)playerResponse sender:(id)sender completion:(void (^)(NSString *captionsUrl))completion {
    SRTParser *parser = [[SRTParser alloc] init];
    NSArray *captions = [parser captionsForDownloading:playerResponse];

    if (!captions || captions.count == 0) {
        if (completion) completion(nil);
        return;
    }

    UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
    if (!presenter) {
        if (completion) completion(nil);
        return;
    }

    NSString *localizedTitle = [[NSBundle mainBundle] localizedStringForKey:@"SelectCaption" value:@"Select captions/subtitles" table:nil];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:localizedTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (id caption in captions) {
        NSString *title = [parser titleForCaption:caption];

        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *baseUrl = nil;
            if ([caption isKindOfClass:[NSDictionary class]]) {
                baseUrl = caption[@"baseUrl"];
            } else if ([caption respondsToSelector:@selector(baseUrl)]) {
                baseUrl = [caption performSelector:@selector(baseUrl)];
            }
            if (completion) completion(baseUrl);
        }]];
    }

    NSString *localizedNone = [[NSBundle mainBundle] localizedStringForKey:@"Disable" value:@"Disable" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedNone style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) completion(nil);
    }]];

    NSString *localizedCancel = [[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    [sheet addAction:[UIAlertAction actionWithTitle:localizedCancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (completion) completion(nil);
    }]];

    if (sheet.popoverPresentationController) {
        UIView *sourceView = [sender isKindOfClass:[UIView class]] ? sender : presenter.view;
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [presenter presentViewController:sheet animated:YES completion:nil];
    });
}

- (void)askForAction:(NSString *)action {
    // Handle post-download action prompt
}

#pragma mark - Internal Helpers

- (void)downloadAudioFromResponse:(id)playerResponse {
    YTPAPIHelper *apiHelper = [YTPAPIHelper sharedInstance];
    NSDictionary *bestAudio = [apiHelper getBestAudioFormat:playerResponse playerVC:nil];

    if (!bestAudio) return;

    NSString *videoID = [self videoIDFromResponse:playerResponse];
    NSString *title = [self videoTitleFromResponse:playerResponse];
    NSString *fileName = [self sanitizeFileName:title];
    long long audioSize = [bestAudio[@"contentLength"] longLongValue];
    long long duration = [bestAudio[@"approxDurationMs"] longLongValue] / 1000;

    Downloader *downloader = [[Downloader alloc] init];
    [downloader downloadAudioWithUrl:bestAudio[@"url"] fileName:fileName videoID:videoID audioSize:audioSize duration:duration];
}

- (void)downloadThumbnail:(NSString *)thumbnailUrl {
    if (!thumbnailUrl) return;
    downloadImageFromURL([NSURL URLWithString:thumbnailUrl], YES);
}

- (void)shareSRT:(NSString *)srtPath sourceView:(id)sourceView {
    NSURL *fileURL = [NSURL fileURLWithPath:srtPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        UIViewController *presenter = [YTLHelper topViewControllerForPresenting];
        if (activityVC.popoverPresentationController) {
            UIView *view = [sourceView isKindOfClass:[UIView class]] ? sourceView : presenter.view;
            activityVC.popoverPresentationController.sourceView = view;
            activityVC.popoverPresentationController.sourceRect = [view bounds];
        }
        [presenter presentViewController:activityVC animated:YES completion:nil];
    });
}

- (NSString *)videoIDFromResponse:(id)playerResponse {
    if ([playerResponse isKindOfClass:[NSDictionary class]]) {
        return playerResponse[@"videoDetails"][@"videoId"];
    }
    if ([playerResponse respondsToSelector:@selector(videoDetails)]) {
        id details = [playerResponse performSelector:@selector(videoDetails)];
        if ([details respondsToSelector:@selector(videoId)]) {
            return [details performSelector:@selector(videoId)];
        }
    }
    return @"unknown";
}

- (NSString *)videoTitleFromResponse:(id)playerResponse {
    if ([playerResponse isKindOfClass:[NSDictionary class]]) {
        return playerResponse[@"videoDetails"][@"title"];
    }
    if ([playerResponse respondsToSelector:@selector(videoDetails)]) {
        id details = [playerResponse performSelector:@selector(videoDetails)];
        if ([details respondsToSelector:@selector(title)]) {
            return [details performSelector:@selector(title)];
        }
    }
    return @"video";
}

- (NSString *)videoDescriptionFromResponse:(id)playerResponse {
    if ([playerResponse isKindOfClass:[NSDictionary class]]) {
        return playerResponse[@"videoDetails"][@"shortDescription"];
    }
    if ([playerResponse respondsToSelector:@selector(videoDetails)]) {
        id details = [playerResponse performSelector:@selector(videoDetails)];
        if ([details respondsToSelector:@selector(shortDescription)]) {
            return [details performSelector:@selector(shortDescription)];
        }
    }
    return nil;
}

- (NSString *)sanitizeFileName:(NSString *)fileName {
    if (!fileName) return @"video";

    NSCharacterSet *illegalChars = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    NSString *sanitized = [[fileName componentsSeparatedByCharactersInSet:illegalChars] componentsJoinedByString:@""];
    sanitized = [sanitized stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (sanitized.length == 0) return @"video";
    if (sanitized.length > 200) sanitized = [sanitized substringToIndex:200];

    return sanitized;
}

- (NSString *)shortCodecName:(NSString *)mimeType {
    if (!mimeType) return @"";
    if ([mimeType containsString:@"avc1"]) return @"H.264";
    if ([mimeType containsString:@"av01"]) return @"AV1";
    if ([mimeType containsString:@"vp9"]) return @"VP9";
    if ([mimeType containsString:@"vp8"]) return @"VP8";
    if ([mimeType containsString:@"mp4a"]) return @"AAC";
    if ([mimeType containsString:@"opus"]) return @"Opus";
    if ([mimeType containsString:@"vorbis"]) return @"Vorbis";
    return @"";
}

- (void)showCopiedToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *localizedCopied = [[NSBundle mainBundle] localizedStringForKey:@"Copied" value:@"Copied to clipboard" table:nil];
        ToastView *toast = [[ToastView alloc] init];
        [toast showMessageWithText:localizedCopied isSuccess:YES];
        [[ToastManager sharedToast] showToast:toast];
    });
}

@end
