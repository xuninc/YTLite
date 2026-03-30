#ifndef YTLTableViewController_h
#define YTLTableViewController_h

#import <UIKit/UIKit.h>

@interface YTLTableViewController : UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style;
- (void)loadView;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIButton *)menuButtonWithTitle:(NSString *)title array:(NSArray *)array key:(NSString *)key;
- (UIImage *)systemImage:(NSString *)name withSize:(CGFloat)size;
- (BOOL)isRTL;

@end

#endif /* YTLTableViewController_h */
