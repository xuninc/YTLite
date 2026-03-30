#import "TabbarVC.h"
#import "YTLTableViewCell.h"
#import "YTLUserDefaults.h"

@implementation TabbarVC

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initForSettings:(BOOL)isSettings {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.isSettings = isSettings;

        self.tabbar = @[];
        self.startup = @[];
        self.activeTabs = [NSMutableArray array];
        self.inactiveTabs = [NSMutableArray array];

        self.tabs = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.tabbar,
                         self.startup,
                         self.activeTabs,
                         self.inactiveTabs,
                         nil];

        [self.tableView setEditing:YES animated:NO];
        [self.tableView setAllowsSelectionDuringEditing:YES];
    }
    return self;
}

- (void)loadView {
    [super loadView];

    [self setTitle:@"Tabbar"];

    if (!self.isSettings) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemClose
            target:self
            action:@selector(closeButtonTapped)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }

    [self.tableView setBackgroundColor:[UIColor systemGroupedBackgroundColor]];
}

- (void)closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initTabs {
    [self.activeTabs removeAllObjects];
    [self.inactiveTabs removeAllObjects];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    NSArray *savedOrder = [defaults objectForKey:@"activeTabs"];

    if (savedOrder != nil) {
        for (NSString *key in savedOrder) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
            NSArray *filtered = [self.tabs filteredArrayUsingPredicate:predicate];
            if ([filtered count] > 0) {
                [self.activeTabs addObject:[filtered firstObject]];
            }
        }
    }

    for (NSDictionary *tab in self.tabs) {
        if (![self.activeTabs containsObject:tab]) {
            [self.inactiveTabs addObject:tab];
        }
    }
}

- (void)saveTabsOrder {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSDictionary *tab in self.activeTabs) {
        NSString *key = [tab objectForKey:@"key"];
        [keys addObject:key];
    }

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    [defaults setObject:keys forKey:@"activeTabs"];

    NSUInteger startupIndex = [self.sections indexOfObject:self.startup];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:startupIndex];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"YTHCCVCRefresh" object:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger startupIndex = [self.sections indexOfObject:self.startup];
    if ((NSInteger)startupIndex == section) {
        return [bundle localizedStringForKey:@"Startup" value:nil table:nil];
    }

    NSUInteger tabbarIndex = [self.sections indexOfObject:self.tabbar];
    if ((NSInteger)tabbarIndex == section) {
        return [bundle localizedStringForKey:@"Main" value:nil table:nil];
    }

    NSUInteger activeIndex = [self.sections indexOfObject:self.activeTabs];
    if ((NSInteger)activeIndex == section) {
        return [bundle localizedStringForKey:@"ActiveTabs" value:nil table:nil];
    }

    NSUInteger inactiveIndex = [self.sections indexOfObject:self.inactiveTabs];
    if ((NSInteger)inactiveIndex == section) {
        return [bundle localizedStringForKey:@"InactiveTabs" value:nil table:nil];
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSUInteger inactiveIndex = [self.sections indexOfObject:self.inactiveTabs];
    if ((NSInteger)inactiveIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        return [bundle localizedStringForKey:@"HideLibraryFooter" value:nil table:nil];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [self.sections objectAtIndex:section];
    return (NSInteger)[sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    if (item == nil) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        return cell;
    }

    NSNumber *styleValue = [item objectForKey:@"style"];
    NSInteger style = UITableViewCellStyleSubtitle;
    if (styleValue != nil) {
        style = [styleValue integerValue];
    }

    NSString *reuseId = [item objectForKey:@"id"];
    YTLTableViewCell *cell = [[YTLTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseId];

    NSString *titleKey = [item objectForKey:@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localizedTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        [[cell detailTextLabel] setText:localizedDesc];

        NSString *key = [item objectForKey:@"key"];
        id toggle = [self switchForKey:key];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [toggle setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        [cell setAccessoryView:toggle];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

    if ([type isEqualToString:@"int"]) {
        NSArray *items = [item objectForKey:@"indexes"];
        UISegmentedControl *segment = [self segmentForItems:items];

        NSString *key = [item objectForKey:@"key"];
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSInteger selectedIndex = [[defaults objectForKey:key] integerValue];
        [segment setSelectedSegmentIndex:selectedIndex];

        [cell setAccessoryView:segment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

    if ([type isEqualToString:@"tab"]) {
        NSString *iconName = [item objectForKey:@"icon"];
        UIImage *icon = [self iconImageNamed:iconName];
        [[cell imageView] setImage:icon];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localizedTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        return cell;
    }

    return cell;
}

- (UIImage *)iconImageNamed:(NSString *)name {
    CGSize size = CGSizeMake(24.0, 24.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];

    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        UIImage *sourceImage = [UIImage imageNamed:name];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [imageView setImage:sourceImage];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setClipsToBounds:YES];
        [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }];

    return image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        id toggle = [cell accessoryView];
        [toggle setOn:![toggle isOn] animated:YES];
        [self toggleSwitch:toggle];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"YTHCCVCRefresh" object:nil];
}

- (id)switchForKey:(NSString *)key {
    id toggle = [[NSClassFromString(@"ABCSwitch") alloc] init];

    UIColor *tintColor = self.navigationController.navigationBar.tintColor;
    [toggle setOnTintColor:tintColor];

    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *thumbColor = [whiteColor colorWithAlphaComponent:0.5];
    [toggle setThumbTintColor:thumbColor];

    [toggle addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    BOOL isOn = [[defaults objectForKey:key] boolValue];
    [toggle setOn:isOn animated:NO];

    return toggle;
}

- (void)toggleSwitch:(id)sender {
    NSInteger tag = [sender tag];
    NSInteger section = (tag >> 16) & 0xFFFF;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:section];
    NSDictionary *item = [sectionArray objectAtIndex:row];
    NSString *key = [item objectForKey:@"key"];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    [defaults setObject:@([(UISwitch *)sender isOn]) forKey:key];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"YTHCCVCRefresh" object:nil];
}

- (UISegmentedControl *)segmentForItems:(NSArray *)items {
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];

    UIColor *tintColor = self.navigationController.navigationBar.tintColor;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: tintColor};
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];

    NSInteger index = 0;
    for (NSDictionary *tab in items) {
        NSString *iconName = [tab objectForKey:@"icon"];
        UIImage *icon = [self iconImageNamed:iconName];
        [segmentedControl insertSegmentWithImage:icon atIndex:index animated:NO];
        index++;
    }

    [segmentedControl addTarget:self action:@selector(setSegment:) forControlEvents:UIControlEventValueChanged];

    return segmentedControl;
}

