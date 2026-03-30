#ifndef SettingsViewController_h
#define SettingsViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;
@class YTWrapperSplitViewController;
@class YTDefaultSheetController;
@class YTActionSheetAction;
@class YTUIUtils;
@class YTToastController;

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *main;
@property (nonatomic, strong) NSArray *additional;
@property (nonatomic, strong) NSArray *developer;
@property (nonatomic, strong) NSArray *credits;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)devCellImage:(id)image;
- (UIImage *)iconImageNamed:(id)name;
- (UIImage *)accessoryImage:(id)name;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)showDonationSheet:(id)sender;
- (UIImage *)imageNamed:(id)name;

@end

#endif /* SettingsViewController_h */
