#import "YTLTableViewController.h"
#import "Utils/YTLUserDefaults.h"

static const CGFloat kSeparatorRed   = 0.75;
static const CGFloat kSeparatorGreen = 0.5;
static const CGFloat kSeparatorBlue  = 0.647;

@implementation YTLTableViewController

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];

    // Disable separator lines on table view
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // Set table view background color to clear
    [[self tableView] setBackgroundColor:[UIColor clearColor]];

    // Set table view content inset
    [[self tableView] setContentInset:UIEdgeInsetsMake(-10.0, 0, 20.0, 0)];

    // Set table view separator color
    UIColor *separatorColor = [UIColor colorWithRed:kSeparatorRed
                                              green:kSeparatorGreen
                                               blue:kSeparatorBlue
                                              alpha:1.0];
    [[self tableView] setSeparatorColor:separatorColor];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;

    // Set header text label font
    UIFont *headerFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight];
    [[headerView textLabel] setFont:headerFont];

    // Set header text label color
    [[headerView textLabel] setTextColor:[UIColor secondaryLabelColor]];

    // Get title for header in section and set as text
    NSString *headerTitle = [self tableView:tableView titleForHeaderInSection:section];
    [[headerView textLabel] setText:headerTitle];

    // Set text alignment to natural
    [[headerView textLabel] setTextAlignment:NSTextAlignmentNatural];

    // Set number of lines to 0 (unlimited)
    [[headerView textLabel] setNumberOfLines:0];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;

    // Set footer text label font
    UIFont *footerFont = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];
    [[footerView textLabel] setFont:footerFont];

    // Set footer text label color
    [[footerView textLabel] setTextColor:[UIColor secondaryLabelColor]];

    // Get title for footer in section and set as text
    NSString *footerTitle = [self tableView:tableView titleForFooterInSection:section];
    [[footerView textLabel] setText:footerTitle];

    // Set text alignment to natural
    [[footerView textLabel] setTextAlignment:NSTextAlignmentNatural];

    // Set number of lines to 0 (unlimited)
    [[footerView textLabel] setNumberOfLines:0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *footerTitle = [self tableView:tableView titleForFooterInSection:section];

    if (footerTitle == nil) {
        return 0.0;
    }

    UIFont *footerFont = [UIFont systemFontOfSize:13.0 weight:UIFontWeightLight];

    NSDictionary *attributes = @{ NSFontAttributeName: footerFont };

    CGFloat tableWidth = tableView.frame.size.width;
    CGRect boundingRect = [footerTitle boundingRectWithSize:CGSizeMake(tableWidth - 40.0, DBL_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];

    return ceil(CGRectGetHeight(boundingRect)) + 10.0;
}

#pragma mark - Helpers

- (UIButton *)menuButtonWithTitle:(NSString *)title array:(NSArray *)array key:(NSString *)key {
    // Creates a UIButton with a pull-down UIMenu for preference dropdowns.
    // Each item in `array` becomes a UIAction; selecting one saves to YTLUserDefaults under `key`.
    NSMutableArray *actions = [NSMutableArray array];
    NSInteger currentIndex = [[YTLUserDefaults standardUserDefaults] integerForKey:key];

    for (NSUInteger i = 0; i < [array count]; i++) {
        NSString *itemTitle = [array objectAtIndex:i];
        UIAction *action = [UIAction actionWithTitle:itemTitle image:nil identifier:nil handler:^(__kindof UIAction *act) {
            [[YTLUserDefaults standardUserDefaults] setInteger:(NSInteger)i forKey:key];
        }];

        if ((NSInteger)i == currentIndex) {
            [action setState:UIMenuElementStateOn];
        }
        [actions addObject:action];
    }

    UIMenu *menu = [UIMenu menuWithTitle:@"" children:actions];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setMenu:menu];
    [button setShowsMenuAsPrimaryAction:YES];

    return button;
}

- (UIImage *)systemImage:(NSString *)name withSize:(CGFloat)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size)];

    UIImage *result = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIImage *symbolImage = [UIImage systemImageNamed:name];

        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:size];
        UIImage *configuredImage = [symbolImage imageWithConfiguration:config];

        CGSize imageSize = [configuredImage size];
        CGFloat x = (size - imageSize.width) / 2.0;
        CGFloat y = (size - imageSize.height) / 2.0;
        CGRect drawRect = CGRectMake(x, y, imageSize.width, imageSize.height);

        [configuredImage drawInRect:drawRect];
    }];

    return result;
}

- (BOOL)isRTL {
    UISemanticContentAttribute semanticAttribute = [UIView appearance].semanticContentAttribute;
    UIUserInterfaceLayoutDirection layoutDirection = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:semanticAttribute];
    return (layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);
}

@end
