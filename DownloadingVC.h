#ifndef DownloadingVC_h
#define DownloadingVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;

@interface DownloadingVC : UITableViewController

@property (nonatomic, strong) NSArray *downloading;
@property (nonatomic, strong) NSArray *position;
@property (nonatomic, strong) NSArray *behavior;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSArray *audio;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) NSArray *sections;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UISegmentedControl *)segmentForItems:(NSArray *)items;
- (void)toggleSwitch:(id)sender;
- (void)setSegment:(id)sender;

@end

#endif /* DownloadingVC_h */
