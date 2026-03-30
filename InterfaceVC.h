#ifndef InterfaceVC_h
#define InterfaceVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;

@interface InterfaceVC : UITableViewController

@property (nonatomic, strong) NSArray *interface;
@property (nonatomic, strong) NSArray *startup;
@property (nonatomic, strong) NSArray *style;
@property (nonatomic, strong) NSArray *mpStyle;
@property (nonatomic, strong) NSArray *other;
@property (nonatomic, strong) NSArray *menu;
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
- (void)setSegment:(UISegmentedControl *)sender;

@end

#endif /* InterfaceVC_h */
