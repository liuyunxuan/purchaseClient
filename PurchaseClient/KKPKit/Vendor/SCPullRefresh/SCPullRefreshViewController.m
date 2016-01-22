//
//  SCPullRefreshViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//



#import "SCPullRefreshViewController.h"

//#import "KKPUIKitConstants.h"

#import "FrameAccessor.h"
#import "EXTScope.h"

#import "KKPRefreshView.h"
#import "KKPLoadmoreView.h"
#import "KKPLoadAnimationView.h"
#import "KKPEmptyView.h"

NSString * const KKPStatusBarTappedNotification = @"StatusBarTappedNotification";

static CGFloat const kRefreshHeight = 60.0f;
static CGFloat const kLoadmoreHeight = 68.0f;

@interface SCPullRefreshViewController ()

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic, strong) KKPRefreshView *refreshView;
@property (nonatomic, strong) KKPLoadmoreView *loadMoreView;
@property (nonatomic, strong) KKPLoadAnimationView *loadAnimationView;

@property (nonatomic, readwrite) BOOL isLoadingMore;
@property (nonatomic, readwrite) BOOL isRefreshing;
@property (nonatomic, readwrite) BOOL isDragging;
@property (nonatomic, assign) BOOL hasShowNoMoreView;

//@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@property (nonatomic, strong) KKPEmptyView *emptyView;

@end

@implementation SCPullRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isLoadingMore = NO;
        self.isRefreshing = NO;
        
        self.tableViewInsertTop = 64;
        self.tableViewInsertBottom = 0;
        
        self.hasLoadLastPage = NO;
        self.hasShowNoMoreView = NO;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    //    [self loadAnimationView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveStatusBarTappedNotification)
                                                 name:KKPStatusBarTappedNotification
                                               object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKPStatusBarTappedNotification object:nil];
    
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableViewInsertTop, 0, self.tableViewInsertBottom, 0);
    
}

- (UIView *)tableHeaderView {
    if (nil == _tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.width, 0}];
        self.refreshView = [[KKPRefreshView alloc] initWithFrame:(CGRect){0, -kRefreshHeight, self.view.width, kRefreshHeight}];
        self.refreshView.timeOffset = 0.0;
        [_tableHeaderView addSubview:self.refreshView];
    }
    return _tableHeaderView;
}

- (UIView *)tableFooterView {
    if (nil == _tableFooterView) {
        _tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.width, 0}];
        self.loadMoreView = [[KKPLoadmoreView alloc] initWithFrame:(CGRect){0, 0, self.view.width, kLoadmoreHeight}];
        self.loadMoreView.timeOffset = 0.0;
        [_tableFooterView addSubview:self.loadMoreView];
    }
    return _tableFooterView;
}

- (UIView *)loadAnimationView {
    
    if (nil == _loadAnimationView) {
        
        KKPLoadAnimationView *loadAnimationView = [[KKPLoadAnimationView alloc] initWithFrame:(CGRect){0, 0, self.view.width, self.view.height}];
        loadAnimationView.hidden = YES;
        [self.view addSubview:loadAnimationView];
        
        _loadAnimationView = loadAnimationView;
    }
    
    [self.view bringSubviewToFront:_loadAnimationView];
    
    return _loadAnimationView;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Refresh
    CGFloat offsetY = -scrollView.contentOffsetY - self.tableViewInsertTop  - 25;
    
    self.refreshView.timeOffset = MAX(offsetY / kRefreshHeight, 0);
    
    if (offsetY > - 20 || self.refreshBlock) {
        self.refreshView.hidden = NO;
    }
    
    // LoadMore
    if ((self.loadMoreBlock && scrollView.contentSizeHeight > self.view.height)) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSizeHeight + scrollView.contentInsetTop < [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    
    CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);
    
    if (loadMoreOffset > 0) {
        self.loadMoreView.timeOffset = MAX(loadMoreOffset / kLoadmoreHeight, 0);
    } else {
        self.loadMoreView.timeOffset = 0;
    }
    
    // Auto loadMore
    if (loadMoreOffset > 0 && self.loadMoreBlock && !self.isLoadingMore
        && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height
        && !self.hasLoadLastPage && !self.isDragging) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.isDragging = YES;
    
    self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.isDragging = NO;
    
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffsetY - scrollView.contentInsetTop;
    if (refreshOffset > kRefreshHeight && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
    
    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    if (loadMoreOffset < -kLoadmoreHeight
        && self.loadMoreBlock
        && !self.isLoadingMore
        && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height
        ) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark - Public Methods

- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    
    if (self.tableView) {
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
    
}

- (void)beginRefresh {
    
    [self.refreshView beginRefreshing];
    
    self.isRefreshing = YES;
    
    self.refreshBlock();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.tableView.contentInsetTop = kRefreshHeight + self.tableViewInsertTop;
            [self.tableView setContentOffset:(CGPoint){0,- (kRefreshHeight + self.tableViewInsertTop )} animated:NO];
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        } completion:nil];
    });
    
}

- (void)endRefresh {
    
    if ((self.loadMoreBlock && self.tableView.contentSizeHeight > self.view.height)) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    [self endRefreshCompletion:nil];
}

