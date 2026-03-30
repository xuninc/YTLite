#ifndef PlayerVC_h
#define PlayerVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;
@class ABCSwitch;
@class YTDefaultSheetController;
@class YTActionSheetAction;

@interface PlayerVC : UITableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *main;
@property (nonatomic, strong) NSArray *audiotrack;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) NSArray *interface_;
@property (nonatomic, strong) NSArray *progressbar;
@property (nonatomic, strong) NSArray *behavior;
@property (nonatomic, strong) NSArray *gestures;
@property (nonatomic, strong) NSArray *wideness;
@property (nonatomic, strong) NSArray *speedGestures;
@property (nonatomic, strong) NSArray *seekMethod;
@property (nonatomic, strong) NSArray *seekSense;
@property (nonatomic, strong) NSArray *gestureSwitches;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UISegmentedControl *)segmentForItems:(NSArray *)items;
- (UISlider *)sliderWithKey:(NSString *)key min:(float)min max:(float)max;
- (id)colorWellForKey:(NSString *)key title:(NSString *)title;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleSwitch:(id)sender;
- (void)setSegment:(id)sender;
- (void)sliderValueChanged:(id)sender;
- (void)colorWellTap:(id)sender;
- (void)showSheet:(NSIndexPath *)indexPath title:(NSString *)title actions:(NSArray *)actions key:(NSString *)key;

@end

#endif /* PlayerVC_h */
