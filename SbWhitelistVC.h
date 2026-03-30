#ifndef SbWhitelistVC_h
#define SbWhitelistVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewController;
@class YTLUserDefaults;
@class YTColor;

@interface SbWhitelistVC : YTLTableViewController

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UIBarButtonItem *sortButton;

- (instancetype)init;
- (void)setupWhitelist;
- (void)loadView;
- (void)closeButtonTapped;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
- (NSArray *)getSortActions;
- (void)updateSortMenu;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeChannelWithLink:(NSString *)link;
- (UIImage *)ytlImageWithName:(NSString *)name;
- (UIImage *)channelImage:(NSDictionary *)channel;

@end

#endif /* SbWhitelistVC_h */
