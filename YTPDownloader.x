// YTPDownloader.x - Core chunked file downloader
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"

static NSString *const kChunkMapFileName = @"chunkmap.plist";
static const long long kDefaultChunkSize = 10 * 1024 * 1024; // 10MB chunks

@implementation YTPDownloader

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadedChunks = [NSMutableDictionary dictionary];
        _chunkSize = kDefaultChunkSize;
        _cancelRequested = NO;
        _downloading = NO;
        _isVideoDownloaded = NO;
        _downloadedSize = 0;
        _totalDownloadedBytes = 0;
    }
    return self;
}

- (void)downloadFileWithURL:(NSURL *)url fileName:(NSString *)fileName fileSize:(long long)fileSize {
    [self downloadFileWithURL:url fileName:fileName videoID:nil fileSize:fileSize];
}

- (void)downloadFileWithURL:(NSURL *)url fileName:(NSString *)fileName videoID:(NSString *)videoID fileSize:(long long)fileSize {
    NSLog(@"YTPlus --- Starting downloading file from url: %@", url);

    self.fileName = fileName;
    self.fileURL = url;
    self.totalFileSize = fileSize;
    self.totalExpectedBytes = fileSize;
    self.cancelRequested = NO;
    self.downloading = YES;
    self.isVideoDownloaded = NO;
    self.downloadedSize = 0;
    self.totalDownloadedBytes = 0;

    // Calculate total chunks
    if (fileSize > 0 && _chunkSize > 0) {
        _totalChunks = (fileSize + _chunkSize - 1) / _chunkSize;
    } else {
        _totalChunks = 1;
    }

    // Setup file path in tmp directory
    NSString *tempDir = [FFMpegHelper createTempDirectoryIfNeeded];
    self.filePath = [tempDir stringByAppendingPathComponent:fileName];
    self.chunkMapPath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", videoID ?: @"file", kChunkMapFileName]];

    // Check for existing partial download
    [self loadChunkMap];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.filePath]) {
        NSDictionary *attrs = [fm attributesOfItemAtPath:self.filePath error:nil];
        long long existingSize = [attrs fileSize];

        // Validate existing data
        NSString *existingHash = [self hashForFile:self.filePath fileSize:existingSize];
        NSString *savedHash = self.downloadedChunks[@"hash"];

        if (savedHash && ![existingHash isEqualToString:savedHash]) {
            NSLog(@"YTPlus --- Hash not matching, removing old files");
            [fm removeItemAtPath:self.filePath error:nil];
            [self.downloadedChunks removeAllObjects];
            [self saveChunkMap];
        } else if (existingSize >= fileSize && fileSize > 0) {
            NSLog(@"YTPlus --- File already downloaded");
            self.downloading = NO;
            self.isVideoDownloaded = YES;
            if ([self.delegate respondsToSelector:@selector(downloadDidFinish:fileName:)]) {
                [self.delegate downloadDidFinish:self.filePath fileName:self.fileName];
            }
            return;
        } else {
            self.downloadedSize = existingSize;
            self.totalDownloadedBytes = existingSize;
        }
    }

    // Create file if needed
    if (![fm fileExistsAtPath:self.filePath]) {
        [fm createFileAtPath:self.filePath contents:nil attributes:nil];
    }

    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];

    // Setup URL session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    config.timeoutIntervalForResource = 600;
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    // Start downloading chunks
    [self downloadNextChunk];
}

- (void)downloadNextChunk {
    if (self.cancelRequested) {
        [self cleanupWithError:nil];
        return;
    }

    // Check if download is complete
    if (self.totalFileSize > 0 && self.downloadedSize >= self.totalFileSize) {
        NSLog(@"YTPlus --- File has been downloaded");
        [self finishDownload];
        return;
    }

    // Calculate range for next chunk
    long long rangeStart = self.downloadedSize;
    long long rangeEnd = rangeStart + self.chunkSize - 1;
    if (self.totalFileSize > 0 && rangeEnd >= self.totalFileSize) {
        rangeEnd = self.totalFileSize - 1;
    }

    NSString *chunkKey = [NSString stringWithFormat:@"%lld", rangeStart];
    if (self.downloadedChunks[chunkKey]) {
        // Chunk already downloaded, skip to next
        NSLog(@"YTPlus --- Continuing download of chunk from %lld to %lld", rangeStart, rangeEnd);
        self.downloadedSize = rangeEnd + 1;
        [self downloadNextChunk];
        return;
    }

    NSLog(@"YTPlus --- Downloading new chunk %lld-%lld", rangeStart, rangeEnd);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.fileURL];
    NSString *rangeHeader = [NSString stringWithFormat:@"bytes=%lld-%lld", rangeStart, rangeEnd];
    [request setValue:rangeHeader forHTTPHeaderField:@"Range"];

    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

