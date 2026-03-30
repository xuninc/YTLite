#ifndef YTLUserDefaultsFull_h
#define YTLUserDefaultsFull_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface YTLUserDefaults : NSUserDefaults <UIDocumentPickerDelegate>

@property (nonatomic, copy) void (^prefsPickerCompletion)(BOOL success);

+ (instancetype)standardUserDefaults;
- (void)reset;
- (void)registerDefaults;
- (UIColor *)colorForSegment:(NSString *)segment;
- (NSString *)sbPrivateUserID;
- (NSString *)sbPublicUserID:(NSString *)privateID;
- (void)importYtlSettings:(void (^)(BOOL success))completion;
- (void)presentDocumentPicker:(UIViewController *)viewController;
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url;
- (void)exportYtlSettings:(UIViewController *)viewController;
- (void)resetUserDefaults;

@end

#endif /* YTLUserDefaultsFull_h */
