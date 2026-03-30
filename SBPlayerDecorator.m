#import "SBPlayerDecorator.h"
#import <objc/runtime.h>

@implementation SBPlayerDecorator

- (void)addDurationWithoutSegments:(id)overlay videoController:(id)videoController {
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (![topVC isKindOfClass:NSClassFromString(@"YTWatchViewController")]) {
        return;
    }

    double totalDuration = [[videoController valueForKey:@"totalMediaTime"] doubleValue];
    if (totalDuration <= 0) {
        return;
    }

    NSString *videoID = [videoController valueForKey:@"videoID"];
    SBManager *manager = [SBManager sharedManager];
    NSArray *segments = [[manager segments] objectForKey:videoID];
    if (segments == nil || [segments count] == 0) {
        return;
    }

    double segmentsDuration = 0.0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (SBSegment *segment in segments) {
        NSString *category = [segment category];
        NSString *key = [NSString stringWithFormat:@"sb_%@", category];
        if ([defaults boolForKey:key]) {
            double start = [segment start];
            double end = [segment end];
            segmentsDuration += (end - start);
        }
    }

    double durationWithoutSegments = totalDuration - segmentsDuration;

    if (durationWithoutSegments != totalDuration) {
        NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
        [formatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
        [formatter setZeroFormattingBehavior:NSDateComponentsFormatterZeroFormattingBehaviorPad];
        if (durationWithoutSegments >= 3600) {
            [formatter setAllowedUnits:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)];
        } else {
            [formatter setAllowedUnits:(NSCalendarUnitMinute | NSCalendarUnitSecond)];
        }
        NSString *formattedDuration = [formatter stringFromTimeInterval:durationWithoutSegments];
        NSString *existingText = [overlay valueForKey:@"durationText"];
        NSString *sbDuration = [NSString stringWithFormat:@"%@ (%@)", existingText, formattedDuration];
        [overlay setValue:sbDuration forKey:@"durationText"];
    }

    return;
}

- (void)drawSegmentsDecorationView:(UIView *)decorationView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"sponsorBlock_enabled"]) {
        return;
    }

    UIViewController *playerVC = [decorationView valueForKey:@"delegate"];
    if (![playerVC isKindOfClass:NSClassFromString(@"YTMainAppVideoPlayerOverlayViewController")]) {
        return;
    }

    NSString *videoID = [playerVC valueForKey:@"videoID"];
    SBManager *manager = [SBManager sharedManager];
    NSArray *segments = [[manager segments] objectForKey:videoID];
    if (segments == nil || [segments count] == 0) {
        return;
    }

    NSArray *existingSublayers = [decorationView.layer.sublayers copy];
    for (CALayer *sublayer in existingSublayers) {
        if ([[sublayer name] isEqualToString:@"SBSegmentLayer"]) {
            [sublayer removeFromSuperlayer];
        }
    }

    CGFloat width = CGRectGetWidth(decorationView.bounds);
    CGFloat height = CGRectGetHeight(decorationView.bounds);

    double totalDuration = [[playerVC valueForKey:@"totalMediaTime"] doubleValue];
    if (totalDuration <= 0) {
        return;
    }

    for (SBSegment *segment in segments) {
        NSString *category = [segment category];

        NSString *enabledKey = [NSString stringWithFormat:@"sb_%@", category];
        if (![defaults boolForKey:enabledKey]) {
            continue;
        }

        NSString *colorKey = [NSString stringWithFormat:@"sb_%@_color", category];
        NSData *colorData = [defaults objectForKey:colorKey];
        UIColor *segmentColor = nil;
        if (colorData != nil) {
            segmentColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                             fromData:colorData
                                                                error:nil];
        }
        if (segmentColor == nil) {
            segmentColor = [UIColor greenColor];
        }

        double start = [segment start];
        double end = [segment end];
        CGFloat x = width * (start / totalDuration);
        CGFloat segmentWidth;

        if ([category isEqualToString:@"poi_highlight"]) {
            segmentWidth = 10.0;
        } else {
            segmentWidth = width * ((end - start) / totalDuration);
        }

        CALayer *segmentLayer = [CALayer layer];
        segmentLayer.name = @"SBSegmentLayer";
        segmentLayer.frame = CGRectMake(x, 0, segmentWidth, height);
        segmentLayer.backgroundColor = segmentColor.CGColor;

        [decorationView.layer addSublayer:segmentLayer];
    }
}

