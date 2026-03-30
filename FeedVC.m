#import "FeedVC.h"
#import "YTLTableViewCell.h"
#import "Utils/YTLUserDefaults.h"

@implementation FeedVC

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
    NSArray *sectionData = [self.sections objectAtIndex:[indexPath section]];
    NSDictionary *rowInfo = [sectionData objectAtIndex:[indexPath row]];

    id typeValue = [rowInfo objectForKey:@"type"];
    BOOL isBoolType = [typeValue isEqual:@"bool"];

    if (isBoolType) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *accessoryView = [cell accessoryView];

        Class ABCSwitchClass = NSClassFromString(@"ABCSwitch");
        if ([accessoryView isKindOfClass:ABCSwitchClass]) {
            [accessoryView sendActionsForControlEvents:UIControlEventTouchUpInside];
            BOOL currentValue = [(id)accessoryView isOn];
            [(id)accessoryView setOn:(currentValue ^ 1) animated:YES];
            [accessoryView sendActionsForControlEvents:UIControlEventValueChanged];
            [accessoryView sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toggleSwitch:(id)sender {
    NSInteger tag = [sender tag];
    NSInteger section = tag >> 16;
    NSInteger row = tag & 0xFFFF;

    id sectionData = [self.sections objectAtIndex:section];
    id rowInfo = [sectionData objectAtIndex:row];

    if (rowInfo != nil) {
        YTLUserDefaults *defaults = [YTLUserDefaults standardUserDefaults];
        BOOL isOn = [sender isOn];
        NSString *key = [rowInfo objectForKey:@"key"];
        [defaults setBool:isOn forKey:key];
    }
}

@end
