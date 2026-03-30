#import "PrefsVC.h"

@implementation PrefsVC

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.prefs = @[];
        self.cache = @[];
        self.other = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.prefs,
                         self.cache,
                         self.other,
                         nil];
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSUInteger prefsIndex = [self.sections indexOfObject:self.prefs];
    if ((NSInteger)prefsIndex == section) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localized = [bundle localizedStringForKey:@"ManagePreferences" value:nil table:nil];
        return localized;
    }

    NSUInteger cacheIndex = [self.sections indexOfObject:self.cache];
    if ((NSInteger)cacheIndex != section) {
        return nil;
    }

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *localized = [bundle localizedStringForKey:@"ManageCache" value:nil table:nil];
    return localized;
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
    YTLTableViewCell *cell = [[NSClassFromString(@"YTLTableViewCell") alloc] initWithStyle:style reuseIdentifier:reuseId];

    NSString *titleKey = [item objectForKey:@"title"];
    NSString *descKey = [NSString stringWithFormat:@"%@_Desc", titleKey];

    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"bool"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localizedTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        [[cell detailTextLabel] setText:localizedDesc];

        ABCSwitch *toggle = [[NSClassFromString(@"ABCSwitch") alloc] init];

        UIColor *tintColor = self.navigationController.navigationBar.tintColor;
        [toggle setOnTintColor:tintColor];

        UIColor *whiteColor = [UIColor whiteColor];
        UIColor *thumbColor = [whiteColor colorWithAlphaComponent:0.5];
        [toggle setThumbTintColor:thumbColor];

        [toggle addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];

        NSInteger section = [indexPath section];
        NSInteger row = [indexPath row];
        [toggle setTag:(row & 0xFFFF) | (section << 16)];

        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        NSString *key = [item objectForKey:@"key"];
        BOOL isOn = [[defaults objectForKey:key] boolValue];
        [toggle setOn:isOn animated:NO];

        [cell setAccessoryView:toggle];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

    if ([type isEqualToString:@"action"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *localizedTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
        [[cell textLabel] setText:localizedTitle];

        NSString *localizedDesc = [bundle localizedStringForKey:descKey value:nil table:nil];
        [[cell detailTextLabel] setText:localizedDesc];

        NSString *actionKey = [item objectForKey:@"key"];
        if ([actionKey isEqualToString:@"clearCache"]) {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            [spinner startAnimating];
            [cell setAccessoryView:spinner];

            [self getCacheSizeWithCompletion:^(NSString *sizeString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILabel *sizeLabel = [[UILabel alloc] init];
                    [sizeLabel setText:sizeString];
                    [sizeLabel sizeToFit];
                    [cell setAccessoryView:sizeLabel];
                });
            }];
        }

        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];

    if ([type isEqualToString:@"bool"]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ABCSwitch *toggle = (ABCSwitch *)[cell accessoryView];
        [toggle setOn:![toggle isOn] animated:YES];
        [self toggleSwitch:toggle];
        return;
    }

    if ([type isEqualToString:@"action"]) {
        NSString *actionKey = [item objectForKey:@"key"];

        if ([actionKey isEqualToString:@"clearCache"]) {
            [self clearCache:indexPath];
        } else if ([actionKey isEqualToString:@"exportPrefs"]) {
            [self exportPrefs:indexPath];
        } else if ([actionKey isEqualToString:@"importPrefs"]) {
            [self importPrefs];
        } else if ([actionKey isEqualToString:@"resetSettings"]) {
            [self resetSettings];
        }
    }
}

- (void)toggleSwitch:(id)sender {
    ABCSwitch *toggle = (ABCSwitch *)sender;
    NSInteger tag = [toggle tag];
    NSInteger section = (tag >> 16) & 0xFFFF;
    NSInteger row = tag & 0xFFFF;

    NSArray *sectionArray = [self.sections objectAtIndex:section];
    NSDictionary *item = [sectionArray objectAtIndex:row];
    NSString *key = [item objectForKey:@"key"];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    [defaults setObject:@([toggle isOn]) forKey:key];
}

- (void)importPrefs {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *title = [bundle localizedStringForKey:@"Warning" value:nil table:nil];
    NSString *message = [bundle localizedStringForKey:@"PreImportMessage" value:nil table:nil];
    NSString *yesStr = [bundle localizedStringForKey:@"Yes" value:nil table:nil];
    NSString *noStr = [bundle localizedStringForKey:@"No" value:nil table:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesStr
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        [defaults importYtlSettings:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSBundle *bundle = [NSBundle mainBundle];
                    NSString *doneStr = [bundle localizedStringForKey:@"Done" value:nil table:nil];
                    [self.tableView reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"YTHCCVCRefresh" object:nil];
                } else {
                    NSBundle *bundle = [NSBundle mainBundle];
                    NSString *errorStr = [bundle localizedStringForKey:@"Error_FailedToImport" value:nil table:nil];
                }
            });
        }];
    }];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noStr
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];

    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exportPrefs:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
    [defaults exportYtlSettings:self];
}

- (void)resetSettings {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *title = [bundle localizedStringForKey:@"Warning" value:nil table:nil];
    NSString *message = [bundle localizedStringForKey:@"ResetMessage" value:nil table:nil];
    NSString *yesStr = [bundle localizedStringForKey:@"Yes" value:nil table:nil];
    NSString *noStr = [bundle localizedStringForKey:@"No" value:nil table:nil];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesStr
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        [defaults resetUserDefaults];
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YTHCCVCRefresh" object:nil];

        NSBundle *bundle = [NSBundle mainBundle];
        NSString *doneStr = [bundle localizedStringForKey:@"Done" value:nil table:nil];
    }];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noStr
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];

    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearCache:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [spinner startAnimating];
    [cell setAccessoryView:spinner];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        if (cachesPath != nil) {
            [fileManager removeItemAtPath:cachesPath error:nil];
        }

        NSString *tempPath = NSTemporaryDirectory();
        NSArray *tempContents = [fileManager contentsOfDirectoryAtPath:tempPath error:nil];
        for (NSString *file in tempContents) {
            NSString *filePath = [tempPath stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:filePath error:nil];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *doneStr = [bundle localizedStringForKey:@"Done" value:nil table:nil];
            [self.tableView reloadData];
        });
    });
}

- (void)getCacheSizeWithCompletion:(void (^)(NSString *sizeString))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        unsigned long long totalSize = 0;

        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        if (cachesPath != nil) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:cachesPath];
            NSString *file;
            while ((file = [enumerator nextObject]) != nil) {
                NSString *fullPath = [cachesPath stringByAppendingPathComponent:file];
                NSDictionary *attrs = [fileManager attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attrs fileSize];
            }
        }

        NSString *tempPath = NSTemporaryDirectory();
        if (tempPath != nil) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:tempPath];
            NSString *file;
            while ((file = [enumerator nextObject]) != nil) {
                NSString *fullPath = [tempPath stringByAppendingPathComponent:file];
                NSDictionary *attrs = [fileManager attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attrs fileSize];
            }
        }

        NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
        NSString *sizeString = [formatter stringFromByteCount:(long long)totalSize];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(sizeString);
            }
        });
    });
}

@end
