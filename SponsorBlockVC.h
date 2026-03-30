#ifndef SponsorBlockVC_h
#define SponsorBlockVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class YTLTableViewCell;
@class YTLUserDefaults;
@class ABCSwitch;
@class ToastManager;

@interface SponsorBlockVC : UITableViewController

@property (nonatomic, strong) NSArray *main;
@property (nonatomic, strong) NSArray *duration;
@property (nonatomic, strong) NSArray *duration2;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic, strong) NSArray *user;
@property (nonatomic, strong) NSArray *sections;

- (instancetype)init;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)editorForIndexPath:(NSIndexPath *)indexPath;
- (UISlider *)sliderWithKey:(NSString *)key min:(double)min max:(double)max;
- (UIView *)colorWellForKey:(NSString *)key title:(NSString *)title;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)toggleSwitch:(id)sender;
- (void)sliderValueChanged:(UISlider *)sender;
- (void)colorWellTap:(UIColorWell *)sender;

@end

#endif /* SponsorBlockVC_h */
