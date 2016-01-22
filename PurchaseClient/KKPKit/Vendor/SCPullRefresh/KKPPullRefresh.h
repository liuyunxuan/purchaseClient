

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KKPPullRefresh : NSObject <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollResponseObject;

@property (nonatomic, assign) CGFloat scrollViewInsertTop;
@property (nonatomic, assign) CGFloat scrollViewInsertBottom;

@property (nonatomic, copy) void (^refreshBlock)();

- (void)beginRefresh;
- (void)endRefresh;

@property (nonatomic, copy) void (^loadMoreBlock)();

- (void)beginLoadMore;
- (void)endLoadMore;


@end
