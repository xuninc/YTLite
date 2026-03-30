#import "SbWhitelistVC.h"

@implementation SbWhitelistVC

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.channels = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.channels,
                         nil];

        [self setupWhitelist];
    }
    return self;
}

- (void)setupWhitelist {
    /* TODO: Implement from Ghidra decompilation */
}

- (void)loadView {
    /* TODO: Implement from Ghidra decompilation */
}

static UIColor *_colorForUserInterfaceStyle(id traitCollection) {
    NSInteger style = [(id)traitCollection userInterfaceStyle];
    if (style == 2) {
        return [NSClassFromString(@"YTColor") performSelector:NSSelectorFromString(@"whiteColor")];
    } else {
        return [UIColor blackColor];
    }
}

- (void)closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger channelsIndex = [self.sections indexOfObject:self.channels];
    if ((NSInteger)channelsIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"Sb_Channels" value:nil table:nil];
        return localized;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    /* TODO: Implement from Ghidra decompilation */
}

- (NSArray *)getSortActions {
    /* TODO: Implement from Ghidra decompilation */
    return nil;
}

static void _saveSortTypeAndReload(SbWhitelistVC *self) {
    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    NSDictionary *sortInfo = [self valueForKey:@"sortType"];
    long long sortType = [(NSNumber *)sortInfo longLongValue];
    [defaults setObject:@(sortType) forKey:@"sbWhitelistSortType"];
    [self setupWhitelist];
    [self.tableView reloadData];
}

- (void)updateSortMenu {
    /* TODO: Implement from Ghidra decompilation */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [self.sections objectAtIndex:section];
    NSInteger count = (NSInteger)[sectionArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* TODO: Implement from Ghidra decompilation */
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /* TODO: Implement from Ghidra decompilation */
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* TODO: Implement from Ghidra decompilation */
    return nil;
}

static void _removeChannelByKey(id dataSource, id channelStore, id channelInfo) {
    NSString *key = [channelInfo objectForKey:@"key"];
    [dataSource performSelector:NSSelectorFromString(@"removeObjectForKey:") withObject:key];
    void (^completionHandler)(BOOL) = (__bridge void (^)(BOOL))((__bridge void *)(channelInfo) + 0x10);
    completionHandler(YES);
}

- (void)removeChannelWithLink:(NSString *)link {
    /* TODO: Implement from Ghidra decompilation */
}

- (UIImage *)ytlImageWithName:(NSString *)name {
    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return templateImage;
}

- (UIImage *)channelImage:(NSDictionary *)channel {
    /* TODO: Implement from Ghidra decompilation */
    return nil;
}

static void _FUN_0005338c(long param_1, id param_2) {
    /* TODO: Implement from Ghidra decompilation */
}

@end
