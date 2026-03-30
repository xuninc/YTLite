#import "SettingsViewController.h"

@implementation SettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle mainBundle];

        NSString *downloadingTitle = [bundle localizedStringForKey:@"Downloading" value:nil table:nil];
        NSString *navbarTitle = [bundle localizedStringForKey:@"Navbar" value:nil table:nil];
        NSString *feedTitle = [bundle localizedStringForKey:@"Feed" value:nil table:nil];
        NSString *playerTitle = [bundle localizedStringForKey:@"Player" value:nil table:nil];
        NSString *shortsTitle = [bundle localizedStringForKey:@"Shorts" value:nil table:nil];
        NSString *tabbarTitle = [bundle localizedStringForKey:@"Tabbar" value:nil table:nil];
        NSString *interfaceTitle = [bundle localizedStringForKey:@"Interface" value:nil table:nil];

        self.main = @[
            @{@"title": downloadingTitle, @"type": @"section", @"key": @"DownloadingVC"},
            @{@"title": navbarTitle, @"type": @"section", @"key": @"NavbarVC"},
            @{@"title": feedTitle, @"type": @"section", @"key": @"FeedVC"},
            @{@"title": playerTitle, @"type": @"section", @"key": @"PlayerVC"},
            @{@"title": shortsTitle, @"type": @"section", @"key": @"ShortsVC"},
            @{@"title": tabbarTitle, @"type": @"section", @"key": @"TabbarVC"},
            @{@"title": interfaceTitle, @"type": @"section", @"key": @"InterfaceVC"}
        ];

        NSString *sponsorBlockTitle = [bundle localizedStringForKey:@"SponsorBlock" value:nil table:nil];
        self.additional = @[
            @{@"title": sponsorBlockTitle, @"type": @"section", @"key": @"SponsorBlockVC"}
        ];

        self.developer = @[
            @{@"title": @"Dayanch96", @"type": @"link", @"key": @"https://github.com/dayanch96"},
            @{@"title": @"SupportDevelopment", @"type": @"action"},
            @{@"title": @"VisitGithub", @"type": @"link", @"key": @"https://github.com/dayanch96/YTLite"},
            @{@"title": @"VisitTelegram", @"type": @"link", @"key": @"https://t.me/nicegram"}
        ];

        self.credits = @[
            @{@"title": @"Contributors", @"type": @"link", @"key": @"contributors"},
            @{@"title": @"OpenSourceLibs", @"type": @"link", @"key": @"opensource"},
            @{@"title": @"SpecialThanks", @"type": @"link", @"key": @"specialthanks"},
            @{@"title": @"Preferences", @"type": @"link", @"key": @"preferences"}
        ];

        self.sections = [NSArray arrayWithObjects:
                         self.main,
                         self.additional,
                         self.developer,
                         self.credits,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSBundle *bundle = [NSBundle mainBundle];

    NSUInteger mainIndex = [self.sections indexOfObject:self.main];
    if ((NSInteger)mainIndex == section) {
        NSString *localized = [bundle localizedStringForKey:@"Main" value:nil table:nil];
        return localized;
    }

    NSUInteger developerIndex = [self.sections indexOfObject:self.developer];
    if ((NSInteger)developerIndex == section) {
        NSString *localized = [bundle localizedStringForKey:@"Developer" value:nil table:nil];
        return localized;
    }

    NSUInteger creditsIndex = [self.sections indexOfObject:self.credits];
    if ((NSInteger)creditsIndex == section) {
        NSString *localized = [bundle localizedStringForKey:@"Credits" value:nil table:nil];
        return localized;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSUInteger creditsIndex = [self.sections indexOfObject:self.credits];
    if ((NSInteger)creditsIndex == section) {
        NSBundle *appBundle = [NSBundle mainBundle];
        NSDictionary *infoDictionary = [appBundle infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *footerText = [NSString stringWithFormat:@"YTLite v%@", version];
        return footerText;
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
    NSIndexPath *ip = indexPath;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[YTLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    NSArray *sectionArray = [self.sections objectAtIndex:[ip section]];
    NSDictionary *item = [sectionArray objectAtIndex:[ip section]];

    if (item == nil) {
        return cell;
    }

    sectionArray = [self.sections objectAtIndex:[ip section]];
    item = [sectionArray objectAtIndex:[ip row]];

    NSNumber *styleValue = [item objectForKey:@"style"];
    NSInteger style = UITableViewCellStyleSubtitle;
    if (styleValue != nil) {
        style = [styleValue integerValue];
    }

    NSString *reuseId = [item objectForKey:@"id"];

    cell = [[YTLTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseId];

    NSString *titleKey = [item objectForKey:@"title"];
    [[cell textLabel] setText:titleKey];

    NSString *type = [item objectForKey:@"type"];

    BOOL isSection = [type isEqualToString:@"section"];
    if (isSection) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        NSString *key = [item objectForKey:@"key"];
        UIImage *iconImage = [self iconImageNamed:key];
        [[cell imageView] setImage:iconImage];

        UIColor *tintColor = [UIColor systemBlueColor];
        [[cell imageView] setTintColor:tintColor];
    }

    BOOL isLink = [type isEqualToString:@"link"];
    if (isLink) {
        NSString *desc = [item objectForKey:@"description"];
        if (desc != nil) {
            [[cell detailTextLabel] setText:desc];
        }

        NSString *iconName = [item objectForKey:@"icon"];
        if (iconName != nil) {
            UIImage *accessory = [self accessoryImage:iconName];
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:accessory];
            [cell setAccessoryView:accessoryView];
        }

        NSString *imageName = [item objectForKey:@"image"];
        if (imageName != nil) {
            UIImage *devImage = [self devCellImage:imageName];
            [[cell imageView] setImage:devImage];
        }
    }

    BOOL isAction = [type isEqualToString:@"action"];
    if (isAction) {
        NSString *desc = [item objectForKey:@"description"];
        if (desc != nil) {
            [[cell detailTextLabel] setText:desc];
        }
    }

    return cell;
}

- (UIImage *)devCellImage:(id)image {
    CGSize size = CGSizeMake(32.0, 32.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];

    UIImage *result = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIImage *sourceImage = [self imageNamed:image];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 32.0, 32.0)];
        [path addClip];
        [sourceImage drawInRect:CGRectMake(0, 0, 32.0, 32.0)];
    }];

    return result;
}

