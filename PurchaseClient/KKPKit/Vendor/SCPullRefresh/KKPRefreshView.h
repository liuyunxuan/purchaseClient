

#import <UIKit/UIKit.h>

@interface KKPRefreshView : UIView

@property (nonatomic, assign) CGFloat timeOffset;  // 0.0 ~ 1.0

- (void)beginRefreshing;
- (void)endRefreshingCompletion:(void (^)())complete;

@end
