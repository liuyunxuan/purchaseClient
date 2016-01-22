

#import "KKPPullRefresh.h"


#import "FrameAccessor.h"
#import "EXTScope.h"

#import "KKPRefreshView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

static CGFloat const kRefreshHeight = 65.0f;

@interface KKPPullRefresh ()

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) KKPRefreshView *refreshView;
@property (nonatomic, strong) KKPRefreshView *loadMoreView;

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@end

@implementation KKPPullRefresh

//@synthesize scrollViewInsertTop = _scrollViewInsertTop, scrollViewInsertBottom = _scrollViewInsertBottom;

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.isLoadingMore = NO;
    self.isRefreshing = NO;
    self.hadLoadMore = NO;
    
    self.scrollViewInsertTop = 0;
    self.scrollViewInsertBottom = 0;
    
    return self;
    
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
        self.refreshView = [[KKPRefreshView alloc] initWithFrame:(CGRect){0, -kRefreshHeight, kScreenWidth, kRefreshHeight}];
        self.refreshView.timeOffset = 0.0;
        [_headerView addSubview:self.refreshView];
    }
    return _headerView;
}

- (UIView *)footerView {
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
        self.loadMoreView = [[KKPRefreshView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kRefreshHeight}];
        self.loadMoreView.timeOffset = 0.0;
        [_footerView addSubview:self.loadMoreView];
    }
    return _footerView;
}


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.scrollResponseObject respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.scrollResponseObject performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
    }
    
    // Refresh
    CGFloat offsetY = -scrollView.contentOffsetY - self.scrollViewInsertTop  - 25;
    
    if (_headerView) {
        if ((-scrollView.contentOffsetY - self.scrollViewInsertTop < 5 || nil == self.refreshBlock) && self.isRefreshing == NO) {
            _headerView.hidden = YES;
        } else {
            _headerView.hidden = NO;
        }
    }
    self.refreshView.timeOffset = MAX(offsetY / 60.0, 0);
    
    // LoadMore
    if ((self.loadMoreBlock && scrollView.contentSizeHeight > 300) || !self.hadLoadMore) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSizeHeight + scrollView.contentInsetTop < [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    
    CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - scrollView.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);
    
    if (loadMoreOffset > 0) {
        self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
    } else {
        self.loadMoreView.timeOffset = 0;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([self.scrollResponseObject respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.scrollResponseObject performSelector:@selector(scrollViewWillBeginDragging:) withObject:scrollView];
    }
    
    self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if ([self.scrollResponseObject respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.scrollResponseObject performSelector:@selector(scrollViewDidEndDragging:willDecelerate:) withObject:scrollView withObject:@(decelerate)];
    }
    
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffsetY - scrollView.contentInsetTop;
    if (refreshOffset > 60 && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
    
    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - scrollView.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.scrollResponseObject respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.scrollResponseObject performSelector:@selector(scrollViewDidEndDecelerating:) withObject:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.scrollResponseObject respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.scrollResponseObject performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView];
    }
}

#pragma mark - Public Methods

- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    
    if (self.scrollView && refreshBlock) {
        if (![self.scrollView.subviews containsObject:self.headerView]) {
            [self.scrollView addSubview:self.headerView];
        }
        self.headerView.y = 0;
        self.headerView.centerX = self.scrollView.width/2;
    } else {
        if ([self.scrollView.subviews containsObject:self.headerView]) {
            [self.headerView removeFromSuperview];
        }
    }
    
}

- (void)beginRefresh {
    
    if (self.isRefreshing) {
        [self.refreshView endRefreshingCompletion:nil];
        return;
    }
    [self.refreshView beginRefreshing];
    
    self.isRefreshing = YES;
    
    self.refreshBlock();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.scrollView.contentInsetTop = kRefreshHeight + self.scrollViewInsertTop;
        } completion:nil];
    });
    
}

- (void)endRefresh {
    
    @weakify(self);
    [self.refreshView endRefreshingCompletion:^{
        @strongify(self);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.scrollView.contentInsetTop = self.scrollViewInsertTop;
        } completion:^(BOOL finished) {
            self.isRefreshing = NO;
            self.headerView.hidden = YES;
        }];
    }];
    
}

- (void)beginLoadMore {
    
    [self.loadMoreView beginRefreshing];
    
    self.isLoadingMore = YES;
    self.hadLoadMore = YES;
    
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.scrollView.contentInsetBottom = kRefreshHeight + self.scrollViewInsertBottom;
        } completion:nil];
    });
    
}

- (void)endLoadMore {
    
    @weakify(self);
    [self.loadMoreView endRefreshingCompletion:^{
        @strongify(self);
        self.isLoadingMore = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentInsetBottom =  + self.scrollViewInsertBottom;
        }];
    }];
    
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    
    if (self.loadMoreBlock && self.scrollView) {
        if (![self.scrollView.subviews containsObject:self.footerView]) {
            [self.scrollView addSubview:self.footerView];
        }
        self.footerView.y = self.scrollView.contentSizeHeight;
        self.footerView.centerX = self.scrollView.width/2;
    } else {
        if ([self.scrollView.subviews containsObject:self.footerView]) {
            [self.footerView removeFromSuperview];
        }
    }
    
}

#pragma mark - Contents

- (void)setScrollViewInsertTop:(CGFloat)scrollViewInsertTop {
    _scrollViewInsertTop = scrollViewInsertTop;
    self.scrollView.contentInsetTop = scrollViewInsertTop;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollViewInsertTop, 0, self.scrollView.scrollIndicatorInsets.bottom, 0);
    self.headerView.y = 0;
}

- (void)setScrollViewInsertBottom:(CGFloat)scrollViewInsertBottom {
    _scrollViewInsertBottom = scrollViewInsertBottom;
    self.scrollView.contentInsetBottom = scrollViewInsertBottom;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.scrollView.contentInsetTop, 0, scrollViewInsertBottom, 0);
    self.footerView.y = self.scrollView.contentSizeHeight;
}

//- (CGFloat)scrollViewInsertTop {
//    NSLog(@"top: %.f", _scrollViewInsertTop);
//    return _scrollViewInsertTop;
//}
//
//- (CGFloat)scrollViewInsertBottom {
//    NSLog(@"bottom: %.f", _scrollViewInsertBottom);
//    return _scrollViewInsertBottom;
//}

- (void)setScrollView:(UIScrollView *)scrollView {
    
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
    }
    
    _scrollView = scrollView;
    
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        self.headerView.y = 0;
        self.footerView.y = self.scrollView.contentSizeHeight;
    }
    
}

-(void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
}
@end
