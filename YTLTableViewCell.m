#import "YTLTableViewCell.h"

static const CGFloat kHighlightRed   = 0.75;
static const CGFloat kHighlightGreen = 0.5;
static const CGFloat kHighlightBlue  = 0.647;
static const CGFloat kHighlightAlpha = 0.5;
static const CGFloat kInitAlpha      = 0.37;

@implementation YTLTableViewCell

#pragma mark - Selection

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (!selected) {
        [UIView animateWithDuration:0.5 animations:^{
            self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        }];
    } else {
        self.selectedBackgroundView.alpha = 1.0;
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:kHighlightRed
                                                                     green:kHighlightGreen
                                                                      blue:kHighlightBlue
                                                                     alpha:kHighlightAlpha];
    }
}

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Set background color to clear
        self.backgroundColor = [UIColor clearColor];

        // Create and set selectedBackgroundView
        UIView *selectedBgView = [[UIView alloc] init];
        self.selectedBackgroundView = selectedBgView;

        // Set initial highlight color for selectedBackgroundView
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:kHighlightRed
                                                                     green:kHighlightGreen
                                                                      blue:kHighlightBlue
                                                                     alpha:kInitAlpha];

        // Get screen scale to determine font size
        CGFloat scale = [[UIScreen mainScreen] scale];

        // Set text label font size: 16.0 for 3x scale, 14.0 otherwise
        CGFloat fontSize = (scale == 3.0) ? 16.0 : 14.0;
        UIFont *textFont = [UIFont systemFontOfSize:fontSize];
        [[self textLabel] setFont:textFont];

        // Set text label line break mode to truncate tail
        [[self textLabel] setLineBreakMode:NSLineBreakByTruncatingTail];

        // Set detail text label color to secondary label color
        [[self detailTextLabel] setTextColor:[UIColor secondaryLabelColor]];

        // Set detail text label font size to 12.0
        [[self detailTextLabel] setFont:[UIFont systemFontOfSize:12.0]];

        // Set detail text label number of lines to 0 (unlimited)
        [[self detailTextLabel] setNumberOfLines:0];
    }
    return self;
}

@end
