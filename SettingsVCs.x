// SettingsVCs.x - Settings view controllers and base table view controller
// Reconstructed from binary analysis of YTLite.dylib v5.2b4

#import "YTLiteHeaders.h"
#import <objc/runtime.h>

// MARK: - YTLTableViewController (Base)

@implementation YTLTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _contentsArray = @[];
        _orderedCategories = @[];
        _settingsData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UISwitch *)switchForKey:(NSString *)key {
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.on = [[YTLUserDefaults sharedInstance] boolForKey:key];
    toggle.accessibilityIdentifier = key;
    [toggle addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    return toggle;
}

- (UISlider *)sliderWithKey:(NSString *)key min:(float)min max:(float)max {
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = [[YTLUserDefaults sharedInstance] floatForKey:key];
    slider.accessibilityIdentifier = key;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    return slider;
}

- (UIMenu *)menuButtonWithTitle:(NSString *)title array:(NSArray *)array key:(NSString *)key {
    NSMutableArray *actions = [NSMutableArray array];
    NSInteger currentValue = [[YTLUserDefaults sharedInstance] integerForKey:key];

    for (NSInteger i = 0; i < array.count; i++) {
        NSString *itemTitle = array[i];
        BOOL isSelected = (i == currentValue);

        UIAction *action = [UIAction actionWithTitle:itemTitle image:isSelected ? [UIImage systemImageNamed:@"checkmark"] : nil identifier:nil handler:^(UIAction *a) {
            [[YTLUserDefaults sharedInstance] setInteger:i forKey:key];
            [self.tableView reloadData];
        }];
        [actions addObject:action];
    }

    return [UIMenu menuWithTitle:title ?: @"" children:actions];
}

- (void)showSheet:(id)controller title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSDictionary *actionInfo in actions) {
        NSString *actionTitle = actionInfo[@"title"];
        [sheet addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSInteger index = [actions indexOfObject:actionInfo];
            [[YTLUserDefaults sharedInstance] setInteger:index forKey:key];
            [self.tableView reloadData];
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil] style:UIAlertActionStyleCancel handler:nil]];

    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = self.view;
        sheet.popoverPresentationController.sourceRect = self.view.bounds;
    }

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)setSectionItems:(NSArray *)items forCategory:(NSString *)category title:(NSString *)title icon:(UIImage *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    NSMutableDictionary *section = [NSMutableDictionary dictionary];
    section[@"items"] = items ?: @[];
    section[@"title"] = title ?: @"";
    if (icon) section[@"icon"] = icon;
    if (titleDescription) section[@"description"] = titleDescription;
    section[@"headerHidden"] = @(headerHidden);

    self.settingsData[category] = section;
}

- (void)setSectionItems:(NSArray *)items forCategory:(NSString *)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    [self setSectionItems:items forCategory:category title:title icon:nil titleDescription:titleDescription headerHidden:headerHidden];
}

- (void)updateSectionForCategory:(NSString *)category withEntry:(id)entry {
    NSMutableDictionary *section = self.settingsData[category];
    if (section && entry) {
        NSMutableArray *items = [section[@"items"] mutableCopy];
        [items addObject:entry];
        section[@"items"] = items;
    }
}

- (void)toggleSwitch:(UISwitch *)sender {
    NSString *key = sender.accessibilityIdentifier;
    if (key) {
        [[YTLUserDefaults sharedInstance] setBool:sender.isOn forKey:key];
    }
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSString *key = sender.accessibilityIdentifier;
    if (key) {
        [[YTLUserDefaults sharedInstance] setFloat:sender.value forKey:key];
    }
}

- (UIImage *)devCellImage:(NSString *)name {
    return [YTLHelper originalImageWithName:name];
}

- (UIImage *)imgForVal:(id)val {
    if ([val boolValue]) {
        return [UIImage systemImageNamed:@"checkmark.circle.fill"];
    }
    return [UIImage systemImageNamed:@"circle"];
}

- (UILabel *)subLabelForVal:(id)val style:(NSInteger)style {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor secondaryLabelColor];
    label.text = [val description];
    return label;
}

- (void)exportPrefs:(id)sender {
    [self exportYtlSettings:sender];
}