- (void)continueDownloadingForURL:(NSURL *)url {
    self.fileURL = url;
    [self downloadNextChunk];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];

    if (!data || data.length == 0) {
        NSLog(@"YTPlus --- Invalid chunk data detected, removing old files");
        [self cleanupWithError:[NSError errorWithDomain:@"YTPDownloader" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Empty chunk data"}]];
        return;
    }

    @try {
        [self.fileHandle seekToEndOfFile];
        [self.fileHandle writeData:data];
    } @catch (NSException *exception) {
        NSLog(@"YTPlus --- Error while downloading: %@", exception.reason);
        return;
    }

    long long chunkStart = self.downloadedSize;
    self.downloadedSize += data.length;
    self.totalDownloadedBytes += data.length;

    // Save chunk progress
    NSString *chunkKey = [NSString stringWithFormat:@"%lld", chunkStart];
    self.downloadedChunks[chunkKey] = @(data.length);

    // Update hash
    self.downloadedChunks[@"hash"] = [self hashForFile:self.filePath fileSize:self.downloadedSize];
    [self saveChunkMap];

    // Report progress
    if (self.totalFileSize > 0) {
        float progress = (float)self.downloadedSize / (float)self.totalFileSize;
        NSLog(@"YTPlus --- Downloading progress: %.2f%%", progress * 100);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(downloadProgress:)]) {
                [self.delegate downloadProgress:progress];
            }
        });
    }

    // Continue to next chunk
    [self downloadNextChunk];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // Per-chunk progress - can be used for finer progress updates
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"YTPlus --- Continuing download of chunk from %lld to %lld", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && !self.cancelRequested) {
        NSLog(@"YTPlus --- Error while downloading: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(downloadDidFailureWithError:)]) {
                [self.delegate downloadDidFailureWithError:error];
            }
        });
    }
}

#pragma mark - Chunk Map Persistence

- (void)loadChunkMap {
    NSData *data = [NSData dataWithContentsOfFile:self.chunkMapPath];
    if (data) {
        NSError *error;
        NSDictionary *map = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainers format:nil error:&error];
        if (error) {
            NSLog(@"YTPlus --- Error parsing plist data: %@", error);
            self.downloadedChunks = [NSMutableDictionary dictionary];
        } else {
            self.downloadedChunks = [map mutableCopy];
        }
    }
}

- (void)saveChunkMap {
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.downloadedChunks format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (data) {
        [data writeToFile:self.chunkMapPath atomically:YES];
    }
}

- (NSString *)hashForFile:(NSString *)file fileSize:(long long)fileSize {
    return [NSString stringWithFormat:@"%@_%lld", [file lastPathComponent], fileSize];
}

#pragma mark - Cancel / Cleanup

- (void)cancelDownload {
    self.cancelRequested = YES;
    [self.downloadTask cancel];
    [self.session invalidateAndCancel];
    self.downloading = NO;
}

- (void)finishDownload {
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    self.downloading = NO;
    self.isVideoDownloaded = YES;

    // Clean up chunk map
    [[NSFileManager defaultManager] removeItemAtPath:self.chunkMapPath error:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downloadDidFinish:fileName:)]) {
            [self.delegate downloadDidFinish:self.filePath fileName:self.fileName];
        }
    });
}

- (void)cleanupWithError:(NSError *)error {
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    self.downloading = NO;

    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(downloadDidFailureWithError:)]) {
                [self.delegate downloadDidFailureWithError:error];
            }
        });
    }
}

- (void)dealloc {
    [self.fileHandle closeFile];
    [self.session invalidateAndCancel];
}

@end
