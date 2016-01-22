//
//  SCPullRefreshView.h
//  G9UIKit
//
//  Created by Singro on 5/28/15.
//  Copyright (c) 2015 yangcy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, G9EmptyType) {
    
    /*! 搜索为空 */
    G9EmptyType1,
    
    /*! 内容为空 */
    G9EmptyType2,
    
    /*! 出错 */
    G9EmptyType3,
    
    /*! 通用 */
    G9EmptyType4,
};

@class G9EmptyView;
@interface SCPullRefreshView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, readonly) UIView *emptyView;

@property (nonatomic, assign) CGFloat tableViewInsertTop;
@property (nonatomic, assign) CGFloat tableViewInsertBottom;

@property (nonatomic, copy) void (^refreshBlock)();

- (void)beginRefresh;
- (void)endRefresh;
- (void)endRefreshCompletion:(void (^)())completion;

@property (nonatomic, copy) void (^loadMoreBlock)();

- (void)beginLoadMore;
- (void)endLoadMore;
- (void)endLoadMoreCompletion:(void (^)())completion;

@property (nonatomic, copy) void (^loadDataBlock)();

- (void)showEmptyViewWithEmptyType:(G9EmptyType)emptyType title:(NSString *)title subtitle:(NSString *)subtitle buttonTitle:(NSString *)buttonTitle buttonHandlerBlock:(void (^)())handlerBlock;

- (void)hideEmptyView;

@end
