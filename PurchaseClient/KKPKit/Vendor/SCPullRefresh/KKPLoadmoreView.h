

#import <UIKit/UIKit.h>

@interface KKPLoadmoreView : UIView

@property (nonatomic, assign) CGFloat timeOffset;  // 0.0 ~ 1.0

- (void)beginRefreshing;
- (void)endRefreshingCompletion:(void (^)())complete;
- (void)endRefreshingWithMessage:(NSString *)message completion:(void (^)())completion;

- (void)hideNoMoreView;

@end
