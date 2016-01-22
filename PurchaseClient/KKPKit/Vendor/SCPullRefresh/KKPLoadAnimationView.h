
#import <UIKit/UIKit.h>

@interface KKPLoadAnimationView : UIView

- (void)beginAnimation;
- (void)endAnimationCompletion:(void (^)())complete;

@end
