#ifndef TabbarVC_h
#define TabbarVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;

@interface TabbarVC : UITableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic, strong) NSArray *startup;
@property (nonatomic, strong) NSArray *tabbar;
@property (nonatomic, strong) NSMutableArray *activeTabs;
@property (nonatomic, strong) NSMutableArray *inactiveTabs;
@property (nonatomic, assign) BOOL isSettings;

- (instancetype)init;
- (instancetype)initForSettings:(BOOL)isSettings;
- (void)loadView;
- (void)closeButtonTapped;
- (void)initTabs;
- (void)saveTabsOrder;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)iconImageNamed:(NSString *)name;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)switchForKey:(NSString *)key;
- (void)toggleSwitch:(id)sender;
- (UISegmentedControl *)segmentForItems:(NSArray *)items;
- (void)setSegment:(UISegmentedControl *)sender;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* TabbarVC_h */
