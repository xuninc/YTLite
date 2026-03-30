#import "ShareImageViewController.h"
#import "BlurButton.h"

@implementation ShareImageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self hapticFeedback];

    // Close button (left bar button)
    UIImage *closeImage = [UIImage systemImageNamed:@"xmark"];
    UIView *closeButton = [BlurButton createButtonWithImage:closeImage target:self action:@selector(closeButtonTapped) menu:nil];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];

    // Copy action
    NSBundle *bundle = [NSBundle ytl_defaultBundle];
    NSString *copyTitle = [bundle localizedStringForKey:@"Copy" value:nil table:nil];
    UIImage *copyImage = [UIImage systemImageNamed:@"doc.on.doc"];
    UIAction *copyAction = [UIAction actionWithTitle:copyTitle image:copyImage identifier:nil handler:^(__kindof UIAction *action) {
        [self copyImageToPasteboard];
    }];

    // Share action
    bundle = [NSBundle ytl_defaultBundle];
    NSString *shareTitle = [bundle localizedStringForKey:@"Share" value:nil table:nil];
    UIImage *shareImage = [UIImage systemImageNamed:@"square.and.arrow.up"];
    UIAction *shareActionItem = [UIAction actionWithTitle:shareTitle image:shareImage identifier:nil handler:^(__kindof UIAction *action) {
        [self shareAction];
    }];

    // Save to Photos action
    bundle = [NSBundle ytl_defaultBundle];
    NSString *saveTitle = [bundle localizedStringForKey:@"SaveToPhotos" value:nil table:nil];
    UIImage *saveImage = [UIImage systemImageNamed:@"photo"];
    UIAction *saveAction = [UIAction actionWithTitle:saveTitle image:saveImage identifier:nil handler:^(__kindof UIAction *action) {
        [self saveToPhotos];
    }];

    // Menu button (right bar button)
    NSArray *menuActions = @[saveAction, shareActionItem, copyAction];
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:menuActions];

    UIImage *ellipsisImage = [UIImage systemImageNamed:@"ellipsis"];
    UIView *menuButton = [BlurButton createButtonWithImage:ellipsisImage target:nil action:nil menu:menu];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];

    // Set navigation bar items
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];

    // Set view background color
    [self.view setBackgroundColor:[UIColor clearColor]];

    // Configure navigation bar
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setTranslucent:YES];
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];

    // Blur effect background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurView setFrame:self.view.bounds];
    [blurView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:blurView];
    [self.view sendSubviewToBack:blurView];

    // Configure scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.scrollView setMaximumZoomScale:3.0];
    [self.scrollView setMinimumZoomScale:1.0];
    [self.scrollView setDelegate:self];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal * 0.5];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.scrollView];

    // Configure image view
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setImage:self.fullImage];
    [self.scrollView addSubview:self.imageView];

    // Double-tap gesture recognizer
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.scrollView addGestureRecognizer:doubleTap];

    // Auto Layout constraints - scrollView to view edges
    [[self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];

    // Auto Layout constraints - imageView size and center to scrollView
    [[self.imageView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor] setActive:YES];
    [[self.imageView.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor] setActive:YES];
    [[self.imageView.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor] setActive:YES];
    [[self.imageView.centerYAnchor constraintEqualToAnchor:self.scrollView.centerYAnchor] setActive:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self adjustScrollViewInsets];

    CGFloat horizontalInset = (self.scrollView.contentSize.width - self.scrollView.bounds.size.width) * 0.5;
    CGFloat verticalInset = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) * 0.5;

    if (horizontalInset < 0.0) {
        horizontalInset = 0.0;
    }
    if (verticalInset < 0.0) {
        verticalInset = 0.0;
    }

    [self.scrollView setContentOffset:CGPointMake(horizontalInset, verticalInset)];
}

#pragma mark - Actions

- (void)copyImageToPasteboard {
    [self hapticFeedback];
    UIImage *image = [self.imageView image];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setImage:image];
}

- (void)shareAction {
    [self hapticFeedback];
    [self share];
}

- (void)saveToPhotos {
    [self hapticFeedback];
    UIImage *image = [self.imageView image];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)closeButtonTapped {
    [self hapticFeedback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share {
    UIImage *image = self.fullImage;
    NSArray *activityItems = @[image];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];

    NSArray *excludedTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [activityVC setExcludedActivityTypes:excludedTypes];

    UIPopoverPresentationController *popover = [activityVC popoverPresentationController];
    if (popover != nil) {
        [activityVC.popoverPresentationController setSourceView:self.view];

        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect sourceRect = CGRectMake(screenBounds.size.width * 0.5, screenBounds.size.height, 0, 0);
        [activityVC.popoverPresentationController setSourceRect:sourceRect];

        [activityVC.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    }

    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    CGFloat currentZoom = self.scrollView.zoomScale;
    CGFloat maxZoom = self.scrollView.maximumZoomScale;

    if (currentZoom == maxZoom) {
        CGFloat minZoom = self.scrollView.minimumZoomScale;
        [self.scrollView setZoomScale:minZoom animated:YES];
    } else {
        CGPoint tapPoint = [gesture locationInView:self.imageView];
        CGFloat zoomScale = self.scrollView.maximumZoomScale;
        CGSize boundsSize = self.scrollView.bounds.size;

        CGRect zoomRect = CGRectMake(
            tapPoint.x - (boundsSize.width / zoomScale) * 0.5,
            tapPoint.y - (boundsSize.height / zoomScale) * 0.5,
            boundsSize.width / zoomScale,
            boundsSize.height / zoomScale
        );
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustScrollViewInsets];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self adjustScrollViewInsets];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self adjustScrollViewInsets];
}

#pragma mark - Scroll View Inset Adjustment

- (void)adjustScrollViewInsets {
    UIImage *image = [self.imageView image];
    CGSize imageSize = [image size];
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;

    CGRect imageViewFrame = [self.imageView frame];

    CGFloat aspectRatio = imageWidth / imageHeight;
    if (imageViewFrame.size.height < imageViewFrame.size.width / aspectRatio) {
        [self adjustHorizontalInsetsWithImageWidth:aspectRatio * imageViewFrame.size.height];
    } else {
        [self adjustVerticalInsetsWithImageHeight:imageViewFrame.size.width / aspectRatio];
    }
}

- (void)adjustHorizontalInsetsWithImageWidth:(CGFloat)imageWidth {
    CGFloat scrollViewWidth = self.scrollView.contentSize.width;
    CGFloat horizontalInset = (scrollViewWidth - imageWidth) * 0.5;

    CGFloat frameWidth = self.scrollView.frame.size.width;
    if (imageWidth < frameWidth) {
        horizontalInset = horizontalInset + (frameWidth - imageWidth) * -0.5;
    }

    UIEdgeInsets insets = UIEdgeInsetsMake(0, -horizontalInset, 0, -horizontalInset);
    [self.scrollView setContentInset:insets];
}

- (void)adjustVerticalInsetsWithImageHeight:(CGFloat)imageHeight {
    CGFloat scrollViewHeight = self.scrollView.contentSize.height;
    CGFloat verticalInset = (scrollViewHeight - imageHeight) * 0.5;

    CGFloat frameHeight = self.scrollView.frame.size.height;
    if (imageHeight < frameHeight) {
        verticalInset = verticalInset + (frameHeight - imageHeight) * -0.5;
    }

    UIEdgeInsets insets = UIEdgeInsetsMake(-verticalInset, 0, -verticalInset, 0);
    [self.scrollView setContentInset:insets];
}

#pragma mark - Utilities

- (void)hapticFeedback {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [generator prepare];
    [generator impactOccurred];
}

@end