- (void)exportYtlSettings:(id)sender {
    NSDictionary *prefs = [[YTLUserDefaults sharedInstance] dictionaryRepresentation];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:prefs format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];

    if (data) {
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"YTLitePreferences.plist"];
        [data writeToFile:tempPath atomically:YES];

        NSURL *fileURL = [NSURL fileURLWithPath:tempPath];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];

        if (activityVC.popoverPresentationController) {
            activityVC.popoverPresentationController.sourceView = self.view;
            activityVC.popoverPresentationController.sourceRect = self.view.bounds;
        }

        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)importYtlSettings:(id)sender {
    NSString *localizedMessage = [[NSBundle mainBundle] localizedStringForKey:@"PreImportMessage" value:@"This action will replace the current preferences with those from the selected file.\n\nAre you sure you want to continue?" table:nil];

    [self confirmationDialogWithAction:^{
        [YTLHelper presentDocumentPicker:self];
    } actionTitle:[[NSBundle mainBundle] localizedStringForKey:@"Continue" value:@"Continue" table:nil] cancelTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil]];
}

- (void)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle cancelAction:(void (^)(void))cancelAction cancelTitle:(NSString *)cancelTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Warning" value:@"Warning" table:nil] message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        if (action) action();
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
        if (cancelAction) cancelAction();
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle {
    [self confirmationDialogWithAction:action actionTitle:actionTitle cancelAction:nil cancelTitle:cancelTitle];
}

@end

// MARK: - SettingsViewController

@implementation SettingsViewController

- (void)initForSettings:(id)settings {
    // Initialize with YouTube's settings context
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YouTube Plus";
}

- (void)updateYTLiteSectionWithEntry:(id)entry {
    [self updateSectionForCategory:@"YTLite" withEntry:entry];
}

- (void)updatePremiumEarlyAccessSectionWithEntry:(id)entry {
    [self updateSectionForCategory:@"PremiumEarlyAccess" withEntry:entry];
}

- (void)resetSettings {
    NSString *localizedMessage = [[NSBundle mainBundle] localizedStringForKey:@"ResetMessage" value:@"This action will reset YTPlus settings to default and close YouTube.\n\nAre you sure you want to continue?" table:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Warning" value:@"Warning" table:nil] message:localizedMessage preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Yes" value:@"Yes" table:nil] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self resetUserDefaults];
        exit(0);
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil] style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetUserDefaults {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleId];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.dvntm.ytlite"];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) {
        NSLog(@"YTPlus --- No URL provided by document picker");
        return;
    }

    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return;

    NSError *error;
    NSDictionary *prefs = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
    if (error || !prefs) {
        NSLog(@"YTPlus --- Error parsing plist data: %@", error);
        NSString *localizedError = [[NSBundle mainBundle] localizedStringForKey:@"Error.FailedToImport" value:@"Failed to import preferences" table:nil];
        ToastView *toast = [[ToastView alloc] init];
        [toast showMessageWithText:localizedError isSuccess:NO];
        [[ToastManager sharedToast] showToast:toast];
        return;
    }

    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    for (NSString *key in prefs) {
        [defaults setObject:prefs[key] forKey:key];
    }

    [self.tableView reloadData];
}

@end

// MARK: - Sub-VCs (minimal implementations)

@implementation PrefsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"ManagePreferences" value:@"Preferences management" table:nil];
}
@end

@implementation PlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Player" value:@"Player" table:nil];
}
@end

@implementation FeedVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Feed" value:@"Feed" table:nil];
}
@end

@implementation ShortsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Shorts" value:@"Shorts" table:nil];
}
@end

@implementation InterfaceVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Interface" value:@"Interface" table:nil];
}
@end

@implementation NavbarVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Navbar" value:@"Navigation bar" table:nil];
}
@end

@implementation TabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Tabbar" value:@"Tab bar" table:nil];
    [self initTabs];
}

- (void)initTabs {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    NSArray *saved = [defaults objectForKey:@"ActiveTabs"];
    self.activeTabs = saved ?: @[@"FEwhat_to_watch", @"FEshorts", @"FEsubscriptions", @"FElibrary"];

    NSArray *savedInactive = [defaults objectForKey:@"InactiveTabs"];
    self.inactiveTabs = savedInactive ?: @[@"FEexplore", @"FEpost_home", @"FEuploads", @"FEhistory"];
}

- (void)saveTabsOrder {
    YTLUserDefaults *defaults = [YTLUserDefaults sharedInstance];
    [defaults setObject:self.activeTabs forKey:@"ActiveTabs"];
    [defaults setObject:self.inactiveTabs forKey:@"InactiveTabs"];
}

@end

@implementation ContributorsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"Contributors" value:@"Contributors" table:nil];
}
@end

@implementation ThanksVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"SupportDevelopment" value:@"Support development" table:nil];
}

- (void)thanksButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sponsors/dayanch96"] options:@{} completionHandler:nil];
}

- (void)contactsButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/dvntms"] options:@{} completionHandler:nil];
}

@end

@implementation LibsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[NSBundle mainBundle] localizedStringForKey:@"OpenSourceLibs" value:@"Open source libraries" table:nil];
}
@end