- (void)drawSegments:(NSArray *)segments layer:(CALayer *)layer playerVC:(id)playerVC {
    static dispatch_once_t onceToken;
    static NSMutableSet *cachedLayerSet = nil;
    dispatch_once(&onceToken, ^{
        cachedLayerSet = [NSMutableSet set];
    });

    if (layer == nil) {
        return;
    }
    CGRect bounds = layer.bounds;
    if (CGRectIsEmpty(bounds)) {
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"sponsorBlock_enabled"]) {
        return;
    }

    NSString *videoID = [playerVC valueForKey:@"videoID"];
    SBManager *manager = [SBManager sharedManager];
    NSArray *videoSegments = [[manager segments] objectForKey:videoID];
    if (videoSegments == nil || [videoSegments count] == 0) {
        return;
    }

    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);

    double totalDuration = [[playerVC valueForKey:@"totalMediaTime"] doubleValue];
    if (totalDuration <= 0) {
        return;
    }

    NSSet *existingCached = [cachedLayerSet copy];
    for (CALayer *cachedLayer in existingCached) {
        if (cachedLayer.superlayer != layer) {
            [cachedLayerSet removeObject:cachedLayer];
        }
    }

    NSArray *existingSublayers = [layer.sublayers copy];
    for (CALayer *sublayer in existingSublayers) {
        if ([[sublayer name] isEqualToString:@"SBSegmentLayer"]) {
            [sublayer removeFromSuperlayer];
            [cachedLayerSet removeObject:sublayer];
        }
    }

    for (SBSegment *segment in videoSegments) {
        NSString *category = [segment category];

        NSString *enabledKey = [NSString stringWithFormat:@"sb_%@", category];
        if (![defaults boolForKey:enabledKey]) {
            continue;
        }

        NSString *colorKey = [NSString stringWithFormat:@"sb_%@_color", category];
        NSData *colorData = [defaults objectForKey:colorKey];
        UIColor *segmentColor = nil;
        if (colorData != nil) {
            segmentColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                             fromData:colorData
                                                                error:nil];
        }
        if (segmentColor == nil) {
            segmentColor = [UIColor greenColor];
        }

        double start = [segment start];
        double end = [segment end];
        CGFloat x = width * (start / totalDuration);
        CGFloat segmentWidth;

        if ([category isEqualToString:@"poi_highlight"]) {
            segmentWidth = 10.0;
        } else {
            segmentWidth = width * ((end - start) / totalDuration);
        }

        CALayer *segmentLayer = [CALayer layer];
        segmentLayer.name = @"SBSegmentLayer";
        segmentLayer.frame = CGRectMake(x, 0, segmentWidth, height);
        segmentLayer.backgroundColor = segmentColor.CGColor;
        [layer addSublayer:segmentLayer];

        [cachedLayerSet addObject:segmentLayer];
    }
}

static NSArray *getSegmentViewsFromPlayerBar(id playerBar) {
    Ivar ivar = class_getInstanceVariable([playerBar class], "_segmentViews");
    if (ivar != NULL) {
        return object_getIvar(playerBar, ivar);
    }
    return nil;
}

- (void)drawSegmentableSegments:(NSArray *)segments playerBar:(id)playerBar playerVC:(id)playerVC {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"sponsorBlock_enabled"]) {
        return;
    }

    NSArray *segmentViews = getSegmentViewsFromPlayerBar(playerBar);
    if (segmentViews == nil || [segmentViews count] == 0) {
        return;
    }

    NSString *videoID = [playerVC valueForKey:@"videoID"];
    SBManager *manager = [SBManager sharedManager];
    NSArray *videoSegments = [[manager segments] objectForKey:videoID];
    if (videoSegments == nil || [videoSegments count] == 0) {
        return;
    }

    double totalDuration = [[playerVC valueForKey:@"totalMediaTime"] doubleValue];
    if (totalDuration <= 0) {
        return;
    }

    for (SBSegment *segment in videoSegments) {
        NSString *category = [segment category];

        NSString *enabledKey = [NSString stringWithFormat:@"sb_%@", category];
        if (![defaults boolForKey:enabledKey]) {
            continue;
        }

        NSString *colorKey = [NSString stringWithFormat:@"sb_%@_color", category];
        NSData *colorData = [defaults objectForKey:colorKey];
        UIColor *segmentColor = nil;
        if (colorData != nil) {
            segmentColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class]
                                                             fromData:colorData
                                                                error:nil];
        }
        if (segmentColor == nil) {
            segmentColor = [UIColor greenColor];
        }

        double segStart = [segment start];
        double segEnd = [segment end];

        for (UIView *segmentView in segmentViews) {
            double viewStart = [[segmentView valueForKey:@"startTime"] doubleValue];
            double viewEnd = [[segmentView valueForKey:@"endTime"] doubleValue];
            double viewDuration = viewEnd - viewStart;
            if (viewDuration <= 0) {
                continue;
            }

            if (segEnd <= viewStart || segStart >= viewEnd) {
                continue;
            }

            double clippedStart = fmax(segStart, viewStart);
            double clippedEnd = fmin(segEnd, viewEnd);
            CGFloat viewWidth = CGRectGetWidth(segmentView.bounds);
            CGFloat viewHeight = CGRectGetHeight(segmentView.bounds);

            CGFloat x = viewWidth * ((clippedStart - viewStart) / viewDuration);
            CGFloat segmentWidth;
            if ([category isEqualToString:@"poi_highlight"]) {
                segmentWidth = 10.0;
            } else {
                segmentWidth = viewWidth * ((clippedEnd - clippedStart) / viewDuration);
            }

            CALayer *segmentLayer = [CALayer layer];
            segmentLayer.name = @"SBSegmentLayer";
            segmentLayer.frame = CGRectMake(x, 0, segmentWidth, viewHeight);
            segmentLayer.backgroundColor = segmentColor.CGColor;

            [segmentView.layer addSublayer:segmentLayer];
        }
    }
}

@end
