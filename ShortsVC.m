#import "ShortsVC.h"
#import "YTLTableViewCell.h"
#import "Utils/YTLUserDefaults.h"

@implementation ShortsVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.main = @[];
        self.playback = @[];
        self.shorts = @[];
        self.interface_ = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.main,
                         self.playback,
                         self.shorts,
                         self.interface_,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger playbackIndex = [self.sections indexOfObject:self.playback];
    if ((NSInteger)playbackIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"PlaybackMode" value:nil table:nil];
        return localized;
    }

    NSUInteger interfaceIndex = [self.sections indexOfObject:self.interface_];
    if ((NSInteger)interfaceIndex != section) {
        return nil;
    }

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localized = [bundle localizedStringForKey:@"ShortsInterface" value:nil table:nil];
    return localized;
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

    NSString *type = [item objectForKey:@"type"];
    BOOL isBool = [type isEqualToString:@"bool"];
    if (isBool) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = [item objectForKey:@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        bundle = [NSBundle mainBundle];
        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        UILabel *detailLabel = [cell detailTextLabel];
        [detailLabel setText:localizedDesc];

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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"int"]) {
        NSArray *indexes = [item objectForKey:@"indexes"];
        UISegmentedControl *segment = [self segmentForItems:indexes];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        NSInteger selectedIndex = [defaults integerForKey:key];
        [segment setSelectedSegmentIndex:selectedIndex];

        NSInteger sectionIdx = [indexPath section];
        NSInteger row = [indexPath row];
        [segment setTag:(row & 0xFFFF) | (sectionIdx << 16)];

        [segment addTarget:self action:@selector(setSegment:) forControlEvents:UIControlEventValueChanged];

        [cell setAccessoryView:segment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"menu"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = [item objectForKey:@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        UILabel *textLabel2 = [cell textLabel];
        [textLabel2 setUserInteractionEnabled:NO];

        NSArray *indexes = [item objectForKey:@"indexes"];
        NSString *menuKey = [item objectForKey:@"key"];
        id menuButton = [self menuButtonWithTitle:localizedTitle array:indexes key:menuKey];
        [cell setAccessoryView:menuButton];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *accessoryView = [cell accessoryView];
        if ([accessoryView isKindOfClass:NSClassFromString(@"ABCSwitch")]) {
            [accessoryView sendActionsForControlEvents:UIControlEventTouchUpInside];
            BOOL currentValue = [(id)accessoryView isOn];
            [(id)accessoryView setOn:(currentValue ^ 1) animated:YES];
            [accessoryView sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }

    type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"menu"]) {
        NSString *rawTitle = [item objectForKey:@"title"];
        NSString *descTitle = [NSString stringWithFormat:@"%@_Desc", rawTitle];

        id alertView = [NSClassFromString(@"YTAlertView") new];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle2 = [item objectForKey:@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle2 value:nil table:nil];
        [alertView setTitle:localizedTitle];

        NSBundle *bundle2 = [NSBundle mainBundle];
        NSString *localizedDesc = [bundle2 localizedStringForKey:descTitle value:nil table:nil];
        [alertView setMessage:localizedDesc];

        [alertView show];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UISegmentedControl *)segmentForItems:(NSArray *)items {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];
    return segment;
}

- (void)toggleSwitch:(UIControl *)sender {
    NSInteger section = [sender tag] >> 16;
    NSInteger row = [sender tag] & 0xFFFF;

    NSDictionary *sectionArray = [self.sections objectAtIndex:section];
    NSDictionary *item = [sectionArray objectAtIndex:row];

    if (item == nil) return;

    NSString *key = [item objectForKey:@"key"];
    if ([key isEqualToString:@"shortsOnlyMode"]) {
        BOOL isOn = [(id)sender isOn];
        if (isOn == NO) {
            goto saveDirectly;
        }
        id alertView = [NSClassFromString(@"YTAlertView") new];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *warningTitle = [bundle localizedStringForKey:@"Warning" value:nil table:nil];
        [alertView setTitle:warningTitle];

        NSBundle *bundle2 = [NSBundle mainBundle];
        NSString *warningMessage = [bundle2 localizedStringForKey:@"ShortsOnlyWarning" value:nil table:nil];
        [alertView setMessage:warningMessage];

        [alertView show];
        return;
    }

saveDirectly:
    {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        BOOL isOn = [(id)sender isOn];
        NSString *itemKey = [item objectForKey:@"key"];
        [defaults setBool:isOn forKey:itemKey];
    }
}

- (void)setSegment:(UISegmentedControl *)sender {
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

- (void)showSheet:(NSIndexPath *)indexPath title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localizedTitle = [bundle localizedStringForKey:title value:nil table:nil];

    id sheet = [NSClassFromString(@"YTDefaultSheetController") performSelector:NSSelectorFromString(@"sheetWithTitle:subtitle:style:identifier:")
                                                                    withObject:localizedTitle
                                                                    withObject:nil];

    id headerView = [sheet valueForKey:@"_headerView"];
    id subtitleLabel = [headerView valueForKey:@"_subtitleLabel"];
    [subtitleLabel setNumberOfLines:0];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    NSString *currentKey = [indexPath valueForKey:@"key"];
    NSInteger currentIndex = [defaults integerForKey:currentKey];

    for (NSUInteger i = 0; i < [actions count]; i++) {
        NSString *actionTitle = [actions objectAtIndex:i];

        NSBundle *actionBundle = [NSBundle mainBundle];
        NSString *localizedActionTitle = [actionBundle localizedStringForKey:actionTitle value:nil table:nil];

        UIImage *icon = [self segmentIcon:actionTitle];

        id action = [[NSClassFromString(@"YTActionSheetAction") alloc] performSelector:NSSelectorFromString(@"actionWithTitle:iconImage:style:accessibilityIdentifier:handler:")
                                                                            withObject:localizedActionTitle
                                                                            withObject:icon];

        [sheet performSelector:NSSelectorFromString(@"addAction:") withObject:action];
    }

    [sheet performSelector:NSSelectorFromString(@"presentInViewController:animated:completion:")
                withObject:self
                withObject:@YES];
}

- (UIImage *)segmentIcon:(NSString *)iconName {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(24.0, 24.0)];

    UIImage *renderedImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        NSBundle *bundle = [NSBundle mainBundle];
        UIImage *sourceImage = [UIImage imageNamed:iconName inBundle:bundle compatibleWithTraitCollection:nil];

        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24.0, 24.0)];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:sourceImage];

        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setClipsToBounds:YES];

        [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setFrame:CGRectMake(0, 0, 24.0, 24.0)];

        [containerView addSubview:imageView];

        CALayer *layer = [containerView layer];
        CGContextRef cgContext = [rendererContext CGContext];
        [layer renderInContext:cgContext];
    }];

    UIImage *templateImage = [renderedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    return templateImage;
}

@end
