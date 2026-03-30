#import "DownloadingVC.h"
#import "YTLTableViewCell.h"
#import "Utils/YTLUserDefaults.h"

@implementation DownloadingVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloading = @[];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *underPlayer = [bundle localizedStringForKey:@"UnderPlayer" value:nil table:nil];
        NSString *overlay = [bundle localizedStringForKey:@"Overlay" value:nil table:nil];
        NSString *both = [bundle localizedStringForKey:@"Both" value:nil table:nil];
        NSArray *positionIndexes = [NSArray arrayWithObjects:underPlayer, overlay, both, nil];

        NSDictionary *positionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      positionIndexes, @"indexes",
                                      @"int",          @"type",
                                      @"ytlButtonIndex", @"key",
                                      @"positionCell", @"id",
                                      nil];
        self.position = @[positionDict];

        NSString *saveToPhotos = [bundle localizedStringForKey:@"SaveToPhotos" value:nil table:nil];
        NSString *share = [bundle localizedStringForKey:@"Share" value:nil table:nil];
        NSString *ask = [bundle localizedStringForKey:@"Ask" value:nil table:nil];
        NSArray *behaviorIndexes = [NSArray arrayWithObjects:saveToPhotos, share, ask, nil];

        NSDictionary *behaviorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      behaviorIndexes,      @"indexes",
                                      @"int",               @"type",
                                      @"postDownloadIndex", @"key",
                                      @"behaviorCell",      @"id",
                                      nil];
        self.behavior = @[behaviorDict];

        NSString *defaultTrack = [bundle localizedStringForKey:@"Default" value:nil table:nil];
        NSString *selected = [bundle localizedStringForKey:@"Selected" value:nil table:nil];
        NSString *english = [bundle localizedStringForKey:@"English" value:nil table:nil];
        NSString *askTrack = [bundle localizedStringForKey:@"Ask" value:nil table:nil];
        NSArray *tracksIndexes = [NSArray arrayWithObjects:defaultTrack, selected, english, askTrack, nil];

        NSDictionary *tracksDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    tracksIndexes,    @"indexes",
                                    @"int",           @"type",
                                    @"ytlAudioIndex", @"key",
                                    @"tracksCell",    @"id",
                                    nil];
        self.tracks = @[tracksDict];

        self.audio = @[];
        self.captions = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.downloading,
                         self.position,
                         self.behavior,
                         self.tracks,
                         self.audio,
                         self.captions,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger downloadingIndex = [self.sections indexOfObject:self.downloading];
    if ((NSInteger)downloadingIndex == section) {
        return [bundle localizedStringForKey:@"Downloading" value:nil table:nil];
    }

    NSUInteger positionIndex = [self.sections indexOfObject:self.position];
    if ((NSInteger)positionIndex == section) {
        return [bundle localizedStringForKey:@"YtlButtonPosition" value:nil table:nil];
    }

    NSUInteger behaviorIndex = [self.sections indexOfObject:self.behavior];
    if ((NSInteger)behaviorIndex == section) {
        return [bundle localizedStringForKey:@"PostDownloadAction" value:nil table:nil];
    }

    NSUInteger tracksIndex = [self.sections indexOfObject:self.tracks];
    if ((NSInteger)tracksIndex == section) {
        return [bundle localizedStringForKey:@"PreferredAudio" value:nil table:nil];
    }

    NSUInteger audioIndex = [self.sections indexOfObject:self.audio];
    if ((NSInteger)audioIndex == section) {
        return [bundle localizedStringForKey:@"Audios" value:nil table:nil];
    }

    NSUInteger captionsIndex = [self.sections indexOfObject:self.captions];
    if ((NSInteger)captionsIndex == section) {
        return [bundle localizedStringForKey:@"CaptionsAndThumbnails" value:nil table:nil];
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSUInteger behaviorIndex = [self.sections indexOfObject:self.behavior];
    if ((NSInteger)behaviorIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        return [bundle localizedStringForKey:@"PostDownloadDesc" value:nil table:nil];
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
    if (sectionArray == nil) {
        return cell;
    }

    sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *reuseId = [item objectForKey:@"id"];
    cell = [[YTLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];

    NSString *titleKey = [item objectForKey:@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localizedTitle = [bundle localizedStringForKey:[item objectForKey:@"title"] value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        [[cell detailTextLabel] setText:localizedDesc];

        id toggle = [[NSClassFromString(@"ABCSwitch") alloc] init];
        UIColor *onTintColor = [UIColor colorWithRed:0.75 green:0.5 blue:0.85 alpha:1.0];
        [toggle setOnTintColor:onTintColor];

        UIColor *whiteColor = [UIColor whiteColor];
        UIColor *thumbColor = [whiteColor colorWithAlphaComponent:0.5];
        [toggle setThumbTintColor:thumbColor];

        [toggle addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [toggle setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        BOOL isOn = [defaults boolForKey:key];
        [toggle setOn:isOn];

        [cell setAccessoryView:toggle];
    }

    type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"int"]) {
        NSArray *indexes = [item objectForKey:@"indexes"];
        UISegmentedControl *segment = [self segmentForItems:indexes];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        NSInteger savedIndex = [defaults integerForKey:key];
        [segment setSelectedSegmentIndex:savedIndex];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [segment setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        [segment addTarget:self action:@selector(setSegment:) forControlEvents:UIControlEventValueChanged];

        UIView *contentView = [cell contentView];
        [contentView addSubview:segment];

        [[segment leadingAnchor] constraintEqualToAnchor:[[cell contentView] leadingAnchor] constant:5.0].active = YES;
        [[segment trailingAnchor] constraintEqualToAnchor:[[cell contentView] trailingAnchor] constant:-5.0].active = YES;
        [[segment centerYAnchor] constraintEqualToAnchor:[[cell contentView] centerYAnchor] constant:10.0].active = YES;
        [[segment bottomAnchor] constraintEqualToAnchor:[[cell contentView] bottomAnchor] constant:-10.0].active = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *accessory = [cell accessoryView];
        if ([accessory isKindOfClass:NSClassFromString(@"ABCSwitch")]) {
            BOOL currentState = [(UISwitch *)accessory isOn];
            [(UISwitch *)accessory setOn:(currentState ^ 1) animated:YES];
            [(UISwitch *)accessory sendActionsForControlEvents:UIControlEventValueChanged];
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
    NSInteger tag = [(UIView *)sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:section];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        BOOL isOn = [(UISwitch *)sender isOn];
        NSString *key = [item objectForKey:@"key"];
        [defaults setBool:isOn forKey:key];
    }
}

- (void)setSegment:(id)sender {
    NSInteger tag = [(UIView *)sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:section];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSInteger selectedIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
        NSString *key = [item objectForKey:@"key"];
        [defaults setInteger:selectedIndex forKey:key];
    }
}

@end
