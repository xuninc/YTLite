#import "NavbarVC.h"
#import "YTLTableViewCell.h"
#import "YTLUserDefaults.h"

@implementation NavbarVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.main = @[];

        self.sections = [NSArray arrayWithObjects:
                         self.main,
                         nil];
    }
    return self;
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

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *item = [sectionArray objectAtIndex:[indexPath row]];

    NSString *type = [item objectForKey:@"type"];
    BOOL isBool = [type isEqualToString:@"bool"];
    if (isBool) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        id toggle = [cell accessoryView];
        [toggle setOn:![toggle isOn] animated:YES];
        [self toggleSwitch:toggle];
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

@end
