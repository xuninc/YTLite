#ifndef PrefsVC_h
#define PrefsVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;
@class ABCSwitch;
@class YTAlertView;

@interface PrefsVC : UITableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *prefs;
@property (nonatomic, strong) NSArray *cache;
@property (nonatomic, strong) NSArray *other;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleSwitch:(id)sender;
- (void)importPrefs;
- (void)exportPrefs:(NSIndexPath *)indexPath;
- (void)resetSettings;
- (void)clearCache:(NSIndexPath *)indexPath;
- (void)getCacheSizeWithCompletion:(void (^)(NSString *sizeString))completion;

@end

#endif /* PrefsVC_h */