- (void)setSegment:(UISegmentedControl *)sender {
    NSInteger selectedIndex = [sender selectedSegmentIndex];

    if (selectedIndex < (NSInteger)[self.activeTabs count]) {
        NSDictionary *tab = [self.activeTabs objectAtIndex:selectedIndex];
        NSString *tabKey = [tab objectForKey:@"key"];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        [defaults setObject:tabKey forKey:@"startupTab"];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger activeIndex = [self.sections indexOfObject:self.activeTabs];
    NSUInteger inactiveIndex = [self.sections indexOfObject:self.inactiveTabs];

    NSInteger section = [indexPath section];
    if (section == (NSInteger)activeIndex || section == (NSInteger)inactiveIndex) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger activeIndex = [self.sections indexOfObject:self.activeTabs];
    NSInteger section = [indexPath section];
    if (section == (NSInteger)activeIndex) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if ([sourceIndexPath section] == [proposedDestinationIndexPath section]) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSInteger fromRow = [sourceIndexPath row];
    NSInteger toRow = [destinationIndexPath row];

    id object = [self.activeTabs objectAtIndex:fromRow];
    [self.activeTabs removeObjectAtIndex:fromRow];
    [self.activeTabs insertObject:object atIndex:toRow];

    [self saveTabsOrder];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger activeIndex = [self.sections indexOfObject:self.activeTabs];
    NSUInteger inactiveIndex = [self.sections indexOfObject:self.inactiveTabs];

    NSInteger section = [indexPath section];
    if (section == (NSInteger)activeIndex) {
        return UITableViewCellEditingStyleDelete;
    }
    if (section == (NSInteger)inactiveIndex) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger activeIndex = [self.sections indexOfObject:self.activeTabs];
    NSUInteger inactiveIndex = [self.sections indexOfObject:self.inactiveTabs];
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    if (editingStyle == UITableViewCellEditingStyleInsert && section == (NSInteger)inactiveIndex) {
        if ([self.activeTabs count] >= 6) {
            return;
        }

        id tab = [self.inactiveTabs objectAtIndex:row];
        [self.inactiveTabs removeObjectAtIndex:row];
        [self.activeTabs addObject:tab];

        [tableView beginUpdates];
        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:row inSection:inactiveIndex];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:[self.activeTabs count] - 1 inSection:activeIndex];
        [tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];

        [self saveTabsOrder];
    }

    if (editingStyle == UITableViewCellEditingStyleDelete && section == (NSInteger)activeIndex) {
        if ([self.activeTabs count] <= 1) {
            return;
        }

        id tab = [self.activeTabs objectAtIndex:row];
        [self.activeTabs removeObjectAtIndex:row];
        [self.inactiveTabs addObject:tab];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *startupTab = [defaults objectForKey:@"startupTab"];
        NSString *removedKey = [tab objectForKey:@"key"];
        if ([startupTab isEqualToString:removedKey]) {
            NSDictionary *firstTab = [self.activeTabs firstObject];
            NSString *newStartupKey = [firstTab objectForKey:@"key"];
            [defaults setObject:newStartupKey forKey:@"startupTab"];
        }

        [tableView beginUpdates];
        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:row inSection:activeIndex];
        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:[self.inactiveTabs count] - 1 inSection:inactiveIndex];
        [tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];

        [self saveTabsOrder];
    }
}

@end
