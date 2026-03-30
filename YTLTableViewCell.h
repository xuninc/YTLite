#ifndef YTLTableViewCell_h
#define YTLTableViewCell_h

#import <UIKit/UIKit.h>

@interface YTLTableViewCell : UITableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

#endif /* YTLTableViewCell_h */
