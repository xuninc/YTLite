#ifndef ShortsVC_h
#define ShortsVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;

@interface ShortsVC : UITableViewController

@property (nonatomic, strong) NSArray *main;
@property (nonatomic, strong) NSArray *playback;
@property (nonatomic, strong) NSArray *shorts;
@property (nonatomic, strong) NSArray *interface_;
@property (nonatomic, strong) NSArray *sections;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UISegmentedControl *)segmentForItems:(NSArray *)items;
- (void)toggleSwitch:(id)sender;
- (void)setSegment:(id)sender;
- (void)showSheet:(NSIndexPath *)indexPath title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key;
- (UIImage *)segmentIcon:(NSString *)name;

@end

#endif /* ShortsVC_h */