- (void)endRefreshCompletion:(void (^)())completion {
    
    @weakify(self);
    [self.refreshView endRefreshingCompletion:^{
        @strongify(self);
        
        self.isRefreshing = NO;
        if (completion) {
            completion();
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.contentInsetTop = self.tableViewInsertTop;
        } completion:^(BOOL finished) {
            
            self.refreshView.hidden = YES;
            
        }];
    }];
    
}


- (void)beginLoadMore {
    
    if (self.isLoadingMore || self.hasShowNoMoreView) {
        return;
    }
    
    [self.loadMoreView beginRefreshing];
    
    self.isLoadingMore = YES;
    
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.tableView.contentInsetBottom = kLoadmoreHeight + self.tableViewInsertBottom;
        } completion:^(BOOL finished) {
            
        }];
    });
    
}

- (void)endLoadMore {
    
    if (!self.isLoadingMore) {
        return;
    }
    
    if (self.hasLoadLastPage) {
        [self endLoadMoreWithMessage:@"无更多内容了╮(╯▽╰)╭" completion:nil];
    } else {
        [self endLoadMoreCompletion:nil];
    }
    
}

- (void)endLoadMoreCompletion:(void (^)())completion {
    
    @weakify(self);
    [self.loadMoreView endRefreshingCompletion:^{
        @strongify(self);
        
        if (completion) {
            completion();
        }
        
        if ((self.loadMoreBlock && self.tableView.contentSizeHeight > self.view.height)) {
            self.loadMoreView.hidden = NO;
        } else {
            self.loadMoreView.hidden = YES;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.contentInsetBottom = self.tableViewInsertBottom;
        } completion:^(BOOL finished) {
            self.isLoadingMore = NO;
        }];
    }];
    
}

- (void)endLoadMoreWithMessage:(NSString *)message completion:(void (^)())completion
{
    
    @weakify(self);
    [self.loadMoreView endRefreshingWithMessage:message completion:^{
        @strongify(self);
        
        if (completion) {
            completion();
        }
        
        self.hasShowNoMoreView = YES;
        
        if ((self.loadMoreBlock && self.tableView.contentSizeHeight > self.view.height)) {
            self.loadMoreView.hidden = NO;
        } else {
            self.loadMoreView.hidden = YES;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.tableView.contentInsetBottom = self.tableViewInsertBottom;
            } completion:^(BOOL finished) {
                self.isLoadingMore = NO;
            }];
        });
    }];
    
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    
    if (self.loadMoreBlock && self.tableView) {
        self.tableView.tableFooterView = self.tableFooterView;
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

- (void)setHasLoadLastPage:(BOOL)hasLoadLastPage
{
    _hasLoadLastPage = hasLoadLastPage;
    
    if (NO == hasLoadLastPage) {
        self.hasShowNoMoreView = NO;
        [self.loadMoreView hideNoMoreView];
    }
}

#pragma mark - Public Method Loading

- (void)beginLoadingAnimation {
    
    self.loadAnimationView.hidden = NO;
    [self.loadAnimationView beginAnimation];
    [self.view bringSubviewToFront:self.loadAnimationView];
    
}

- (void)endLoadingAnimationCompletion:(void (^)())completion {
    
    if (completion) {
        @weakify(self);
        [self.loadAnimationView endAnimationCompletion:^{
            @strongify(self);
            self.loadAnimationView.hidden = YES;
            completion();
        }];
    } else {
        [self.loadAnimationView endAnimationCompletion:nil];
        self.loadAnimationView.hidden = YES;
    }
    
}


#pragma mark - EmptyView

- (void)showEmptyViewWithEmptyType:(KKPEmptyVCType)emptyType title:(NSString *)title subtitle:(NSString *)subtitle buttonTitle:(NSString *)buttonTitle buttonHandlerBlock:(void (^)())handlerBlock {
    
    [self endLoadingAnimationCompletion:nil];
    
    if (!self.emptyView) {
        self.emptyView = [self createEmptyView];
        if (self.tableView) {
            [self.tableView addSubview:self.emptyView];
            [self.tableView bringSubviewToFront:self.emptyView];
        } else {
            [self.view addSubview:self.emptyView];
            [self.view bringSubviewToFront:self.emptyView];
        }
    }

    self.emptyView.hidden = NO;
    if (self.tableView) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        self.emptyView.y = (screenHeight - self.emptyView.emptyViewHeight - self.tableViewInsertTop - self.tableViewInsertBottom)/2 - 20;
        [self.tableView bringSubviewToFront:self.emptyView];
    } else {
        self.emptyView.y = ([UIScreen mainScreen].bounds.size.height - self.emptyView.emptyViewHeight - 64)/2 + 64 - 20;
        [self.view bringSubviewToFront:self.emptyView];
    }
}

- (void)hideEmptyView {
    self.emptyView.hidden = YES;
}

- (KKPEmptyView *)createEmptyView {
    KKPEmptyView *emptyView = [[KKPEmptyView alloc] initWithFrame:CGRectZero];
    emptyView.emptyImageType = KKPEmptyImageType3;
    emptyView.centerX = self.view.width/2;
    emptyView.hidden = YES;
    return emptyView;
}

#pragma mark - Notifications

- (void)didReceiveStatusBarTappedNotification {
    
    [self.tableView scrollRectToVisible:(CGRect){0, 0, self.view.width, 0.1} animated:YES];
    
}

@end
