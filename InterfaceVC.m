#import "InterfaceVC.h"
#import "YTLTableViewCell.h"
#import "YTLUserDefaults.h"

@implementation InterfaceVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.interface = @[];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *defaultStr = [bundle localizedStringForKey:@"Default" value:nil table:nil];
        NSString *showStr = [bundle localizedStringForKey:@"Show" value:nil table:nil];
        NSString *disableStr = [bundle localizedStringForKey:@"Disable" value:nil table:nil];

        NSArray *startupIndexes = [NSArray arrayWithObjects:defaultStr, showStr, disableStr, nil];

        NSDictionary *startupDict = [NSDictionary dictionaryWithObjects:
                                     @[startupIndexes, @"int", @"startupAnimation", @"startupCell"]
                                                                forKeys:
                                     @[@"indexes", @"type", @"key", @"id"]
                                                                  count:4];

        self.startup = [NSArray arrayWithObjects:startupDict, nil];

        NSString *defaultStr2 = [bundle localizedStringForKey:@"Default" value:nil table:nil];
        NSArray *styleIndexes = [NSArray arrayWithObjects:defaultStr2, @"iPhone", @"iPad", nil];

        NSDictionary *styleDict = [NSDictionary dictionaryWithObjects:
                                   @[styleIndexes, @"int", @"idiomIndex", @"idiomCell"]
                                                              forKeys:
                                   @[@"indexes", @"type", @"key", @"id"]
                                                                count:4];

        self.style = [NSArray arrayWithObjects:styleDict, nil];

        NSString *defaultStr3 = [bundle localizedStringForKey:@"Default" value:nil table:nil];
        NSString *floatingStr = [bundle localizedStringForKey:@"Floating" value:nil table:nil];

        NSArray *mpStyleIndexes = [NSArray arrayWithObjects:defaultStr3, @"iPhone", @"iPad", floatingStr, nil];

        NSDictionary *mpStyleDict = [NSDictionary dictionaryWithObjects:
                                     @[mpStyleIndexes, @"int", @"miniPlayerIndex", @"mpCell"]
                                                                forKeys:
                                     @[@"indexes", @"type", @"key", @"id"]
                                                                  count:4];

        self.mpStyle = [NSArray arrayWithObjects:mpStyleDict, nil];

        self.other = @[];
        self.menu = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.interface,
                         self.startup,
                         self.style,
                         self.mpStyle,
                         self.other,
                         self.menu,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger interfaceIndex = [self.sections indexOfObject:self.interface];
    if ((NSInteger)interfaceIndex == section) {
        return [bundle localizedStringForKey:@"Interface" value:nil table:nil];
    }

    NSUInteger startupIndex = [self.sections indexOfObject:self.startup];
    if ((NSInteger)startupIndex == section) {
        return [bundle localizedStringForKey:@"StartupAnimation" value:nil table:nil];
    }

    NSUInteger styleIndex = [self.sections indexOfObject:self.style];
    if ((NSInteger)styleIndex == section) {
        return [bundle localizedStringForKey:@"InterfaceStyle" value:nil table:nil];
    }

    NSUInteger mpStyleIndex = [self.sections indexOfObject:self.mpStyle];
    if ((NSInteger)mpStyleIndex == section) {
        return [bundle localizedStringForKey:@"MiniplayerStyle" value:nil table:nil];
    }

    NSUInteger otherIndex = [self.sections indexOfObject:self.other];
    if ((NSInteger)otherIndex == section) {
        return [bundle localizedStringForKey:@"Other" value:nil table:nil];
    }

    NSUInteger menuIndex = [self.sections indexOfObject:self.menu];
    if ((NSInteger)menuIndex == section) {
        return [bundle localizedStringForKey:@"ContextMenu" value:nil table:nil];
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger startupIndex = [self.sections indexOfObject:self.startup];
    if ((NSInteger)startupIndex == section) {
        return [bundle localizedStringForKey:@"StartupAnimationDesc" value:nil table:nil];
    }

    NSUInteger mpStyleIndex = [self.sections indexOfObject:self.mpStyle];
    if ((NSInteger)mpStyleIndex == section) {
        return [bundle localizedStringForKey:@"MiniplayerStyleDesc" value:nil table:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[YTLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath section]];

    if (item == nil) {
        return cell;
    }

    sectionArray = [self.sections objectAtIndex:[indexPath section]];
    item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *reuseId = item[@"id"];
    cell = [[YTLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];

    NSString *titleKey = item[@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];

    NSString *type = item[@"type"];

    if ([type isEqualToString:@"bool"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = item[@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        [[cell detailTextLabel] setText:localizedDesc];

        id toggle = [[NSClassFromString(@"ABCSwitch") alloc] init];

        UIColor *onTintColor = [UIColor colorWithRed:0.75 green:0.5 blue:0.85 alpha:1.0];
        [toggle setOnTintColor:onTintColor];

        UIColor *grayColor = [UIColor grayColor];
        UIColor *offTrackColor = [grayColor colorWithAlphaComponent:0.5];
        [toggle setOffTrackColor:offTrackColor];

        [toggle addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];

        NSInteger tagSection = [indexPath section];
        NSInteger tagRow = [indexPath row];
        [toggle setTag:(tagRow & 0xFFFF) | (tagSection << 16)];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = item[@"key"];
        BOOL isOn = [defaults boolForKey:key];
        [toggle setOn:isOn];

        [cell setAccessoryView:toggle];
    }

    type = item[@"type"];
    if ([type isEqualToString:@"int"]) {
        NSArray *indexes = item[@"indexes"];
        UISegmentedControl *segmentedControl = [self segmentForItems:indexes];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = item[@"key"];
        NSInteger selectedIndex = [defaults integerForKey:key];
        [segmentedControl setSelectedSegmentIndex:selectedIndex];

        NSInteger tagSection = [indexPath section];
        NSInteger tagRow = [indexPath row];
        [segmentedControl setTag:(tagRow & 0xFFFF) | (tagSection << 16)];

        [segmentedControl addTarget:self action:@selector(setSegment:) forControlEvents:UIControlEventValueChanged];

        UIView *contentView = [cell contentView];
        [contentView addSubview:segmentedControl];

        [[segmentedControl leadingAnchor] constraintEqualToAnchor:[[cell contentView] leadingAnchor]].active = YES;
        [[segmentedControl trailingAnchor] constraintEqualToAnchor:[[cell contentView] trailingAnchor]].active = YES;
        [[segmentedControl centerYAnchor] constraintEqualToAnchor:[[cell contentView] centerYAnchor] constant:10.0].active = YES;
        [[segmentedControl bottomAnchor] constraintEqualToAnchor:[[cell contentView] bottomAnchor] constant:-10.0].active = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id sectionArray = self.sections;
    NSInteger section = [indexPath section];
    id sectionData = [sectionArray objectAtIndex:section];

    NSInteger row = [indexPath row];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    NSString *type = [rowInfo objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *accessoryView = [cell accessoryView];

        Class ABCSwitchClass = NSClassFromString(@"ABCSwitch");
        if ([accessoryView isKindOfClass:ABCSwitchClass]) {
            BOOL isOn = [(id)accessoryView isOn];
            [(id)accessoryView setOn:!isOn animated:YES];
            [accessoryView sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UISegmentedControl *)segmentForItems:(NSArray *)items {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];

    [segment setApportionsSegmentWidthsByContent:NO];

    for (UIView *subview in [segment subviews]) {
        for (UIView *innerView in [subview subviews]) {
            if ([innerView isKindOfClass:[UILabel class]]) {
                [(UILabel *)innerView setAdjustsFontSizeToFitWidth:YES];
            }
        }
    }

    return segment;
}

- (void)toggleSwitch:(id)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        BOOL isOn = [sender isOn];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setBool:isOn forKey:key];
    }
}

- (void)setSegment:(id)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSInteger selectedIndex = [sender selectedSegmentIndex];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setInteger:selectedIndex forKey:key];
    }
}

@end
