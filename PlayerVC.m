#import "PlayerVC.h"

@implementation PlayerVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.main = @[];
        self.audiotrack = @[];
        self.captions = @[];
        self.interface_ = @[];
        self.progressbar = @[];
        self.behavior = @[];
        self.gestures = @[];
        self.wideness = @[];
        self.speedGestures = @[];
        self.seekMethod = @[];
        self.seekSense = @[];
        self.gestureSwitches = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.main,
                         self.audiotrack,
                         self.captions,
                         self.interface_,
                         self.progressbar,
                         self.behavior,
                         self.gestures,
                         self.wideness,
                         self.speedGestures,
                         self.seekMethod,
                         self.seekSense,
                         self.gestureSwitches,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger mainIndex = [self.sections indexOfObject:self.main];
    if ((NSInteger)mainIndex == section) {
        return [bundle localizedStringForKey:@"Main" value:nil table:nil];
    }

    NSUInteger audiotrackIndex = [self.sections indexOfObject:self.audiotrack];
    if ((NSInteger)audiotrackIndex == section) {
        return [bundle localizedStringForKey:@"PreferredAudio" value:nil table:nil];
    }

    NSUInteger captionsIndex = [self.sections indexOfObject:self.captions];
    if ((NSInteger)captionsIndex == section) {
        return [bundle localizedStringForKey:@"PreferredCaptions" value:nil table:nil];
    }

    NSUInteger interfaceIndex = [self.sections indexOfObject:self.interface_];
    if ((NSInteger)interfaceIndex == section) {
        return [bundle localizedStringForKey:@"Player_Interface" value:nil table:nil];
    }

    NSUInteger progressbarIndex = [self.sections indexOfObject:self.progressbar];
    if ((NSInteger)progressbarIndex == section) {
        return [bundle localizedStringForKey:@"ProgressBarStyle" value:nil table:nil];
    }

    NSUInteger behaviorIndex = [self.sections indexOfObject:self.behavior];
    if ((NSInteger)behaviorIndex == section) {
        return [bundle localizedStringForKey:@"Player_Actions" value:nil table:nil];
    }

    NSUInteger gesturesIndex = [self.sections indexOfObject:self.gestures];
    if ((NSInteger)gesturesIndex == section) {
        return [bundle localizedStringForKey:@"Player_Gestures" value:nil table:nil];
    }

    NSUInteger widenessIndex = [self.sections indexOfObject:self.wideness];
    if ((NSInteger)widenessIndex == section) {
        return [bundle localizedStringForKey:@"ActivationAreaWidth" value:nil table:nil];
    }

    NSUInteger seekMethodIndex = [self.sections indexOfObject:self.seekMethod];
    if ((NSInteger)seekMethodIndex == section) {
        return [bundle localizedStringForKey:@"SeekMethod" value:nil table:nil];
    }

    NSUInteger seekSenseIndex = [self.sections indexOfObject:self.seekSense];
    if ((NSInteger)seekSenseIndex == section) {
        return [bundle localizedStringForKey:@"SeekSensitivity" value:nil table:nil];
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger widenessIndex = [self.sections indexOfObject:self.wideness];
    if ((NSInteger)widenessIndex == section) {
        return [bundle localizedStringForKey:@"ActivationAreaWidth_Desc" value:nil table:nil];
    }

    NSUInteger seekMethodIndex = [self.sections indexOfObject:self.seekMethod];
    if ((NSInteger)seekMethodIndex == section) {
        return [bundle localizedStringForKey:@"SeekMethod_Desc" value:nil table:nil];
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

    NSNumber *styleValue = [item objectForKey:@"style"];
    NSInteger style = UITableViewCellStyleSubtitle;
    if (styleValue != nil) {
        style = [styleValue integerValue];
    }

    NSString *reuseId = [item objectForKey:@"id"];

    cell = [[YTLTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseId];

    NSString *titleKey = [item objectForKey:@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localizedTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
    [[cell textLabel] setText:localizedTitle];

    NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
    [[cell detailTextLabel] setText:localizedDesc];

    NSString *type = [item objectForKey:@"type"];
    BOOL isBool = [type isEqualToString:@"bool"];
    if (isBool) {
        ABCSwitch *toggle = [[NSClassFromString(@"ABCSwitch") alloc] init];

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

        if ([key isEqualToString:@"adjustByFinger"]) {
            NSInteger speedIndex = [defaults integerForKey:@"speedIndex"];
            if (speedIndex == 0) {
                [toggle setEnabled:NO];
                [cell setUserInteractionEnabled:NO];
                [[cell textLabel] setAlpha:0.5];
                [[cell detailTextLabel] setAlpha:0.5];
            }
        }

        [cell setAccessoryView:toggle];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    BOOL isInt = [type isEqualToString:@"int"];
    if (isInt) {
        NSArray *items = [item objectForKey:@"items"];
        UISegmentedControl *segment = [self segmentForItems:items];

        [segment addTarget:self action:@selector(setSegment:) forControlEvents:UIControlEventValueChanged];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [segment setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        NSInteger selectedIndex = [defaults integerForKey:key];
        [segment setSelectedSegmentIndex:selectedIndex];

        [cell setAccessoryView:segment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    BOOL isSlider = [type isEqualToString:@"slider"];
    if (isSlider) {
        NSString *key = [item objectForKey:@"key"];
        float minVal = [[item objectForKey:@"min"] floatValue];
        float maxVal = [[item objectForKey:@"max"] floatValue];

        UISlider *slider = [self sliderWithKey:key min:minVal max:maxVal];

        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [slider setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        [cell setAccessoryView:slider];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    BOOL isMenu = [type isEqualToString:@"menu"];
    if (isMenu) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    BOOL isColor = [type isEqualToString:@"color"];
    if (isColor) {
        NSString *key = [item objectForKey:@"key"];
        id colorWell = [self colorWellForKey:key title:localizedTitle];
        [cell setAccessoryView:colorWell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return cell;
}

- (UISegmentedControl *)segmentForItems:(NSArray *)items {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];
    return segment;
}

- (UISlider *)sliderWithKey:(NSString *)key min:(float)min max:(float)max {
    UISlider *slider = [[UISlider alloc] init];
    [slider setMinimumValue:min];
    [slider setMaximumValue:max];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    float value = [defaults floatForKey:key];
    [slider setValue:value];

    return slider;
}

- (id)colorWellForKey:(NSString *)key title:(NSString *)title {
    UIColorWell *colorWell = [[UIColorWell alloc] init];
    [colorWell setTitle:title];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    id storedColor = [defaults objectForKey:key];
    if (storedColor != nil) {
        [colorWell setSelectedColor:storedColor];
    }

    [colorWell addTarget:self action:@selector(colorWellTap:) forControlEvents:UIControlEventValueChanged];

    return colorWell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];
    BOOL isBool = [type isEqualToString:@"bool"];
    if (isBool) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ABCSwitch *toggle = (ABCSwitch *)[cell accessoryView];
        [toggle setOn:![toggle isOn] animated:YES];
        [self toggleSwitch:toggle];
    }

    BOOL isMenu = [type isEqualToString:@"menu"];
    if (isMenu) {
        NSString *titleKey = [item objectForKey:@"title"];
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *title = [bundle localizedStringForKey:titleKey value:nil table:nil];
        NSArray *actions = [item objectForKey:@"actions"];
        NSString *key = [item objectForKey:@"key"];
        [self showSheet:indexPath title:title actions:actions key:key];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toggleSwitch:(id)sender {
    UISwitch *toggle = (UISwitch *)sender;

    NSInteger tag = [toggle tag];
    NSInteger sectionIdx = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:sectionIdx];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        BOOL isOn = [toggle isOn];
        [defaults setBool:isOn forKey:key];
    }
}

- (void)setSegment:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;

    NSInteger tag = [segment tag];
    NSInteger sectionIdx = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:sectionIdx];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        NSInteger selectedIndex = [segment selectedSegmentIndex];
        [defaults setInteger:selectedIndex forKey:key];
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;

    NSInteger tag = [slider tag];
    NSInteger sectionIdx = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:sectionIdx];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        float value = [slider value];
        [defaults setFloat:value forKey:key];
    }
}

- (void)colorWellTap:(id)sender {
    UIColorWell *colorWell = (UIColorWell *)sender;
    UIColor *selectedColor = [colorWell selectedColor];

    NSInteger tag = [colorWell tag];
    NSInteger sectionIdx = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:sectionIdx];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        [defaults setObject:selectedColor forKey:key];
    }
}

- (void)showSheet:(NSIndexPath *)indexPath title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key {
    id sheetController = [NSClassFromString(@"YTDefaultSheetController") alloc];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localizedTitle = [bundle localizedStringForKey:title value:nil table:nil];
    sheetController = [sheetController initWithTitle:localizedTitle message:nil presenter:self];

    for (NSDictionary *actionDict in actions) {
        NSString *actionTitle = [actionDict objectForKey:@"title"];
        NSString *localizedActionTitle = [bundle localizedStringForKey:actionTitle value:nil table:nil];

        id action = [NSClassFromString(@"YTActionSheetAction") alloc];
        action = [action initWithTitle:localizedActionTitle iconImage:nil style:0 handler:^(id a) {
            YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
            NSInteger actionIndex = [actions indexOfObject:actionDict];
            [defaults setInteger:actionIndex forKey:key];
            [self.tableView reloadData];
        }];

        [sheetController addAction:action];
    }

    [sheetController presentFromViewController:self animated:YES completion:nil];
}

@end
