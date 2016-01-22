

#import <UIKit/UIKit.h>

@protocol KKPTapDetectingImageViewDelegate;

@interface KKPTapDetectingImageView : UIImageView

@property (nonatomic, assign) id <KKPTapDetectingImageViewDelegate> tapDelegate;

@end

@protocol KKPTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end