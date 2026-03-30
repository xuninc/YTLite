#import "SponsorBlockVC.h"

@implementation SponsorBlockVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.main = @[];
        self.duration = @[];
        self.duration2 = @[];
        self.segments = @[];
        self.user = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.main,
                         self.duration,
                         self.duration2,
                         self.segments,
                         self.user,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger mainIndex = [self.sections indexOfObject:self.main];
    if ((NSInteger)mainIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"Main" value:nil table:nil];
        return localized;
    }

    NSUInteger durationIndex = [self.sections indexOfObject:self.duration];
    if ((NSInteger)durationIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"SkipAlertDuration" value:nil table:nil];
        return localized;
    }

    NSUInteger duration2Index = [self.sections indexOfObject:self.duration2];
    if ((NSInteger)duration2Index == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"UnskipAlertDuration" value:nil table:nil];
        return localized;
    }

    NSUInteger segmentsIndex = [self.sections indexOfObject:self.segments];
    if ((NSInteger)segmentsIndex != section) {
        return nil;
    }

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localized = [bundle localizedStringForKey:@"Segments" value:nil table:nil];
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

    NSNumber *styleValue = item[@"style"];
    NSInteger style = UITableViewCellStyleSubtitle;
    if (styleValue != nil) {
        style = [styleValue integerValue];
    }

    NSString *reuseId = item[@"id"];

    cell = [[YTLTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseId];

    NSString *titleKey = item[@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];

    NSString *type = item[@"type"];

    // ---- Handle bool type ----
    if ([type isEqualToString:@"bool"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = item[@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        UILabel *detailLabel = [cell detailTextLabel];
        [detailLabel setText:localizedDesc];

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

        NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = item[@"key"];
        BOOL isOn = [defaults boolForKey:key];
        [toggle setOn:isOn];

        [cell setAccessoryView:toggle];
    }

    // ---- Handle slider type ----
    type = item[@"type"];
    if ([type isEqualToString:@"slider"]) {
        NSString *key = item[@"key"];
        NSNumber *minValue = item[@"min"];
        float minFloat = [minValue floatValue];
        NSNumber *maxValue = item[@"max"];
        float maxFloat = [maxValue floatValue];

        UISlider *slider = [self sliderWithKey:key min:(double)minFloat max:(double)maxFloat];

        NSInteger tagSection = [indexPath section];
        NSInteger tagRow = [indexPath row];
        [slider setTag:(tagRow & 0xFFFF) | (tagSection << 16)];

        NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
        [formatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
        [formatter setAllowedUnits:NSCalendarUnitSecond];

        float sliderValue = [slider value];
        NSString *timeString = [formatter stringFromTimeInterval:(double)sliderValue];
        UILabel *detailLabel = [cell detailTextLabel];
        [detailLabel setText:timeString];

        UIView *contentView = [cell contentView];
        [contentView addSubview:slider];

        [slider setTranslatesAutoresizingMaskIntoConstraints:NO];

        // Leading constraint
        NSLayoutAnchor *sliderLeading = [slider leadingAnchor];
        UILayoutGuide *marginsGuide = [[cell contentView] layoutMarginsGuide];
        NSLayoutAnchor *marginLeading = [marginsGuide leadingAnchor];
        NSLayoutConstraint *leadingConstraint = [sliderLeading constraintEqualToAnchor:marginLeading constant:5.0];
        [leadingConstraint setActive:YES];

        // Trailing constraint
        NSLayoutAnchor *sliderTrailing = [slider trailingAnchor];
        UILayoutGuide *marginsGuide2 = [[cell contentView] layoutMarginsGuide];
        NSLayoutAnchor *marginTrailing = [marginsGuide2 trailingAnchor];
        NSLayoutConstraint *trailingConstraint = [sliderTrailing constraintEqualToAnchor:marginTrailing constant:-50.0];
        [trailingConstraint setActive:YES];

        // Center Y constraint
        NSLayoutAnchor *sliderCenterY = [slider centerYAnchor];
        UILayoutGuide *marginsGuide3 = [[cell contentView] layoutMarginsGuide];
        NSLayoutAnchor *marginCenterY = [marginsGuide3 centerYAnchor];
        NSLayoutConstraint *centerYConstraint = [sliderCenterY constraintEqualToAnchor:marginCenterY];
        [centerYConstraint setActive:YES];
    }

    // ---- Handle menu type ----
    type = item[@"type"];
    if ([type isEqualToString:@"menu"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = item[@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        UILabel *textLabel2 = [cell textLabel];
        [textLabel2 setNumberOfLines:0];

        NSString *rawTitle2 = item[@"title"];
        NSString *localizedTitle2 = [bundle localizedStringForKey:rawTitle2 value:nil table:nil];
        NSArray *indexes = item[@"indexes"];
        NSString *menuKey = item[@"key"];

        id menuButton = [self menuButtonWithTitle:localizedTitle2 array:indexes key:menuKey];
        [cell setAccessoryView:menuButton];
    }

    // ---- Handle text type ----
    type = item[@"type"];
    if ([type isEqualToString:@"text"]) {
        NSString *key = item[@"key"];
        BOOL isPrivateID = [key isEqualToString:@"sbPrivateUserID"];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = item[@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        UILabel *textLabel2 = [cell textLabel];
        [textLabel2 setNumberOfLines:1];
        UILabel *textLabel3 = [cell textLabel];
        [textLabel3 setLineBreakMode:NSLineBreakByTruncatingTail];

        if (isPrivateID == NO) {
            NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
            NSString *storedKey = item[@"key"];
            NSString *storedValue = [defaults valueForKey:storedKey];

            NSString *displayValue = storedValue;
            if ([storedValue length] > 15) {
                NSString *truncated = [storedValue substringToIndex:15];
                displayValue = [truncated stringByAppendingString:@"..."];
            }

            UILabel *detailLabel = [cell detailTextLabel];
            [detailLabel setText:displayValue];
        } else {
            NSBundle *bundle2 = [NSBundle mainBundle];
            NSString *tapToReveal = [bundle2 localizedStringForKey:@"TapToReveal" value:nil table:nil];
            UILabel *detailLabel = [cell detailTextLabel];
            [detailLabel setText:tapToReveal];
        }
    }

    // ---- Handle color type ----
    type = item[@"type"];
    if ([type isEqualToString:@"color"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *rawTitle = item[@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:localizedTitle];

        NSString *colorKey = item[@"key"];

        NSBundle *bundle2 = [NSBundle mainBundle];
        NSString *rawTitle2 = item[@"title"];
        NSString *localizedTitle2 = [bundle2 localizedStringForKey:rawTitle2 value:nil table:nil];

        UIColorWell *colorWell = [self colorWellForKey:colorKey title:localizedTitle2];

        NSInteger tagSection = [indexPath section];
        NSInteger tagRow = [indexPath row];
        [colorWell setTag:(tagRow & 0xFFFF) | (tagSection << 16)];

        [cell setAccessoryView:colorWell];
    }

    // ---- Handle space type ----
    type = item[@"type"];
    if ([type isEqualToString:@"space"]) {
        UILabel *textLabel = [cell textLabel];
        [textLabel setText:nil];
        [cell setUserInteractionEnabled:NO];
    }

    return cell;
}

- (void)editorForIndexPath:(NSIndexPath *)indexPath {
    id sectionArray = self.sections;
    NSInteger section = [indexPath section];
    id sectionData = [sectionArray objectAtIndex:section];

    NSInteger row = [indexPath row];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    UITextView *textView = [[UITextView alloc] init];

    UIColor *labelColor = [UIColor labelColor];
    UIColor *bgColor = [labelColor colorWithAlphaComponent:0.1];
    [textView setBackgroundColor:bgColor];

    CALayer *layer = [textView layer];
    [layer setCornerRadius:3.0];
    CALayer *layer2 = [textView layer];
    [layer2 setBorderWidth:1.0];

    UIColor *grayColor = [UIColor grayColor];
    UIColor *borderUIColor = [grayColor colorWithAlphaComponent:0.5];
    CGColorRef borderColor = [borderUIColor CGColor];
    CALayer *layer3 = [textView layer];
    [layer3 setBorderColor:borderColor];

    UIColor *textColor = [UIColor labelColor];
    [textView setTextColor:textColor];

    NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    NSString *key = rowInfo[@"key"];
    NSString *currentValue = [defaults valueForKey:key];
    [textView setText:currentValue];

    [textView setEditable:YES];
    [textView setScrollEnabled:YES];
    [textView setTextAlignment:NSTextAlignmentCenter];
    UIFont *font = [UIFont systemFontOfSize:14.0];
    [textView setFont:font];

    id alertView = [NSClassFromString(@"YTAlertView") dialog];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *rawTitle = rowInfo[@"title"];
    NSString *localizedTitle = [bundle localizedStringForKey:rawTitle value:nil table:nil];
    [alertView setTitle:localizedTitle];

    UIColor *alertLabelColor = [UIColor labelColor];
    UIColor *alertBgColor = [alertLabelColor colorWithAlphaComponent:0.1];
    [alertView setBackgroundColor:alertBgColor];

    // Add "Copy" button
    NSBundle *bundle2 = [NSBundle mainBundle];
    NSString *copyTitle = [bundle2 localizedStringForKey:@"Copy" value:nil table:nil];

    [alertView addTitle:copyTitle withAction:^{
        NSString *textContent = [textView text];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:textContent];

        NSBundle *toastBundle = [NSBundle mainBundle];
        NSString *copiedMessage = [toastBundle localizedStringForKey:@"Copied" value:nil table:nil];
        [ToastManager showMessageWithText:copiedMessage isSuccess:YES];
    }];

    // Add "Save" button
    NSBundle *bundle3 = [NSBundle mainBundle];
    NSString *saveTitle = [bundle3 localizedStringForKey:@"Save" value:nil table:nil];

    [alertView addTitle:saveTitle withAction:^{
        NSUserDefaults *saveDefaults = [YTLUserDefaults standardUserDefaults];

        NSString *saveKey = rowInfo[@"key"];
        BOOL isPublicUserID = [saveKey isEqualToString:@"sbPublicUserID"];

        NSString *textContent = [textView text];
        NSUInteger textLength = [textContent length];

        BOOL isValidLength = NO;
        if (isPublicUserID == NO) {
            if (textLength > 0x1f) {
                isValidLength = YES;
            }
        } else {
            if (textLength == 0x40) {
                isValidLength = YES;
            }
        }

        if (isValidLength) {
            NSString *valueToSave = [textView text];
            NSString *keyToSave = rowInfo[@"key"];
            [saveDefaults setObject:valueToSave forKey:keyToSave];
        } else {
            NSString *textContent2 = [textView text];
            NSInteger textLength2 = (NSInteger)[textContent2 length];

            if (textLength2 == 0) {
                NSString *privateID = [saveDefaults sbPrivateUserID];
                NSString *publicID = [saveDefaults sbPublicUserID];

                NSString *saveKeyAgain = rowInfo[@"key"];
                BOOL isPublicAgain = [saveKeyAgain isEqualToString:@"sbPublicUserID"];

                NSString *saveKeyFinal = rowInfo[@"key"];
                NSString *valueToStore = isPublicAgain ? publicID : privateID;
                [saveDefaults setObject:valueToStore forKey:saveKeyFinal];
            } else {
                NSBundle *errorBundle = [NSBundle mainBundle];
                NSString *errorKey;
                if ((isPublicUserID & 1) == 0) {
                    errorKey = @"Error_SbPrivateID";
                } else {
                    errorKey = @"Error_SbPublicID";
                }
                NSString *errorMessage = [errorBundle localizedStringForKey:errorKey value:nil table:nil];
                [ToastManager showMessageWithText:errorMessage isSuccess:NO];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [saveDefaults synchronize];
            UITableView *tv = [self tableView];
            [tv reloadData];
        });
    }];

    // Add "Cancel" button
    NSBundle *bundle4 = [NSBundle mainBundle];
    NSString *cancelTitle = [bundle4 localizedStringForKey:@"Cancel" value:nil table:nil];
    [alertView addTitle:cancelTitle withAction:nil];

    CGRect dialogFrame = [alertView frameForDialog];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dialogFrame.size.width - 50.0, 100.0)];
    [textView setFrame:[containerView frame]];
    [containerView addSubview:textView];
    [alertView setCustomContentView:containerView];

    [alertView show];
}

- (UISlider *)sliderWithKey:(NSString *)key min:(double)minVal max:(double)maxVal {
    UISlider *slider = [[UISlider alloc] init];

    UIColor *thumbColor = [UIColor colorWithRed:0.75 green:0.5 blue:0.85 alpha:1.0];
    [slider setThumbTintColor:thumbColor];

    [slider setMinimumValue:(float)minVal];
    [slider setMaximumValue:(float)maxVal];

    NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    float currentValue = [defaults floatForKey:key];
    [slider setValue:currentValue];

    [slider setContinuous:NO];

    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb" inBundle:bundle compatibleWithTraitCollection:nil];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];

    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    return slider;
}

- (UIView *)colorWellForKey:(NSString *)key title:(NSString *)title {
    NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    NSData *colorData = [defaults dataForKey:key];

    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                       fromData:colorData
                                                          error:nil];

    UIColorWell *colorWell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];

    [colorWell setTitle:title];
    [colorWell setSupportsAlpha:YES];
    [colorWell setSelectedColor:color];

    [colorWell addTarget:self action:@selector(colorWellTap:) forControlEvents:UIControlEventValueChanged];

    return colorWell;
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
            [(id)accessoryView sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }

    type = [rowInfo objectForKey:@"type"];
    if ([type isEqualToString:@"menu"]) {
        NSString *title = [rowInfo objectForKey:@"title"];
        NSString *descKey = [NSString stringWithFormat:@"%@Desc", title];

        id alertView = [NSClassFromString(@"YTAlertView") new];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *alertTitle = [rowInfo objectForKey:@"title"];
        NSString *localizedTitle = [bundle localizedStringForKey:alertTitle value:nil table:nil];
        [alertView setTitle:localizedTitle];

        NSBundle *bundle2 = [NSBundle mainBundle];
        NSString *localizedDesc = [bundle2 localizedStringForKey:descKey value:nil table:nil];
        [alertView setMessage:localizedDesc];

        [alertView show];
    }

    type = [rowInfo objectForKey:@"type"];
    if ([type isEqualToString:@"text"]) {
        [self editorForIndexPath:indexPath];
    }

    type = [rowInfo objectForKey:@"type"];
    if ([type isEqualToString:@"color"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *accessoryView = [cell accessoryView];

        if ([accessoryView respondsToSelector:@selector(styleRequestedColorPickerPresent)]) {
            [(id)accessoryView styleRequestedColorPickerPresent];
        } else {
            [accessoryView performSelector:@selector(invokeColorPicker:)];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toggleSwitch:(id)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        BOOL isOn = [sender isOn];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setBool:isOn forKey:key];
    }
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        float rawValue = [sender value];
        NSNumber *dividerNumber = [rowInfo objectForKey:@"divider"];
        float divider = [dividerNumber floatValue];
        NSNumber *dividerNumber2 = [rowInfo objectForKey:@"divider"];
        float divider2 = [dividerNumber2 floatValue];
        float snappedValue = (float)((int)(rawValue / divider)) * divider2;
        [sender setValue:snappedValue];

        NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        float valueToSave = [sender value];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setFloat:valueToSave forKey:key];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        UITableView *tableView = [self tableView];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
        [formatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
        [formatter setAllowedUnits:NSCalendarUnitMinute | NSCalendarUnitSecond];

        float currentValue = [sender value];
        NSString *formattedString = [formatter stringFromTimeInterval:(double)currentValue];
        UILabel *detailLabel = [cell detailTextLabel];
        [detailLabel setText:formattedString];
    }
}

- (void)colorWellTap:(UIColorWell *)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    NSDictionary *rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        UIColor *selectedColor = [sender selectedColor];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:selectedColor
                                                 requiringSecureCoding:NO
                                                                 error:nil];

        NSUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setObject:colorData forKey:key];
    }
}

@end
