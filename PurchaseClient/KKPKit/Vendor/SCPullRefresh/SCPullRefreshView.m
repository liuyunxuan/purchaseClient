//
//  SCPullRefreshView.m
//  G9UIKit
//
//  Created by Singro on 5/28/15.
//  Copyright (c) 2015 yangcy. All rights reserved.
//

#import "SCPullRefreshView.h"

#import "FrameAccessor.h"
#import "EXTScope.h"

static CGFloat const kRefreshHeight = 60.0f;

@interface SCPullRefreshView ()

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *refreshView; //TODO
@property (nonatomic, strong) UIView *loadMoreView; //TODO
@property (nonatomic, strong) UIView *emptyView; //TODO

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) CGFloat dragOffsetY;



@end

@implementation SCPullRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.isLoadingMore = NO;
    self.isRefreshing = NO;
    
    self.tableViewInsertTop = 64;
    self.tableViewInsertBottom = 0;
    
    return self;
    
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.width, 0}];
        self.refreshView = [[UIView alloc] initWithFrame:(CGRect){0, -kRefreshHeight, self.width, kRefreshHeight}];
        [_headerView addSubview:self.refreshView];
    }
    return _headerView;
}

- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.width, 0}];
        self.loadMoreView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.width, kRefreshHeight}];
        [_footerView addSubview:self.loadMoreView];
    }
    return _footerView;
}


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Refresh
    CGFloat offsetY = -scrollView.contentOffsetY - self.tableViewInsertTop  - 25;
    
//    self.refreshView.timeOffset = MAX(offsetY / 60.0, 0);
    
    // LoadMore
    if (self.loadMoreBlock && scrollView.contentSizeHeight > self.height) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSizeHeight + scrollView.contentInsetTop < [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    
    CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - self.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);
    
//    if (loadMoreOffset > 0) {
//        self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
//    } else {
//        self.loadMoreView.timeOffset = 0;
//    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffsetY - scrollView.contentInsetTop;
    if (refreshOffset > 60 && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
    
    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark - Public Methods

- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    
    if (self.tableView && refreshBlock) {
        self.tableView.tableHeaderView = self.headerView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
    
}

- (void)beginRefresh {
    
//    [self.refreshView beginRefreshing];
    
    self.isRefreshing = YES;
    
    self.refreshBlock();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.tableView.contentInsetTop = kRefreshHeight + self.tableViewInsertTop;
        } completion:nil];
    });
    
}

- (void)endRefresh {
    [self endRefreshCompletion:nil];
}

- (void)endRefreshCompletion:(void (^)())completion {
    
    @weakify(self);
    if (self.isRefreshing) {
//        [self.refreshView endRefreshingCompletion:^{
            @strongify(self);
            
            self.isRefreshing = NO;
            if (completion) {
                completion();
            }
            
            [UIView animateWithDuration:0.5 animations:^{
                self.tableView.contentInsetTop = self.tableViewInsertTop;
            } completion:^(BOOL finished) {
            }];
//        }];
//    } else {
        if (completion) {
            completion();
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.contentInsetTop = self.tableViewInsertTop;
        } completion:^(BOOL finished) {
        }];
    }
    
}

- (void)beginLoadMore {
    
//    [self.loadMoreView beginRefreshing];
    
    self.isLoadingMore = YES;
    
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.tableView.contentInsetBottom = kRefreshHeight + self.tableViewInsertBottom;
        } completion:nil];
    });
    
}

- (void)endLoadMore {
    
    [self endLoadMoreCompletion:nil];
    
}

- (void)endLoadMoreCompletion:(void (^)())completion {
    
//    @weakify(self);
//    [self.loadMoreView endRefreshingCompletion:^{
//        @strongify(self);
        self.isLoadingMore = NO;
        
        if (completion) {
            completion();
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.contentInsetBottom =  + self.tableViewInsertBottom;
        } completion:^(BOOL finished) {
        }];
//    }];
    
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    
    if (self.loadMoreBlock && self.tableView) {
        self.tableView.tableFooterView = self.footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
    
    if (self.loadMoreBlock && self.tableView.contentSizeHeight > self.height) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
}

- (void)setTableViewInsertTop:(CGFloat)tableViewInsertTop {
    _tableViewInsertTop = tableViewInsertTop;
    self.tableView.contentInsetTop = tableViewInsertTop;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewInsertTop, 0, self.tableView.scrollIndicatorInsets.bottom, 0);
}

- (void)setTableViewInsertBottom:(CGFloat)tableViewInsertBottom {
    _tableViewInsertBottom = tableViewInsertBottom;
    self.tableView.contentInsetBottom = tableViewInsertBottom;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, 0, tableViewInsertBottom, 0);
}

#pragma mark - EmptyView

- (void)showEmptyViewWithEmptyType:(G9EmptyType)emptyType title:(NSString *)title subtitle:(NSString *)subtitle buttonTitle:(NSString *)buttonTitle buttonHandlerBlock:(void (^)())handlerBlock {
    
    //TODO
    
}

- (void)hideEmptyView {
//    self.emptyView.hidden = YES;
}


@end
