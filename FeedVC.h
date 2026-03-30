#ifndef FeedVC_h
#define FeedVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;

@interface FeedVC : UITableViewController

@property (nonatomic, strong) NSArray *main;
@property (nonatomic, strong) NSArray *sections;

- (instancetype)init;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleSwitch:(id)sender;

@end

#endif /* FeedVC_h */
