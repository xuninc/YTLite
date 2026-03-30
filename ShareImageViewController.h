#ifndef ShareImageViewController_h
#define ShareImageViewController_h

#import <UIKit/UIKit.h>

@interface ShareImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *fullImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)viewDidLoad;
- (void)copyImageToPasteboard;
- (void)shareAction;
- (void)saveToPhotos;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
- (void)viewDidLayoutSubviews;
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture;
- (void)scrollViewDidZoom:(UIScrollView *)scrollView;
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view;
- (void)adjustScrollViewInsets;
- (void)adjustHorizontalInsetsWithImageWidth:(CGFloat)imageWidth;
- (void)adjustVerticalInsetsWithImageHeight:(CGFloat)imageHeight;
- (void)hapticFeedback;
- (void)closeButtonTapped;
- (void)share;

@end

#endif /* ShareImageViewController_h */
