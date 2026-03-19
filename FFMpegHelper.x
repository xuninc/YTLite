// FFMpegHelper.x - FFmpeg wrapper for media merging
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

static NSString *const kTempDirectoryName = @"YTLiteDownloads";

@implementation FFMpegHelper

+ (void)mergeVideo:(NSString *)videoPath withAudio:(NSString *)audioPath captions:(NSString *)captionsPath duration:(long long)duration completion:(void (^)(BOOL success, NSString *outputPath))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tempDir = [self createTempDirectoryIfNeeded];
        NSString *outputPath = [tempDir stringByAppendingPathComponent:@"output.mp4"];

        // Remove existing output
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];

        YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
        BOOL embedThumbnails = [defaults boolForKey:@"EmbedThumbnailsToVideos"];
        BOOL embedCaptions = [defaults boolForKey:@"EmbedCapsToVideos"];

        NSString *command = [self getCommandWithVideoURL:videoPath
                                               audioURL:audioPath
                                            captionsURL:(embedCaptions ? captionsPath : nil)
                                           thumbnailURL:nil
                                               duration:duration
                                              outputURL:outputPath];

        int result = [MobileFFmpeg execute:command];

        BOOL success = (result == 0) && [[NSFileManager defaultManager] fileExistsAtPath:outputPath];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success, outputPath);
        });
    });
}

+ (void)cutAudio:(NSString *)audioPath duration:(long long)duration completion:(void (^)(BOOL success, NSString *outputPath))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tempDir = [self createTempDirectoryIfNeeded];
        NSString *outputPath = [tempDir stringByAppendingPathComponent:@"output.m4a"];

        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];

        // Simple copy/remux for audio
        NSString *command = [NSString stringWithFormat:@"-y -i \"%@\" -c copy \"%@\"", audioPath, outputPath];

        int result = [MobileFFmpeg execute:command];

        BOOL success = (result == 0) && [[NSFileManager defaultManager] fileExistsAtPath:outputPath];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success, success ? outputPath : audioPath);
        });
    });
}

+ (NSString *)getCommandWithVideoURL:(NSString *)videoURL audioURL:(NSString *)audioURL captionsURL:(NSString *)captionsURL thumbnailURL:(NSString *)thumbnailURL duration:(long long)duration outputURL:(NSString *)outputURL {
    NSMutableString *command = [NSMutableString stringWithString:@"-y"];

    // Input video
    if (videoURL) {
        [command appendFormat:@" -i \"%@\"", videoURL];
    }

    // Input audio
    if (audioURL) {
        [command appendFormat:@" -i \"%@\"", audioURL];
    }

    // Input captions (SRT)
    if (captionsURL && captionsURL.length > 0) {
        [command appendFormat:@" -i \"%@\"", captionsURL];
    }

    // Input thumbnail
    if (thumbnailURL && thumbnailURL.length > 0) {
        [command appendFormat:@" -i \"%@\"", thumbnailURL];
    }

    // Map streams
    if (videoURL && audioURL) {
        [command appendString:@" -map 0:v -map 1:a"];

        if (captionsURL && captionsURL.length > 0) {
            [command appendString:@" -map 2:s"];
        }

        // Copy codecs (no re-encoding)
        [command appendString:@" -c:v copy -c:a copy"];

        if (captionsURL && captionsURL.length > 0) {
            [command appendString:@" -c:s mov_text"];
        }
    } else if (videoURL) {
        [command appendString:@" -map 0 -c copy"];
    } else if (audioURL) {
        [command appendString:@" -map 0 -c copy"];
    }

    // Shortest flag to match video/audio duration
    if (videoURL && audioURL) {
        [command appendString:@" -shortest"];
    }

    // Output
    [command appendFormat:@" \"%@\"", outputURL];

    return command;
}

+ (void)closeFFmpegPipe:(NSString *)pipe {
    if (pipe) {
        [MobileFFmpegConfig closeFFmpegPipe:pipe];
    }
}

+ (NSString *)createTempDirectoryIfNeeded {
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:kTempDirectoryName];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:tempDir]) {
        NSError *error;
        [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"YTPlus --- Error creating temporary directory: %@", error);
            return NSTemporaryDirectory();
        }
    }

    return tempDir;
}

@end
