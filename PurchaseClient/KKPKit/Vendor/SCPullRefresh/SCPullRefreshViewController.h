//
//  SCPullRefreshViewController.h
//  v2ex-iOS
//
//  Created by Singro on 4/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const KKPStatusBarTappedNotification;

typedef NS_ENUM(NSUInteger, KKPEmptyVCType) {
    
    /*! 搜索为空 */
    KKPEmptyVCType1,
    
    /*! 内容为空 */
    KKPEmptyVCType2,
    
    /*! 出错 */
    KKPEmptyVCType3,
    
    /*! 通用 */
    KKPEmptyVCType4,
};

@interface SCPullRefreshViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat tableViewInsertTop;
@property (nonatomic, assign) CGFloat tableViewInsertBottom;

@property (nonatomic, readonly) BOOL isLoadingMore;
@property (nonatomic, readonly) BOOL isRefreshing;

@property (nonatomic, assign) BOOL hasLoadLastPage;

@property (nonatomic, copy) void (^refreshBlock)();

- (void)beginRefresh;
- (void)endRefresh;
- (void)endRefreshCompletion:(void (^)())completion;

@property (nonatomic, copy) void (^loadMoreBlock)();

- (void)beginLoadMore;
- (void)endLoadMore;
- (void)endLoadMoreCompletion:(void (^)())completion;

@property (nonatomic, copy) void (^loadDataBlock)();

- (void)beginLoadingAnimation;
- (void)endLoadingAnimationCompletion:(void (^)())completion;
- (void)endLoadMoreWithMessage:(NSString *)message completion:(void (^)())completion;

- (void)showEmptyViewWithEmptyType:(KKPEmptyVCType)emptyType title:(NSString *)title subtitle:(NSString *)subtitle buttonTitle:(NSString *)buttonTitle buttonHandlerBlock:(void (^)())handlerBlock;

- (void)hideEmptyView;

@end