- (UIImage *)iconImageNamed:(id)name {
    CGSize size = CGSizeMake(24.0, 24.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];

    UIImage *rendered = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIImage *sourceImage = [self imageNamed:name];
        [sourceImage drawInRect:CGRectMake(0, 0, 24.0, 24.0)];
    }];

    UIImage *result = [rendered imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return result;
}

- (UIImage *)accessoryImage:(id)name {
    CGSize size = CGSizeMake(20.0, 20.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];

    UIImage *rendered = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        UIImage *sourceImage = [self imageNamed:name];
        [sourceImage drawInRect:CGRectMake(0, 0, 20.0, 20.0)];
    }];

    UIImage *result = [rendered imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];

    BOOL isSection = [type isEqualToString:@"section"];
    if (isSection) {
        NSString *key = [item objectForKey:@"key"];
        Class vcClass = NSClassFromString(key);
        id viewController = [[vcClass alloc] init];

        id wrapper = [[NSClassFromString(@"YTWrapperSplitViewController") alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }

    BOOL isLink = [type isEqualToString:@"link"];
    if (isLink) {
        NSString *key = [item objectForKey:@"key"];
        NSURL *url = [NSURL URLWithString:key];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }

    BOOL isAction = [type isEqualToString:@"action"];
    if (isAction) {
        [self showDonationSheet:indexPath];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showDonationSheet:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];

    NSString *sheetTitle = [bundle localizedStringForKey:@"SupportDevelopment" value:nil table:nil];
    NSString *sheetDesc = [bundle localizedStringForKey:@"DonateDesc" value:nil table:nil];
    id sheetController = [NSClassFromString(@"YTDefaultSheetController") alloc];
    sheetController = [sheetController initWithTitle:sheetTitle message:sheetDesc presenter:self];

    // Patreon
    id patreonAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *patreonTitle = [bundle localizedStringForKey:@"Patreon" value:nil table:nil];
    patreonAction = [patreonAction initWithTitle:patreonTitle iconImage:nil style:0 handler:^(id action) {
        NSURL *url = [NSURL URLWithString:@"https://www.patreon.com/dayanch96"];
        [NSClassFromString(@"YTUIUtils") openURL:url];
    }];
    [sheetController addAction:patreonAction];

    // Github Sponsors
    id githubAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *githubTitle = [bundle localizedStringForKey:@"GithubSponsors" value:nil table:nil];
    githubAction = [githubAction initWithTitle:githubTitle iconImage:nil style:0 handler:^(id action) {
        NSURL *url = [NSURL URLWithString:@"https://github.com/sponsors/dayanch96"];
        [NSClassFromString(@"YTUIUtils") openURL:url];
    }];
    [sheetController addAction:githubAction];

    // Buy Me a Coffee
    id coffeeAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *coffeeTitle = [bundle localizedStringForKey:@"BuyMeaCoffee" value:nil table:nil];
    coffeeAction = [coffeeAction initWithTitle:coffeeTitle iconImage:nil style:0 handler:^(id action) {
        NSURL *url = [NSURL URLWithString:@"https://www.buymeacoffee.com/dayanch96"];
        [NSClassFromString(@"YTUIUtils") openURL:url];
    }];
    [sheetController addAction:coffeeAction];

    // USDT (TRC20)
    id usdtAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *usdtTitle = [bundle localizedStringForKey:@"USDT (TRC20)" value:nil table:nil];
    usdtAction = [usdtAction initWithTitle:usdtTitle iconImage:nil style:0 handler:^(id action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:@"TEdKJdKwc1Bbu8Py4um8qPQ6MbproEqNJw"];
        [NSClassFromString(@"YTToastController") showToast:@"Copied"];
    }];
    [sheetController addAction:usdtAction];

    // BNB Smart Chain (BEP20)
    id bnbAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *bnbTitle = [bundle localizedStringForKey:@"BNB Smart Chain (BEP20)" value:nil table:nil];
    bnbAction = [bnbAction initWithTitle:bnbTitle iconImage:nil style:0 handler:^(id action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:@"0xc6f9fddb30ce10d70e6497950f44c8e10b72bcd6"];
        [NSClassFromString(@"YTToastController") showToast:@"Copied"];
    }];
    [sheetController addAction:bnbAction];

    // Boosty
    id boostyAction = [NSClassFromString(@"YTActionSheetAction") alloc];
    NSString *boostyTitle = [bundle localizedStringForKey:@"Boosty" value:nil table:nil];
    boostyAction = [boostyAction initWithTitle:boostyTitle iconImage:nil style:0 handler:^(id action) {
        NSURL *url = [NSURL URLWithString:@"https://boosty.to/dayanch96"];
        [NSClassFromString(@"YTUIUtils") openURL:url];
    }];
    [sheetController addAction:boostyAction];

    [sheetController presentFromViewController:self animated:YES completion:nil];
}

- (UIImage *)imageNamed:(id)name {
    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
