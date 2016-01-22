

#import "KKPImageBrowser.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIViewController+SCNavigation.h"
#import "FrameAccessor.h"

#import "KKPButton.h"
#import "KKPColor.h"
#import "EXTScope.h"

#import "KKPImageBrowserCell.h"

static CGFloat const kBottomBarHeight = 50;
static CGFloat const kButtonWidth = 55;
static CGFloat const kButtonHeight = 30;

#define kBarColor RGB(0x333333, 0.8)

static NSString * const kCellIndentifier = @"KKPBrowserCellIndentifier";

@interface KKPImageBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, KKPImageBrowserCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) KKPButton *confirmButton;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, assign) BOOL fullscreen;

@end

@implementation KKPImageBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    _browserType = KKPImageBrowserTypeDefault;

    return self;

}

- (void)dealloc {
    
}

- (void)loadView {
    [super loadView];
    
    [self collectionView];
    
    if (self.browserType == KKPImageBrowserTypeDefault) {
        [self configureBottomBar];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    self.sc_navigationBar.backgroundColor = kBarColor;
    
    self.collectionView.contentOffsetX = self.selectedIndex * self.collectionView.width;

    [self configureNaviBar];
    [self updateSelectionStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.sc_navigationItem.leftBarButtonItem.view.centerY = self.sc_navigationBar.height/2;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateBottomStatus];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - Configure Views

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.frame = CGRectMake(-10, 0, self.view.width + 20, self.view.height);
        _collectionView.contentInsetTop = 64;
        _collectionView.contentInsetBottom = kBottomBarHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = YES;
        [self.view addSubview:_collectionView];
        
        [_collectionView registerClass:[KKPImageBrowserCell class] forCellWithReuseIdentifier:kCellIndentifier];
        
    }
    
    return _collectionView;
}

- (void)configureBottomBar {
    
    self.bottomBarView = [[UIView alloc] initWithFrame:(CGRect){0, self.view.height - kBottomBarHeight, self.view.width, kBottomBarHeight}];
    self.bottomBarView.backgroundColor = kBarColor;
    [self.view addSubview:self.bottomBarView];
    
    KKPButton *confirmButton = [KKPButton buttonWithType:KKPButtonType1];
    confirmButton.frame = (CGRect){10, 10, kButtonWidth, kButtonHeight};
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:confirmButton];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 10, kButtonWidth, kButtonHeight}];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:13];
    [self.bottomBarView addSubview:countLabel];
    
    // title
    self.confirmButton = confirmButton;
    self.countLabel = countLabel;
    confirmButton.title = @"确定";
    
    confirmButton.right = self.view.width - 10;
    countLabel.right = confirmButton.left - 10;
    
    self.countLabel.text = nil;
    self.confirmButton.enabled = NO;

}

- (void)configureNaviBar {
    
    @weakify(self);
    switch (self.browserType) {
        case KKPImageBrowserTypeDefault: {
            self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkbox_check_预览页"]
                                                                                         style:0
                                                                                       handler:^(id sender) {
                @strongify(self);
                [self selectOrCancelAction];
            }];
            UIButton *rightItemView = (UIButton *)self.sc_navigationItem.rightBarButtonItem.view;
            [rightItemView sizeToFit];
//            rightItemView.layer.cornerRadius = rightItemView.height/2;
//            rightItemView.layer.borderWidth = 1;
//            rightItemView.clipsToBounds = YES;
//            rightItemView.backgroundColor = [UIColor clearColor];
//            rightItemView.layer.borderColor = [UIColor whiteColor].CGColor;
            rightItemView.centerY = self.sc_navigationBar.height/2;
            rightItemView.right = self.sc_navigationBar.width - 10;
            [rightItemView setImage:[UIImage imageNamed:@"checkbox_预览页"] forState:UIControlStateNormal];
            [rightItemView setImage:[UIImage imageNamed:@"checkbox_预览页"] forState:UIControlStateHighlighted];
            break;
        }
        case KKPImageBrowserTypeDelete: {
            self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico_delete_预览页导航栏"]
                                                                                         style:0
                                                                                       handler:^(id sender) {
                @strongify(self);
                [self deleteAction];
            }];
            UIView *rightItemView = self.sc_navigationItem.rightBarButtonItem.view;
            rightItemView.centerY = self.sc_navigationBar.height/2;
            rightItemView.right = self.sc_navigationBar.width - 10;
            break;
        }
        default: {
            break;
        }
    }

}

#pragma mark - Data

- (void)loadData
{
}

#pragma mark - Action

- (void)setFullscreen:(BOOL)fullscreen {
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.sc_navigationBar.alpha = fullscreen ? 0 : 1;
        self.bottomBarView.alpha = fullscreen ? 0 : 1;
    } completion:^(BOOL finished) {
        _fullscreen = fullscreen;
    }];
    
}

- (void)selectAsset:(ALAsset *)asset {
    
    [self updateBottomStatus];
}

- (void)deselectAsset:(ALAsset *)asset {

    [self updateSelectionStatus];
}

- (void)updateSelectionStatus {
    
    NSInteger page = MAX(floor(self.collectionView.contentOffsetX/self.collectionView.width), 0);
    
    switch (self.browserType) {
        case KKPImageBrowserTypeDefault: {
            ALAsset *asset = self.assetsArray[page];
            BOOL isSelected = NO;
            if ([self.selectedAssetsArray containsObject:asset]) {
                isSelected = YES;
            }
            
            UIButton *rightItemView = (UIButton *)self.sc_navigationItem.rightBarButtonItem.view;
            if (isSelected) {
                [rightItemView setImage:[UIImage imageNamed:@"checkbox_check_预览页"] forState:UIControlStateNormal];
                [rightItemView setImage:[UIImage imageNamed:@"checkbox_check_预览页"] forState:UIControlStateHighlighted];
//                rightItemView.backgroundColor = kColor.colorOrange;
//                rightItemView.layer.borderColor = kColor.colorOrange.CGColor;
            } else {
                [rightItemView setImage:[UIImage imageNamed:@"checkbox_预览页"] forState:UIControlStateNormal];
                [rightItemView setImage:[UIImage imageNamed:@"checkbox_预览页"] forState:UIControlStateHighlighted];
//                rightItemView.backgroundColor = [UIColor clearColor];
//                rightItemView.layer.borderColor = [UIColor whiteColor].CGColor;
            }
            break;
        }
        case KKPImageBrowserTypeDelete: {
            break;
        }
        default: {
            break;
        }
    }
    
//    self.sc_navigationItem.title = [NSString stringWithFormat:@"%zd/%zd", page + 1, self.assetsArray.count];
//    self.sc_navigationItem.titleLabel.textColor = kColor.colorUltraLightGray;
//    self.sc_navigationItem.titleLabel.centerY = self.sc_navigationBar.height/2;
    
    [self updateBottomStatus];
}

- (void)updateBottomStatus {
    if (self.selectedAssetsArray.count > 0) {
        self.confirmButton.enabled = YES;
        self.countLabel.textColor = kColor.colorWhite;
        NSInteger maxCount = self.maxSelectedImageCount ?: self.assetsArray.count;
        self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.selectedAssetsArray.count, maxCount];
    } else {
        self.countLabel.textColor = kColor.colorGray;
        if (self.maxSelectedImageCount > 0) {
            self.countLabel.text = [NSString stringWithFormat:@"0/%zd", self.maxSelectedImageCount];
        } else {
            self.countLabel.text = nil;
        }
        self.confirmButton.enabled = NO;
    }
}

- (void)confirmAction {
    
    if ([self.delegate respondsToSelector:@selector(imageBrowserSendPressed:)]) {
        [self.delegate imageBrowserSendPressed:self];
    }

}

- (void)selectOrCancelAction {
    
    NSInteger page = floor(self.collectionView.contentOffsetX/self.collectionView.width);
    ALAsset *asset = self.assetsArray[page];

    BOOL isSelected = NO;
    if ([self.selectedAssetsArray containsObject:asset]) {
        isSelected = YES;
    }

    if (!isSelected &&
        [self.delegate respondsToSelector:@selector(imageBrowser:didSelectAsset:)] &&
        [self.delegate imageBrowser:self didSelectAsset:asset]) {
        
        UIButton *rightItemView = (UIButton *)self.sc_navigationItem.rightBarButtonItem.view;
        [rightItemView setImage:[UIImage imageNamed:@"checkbox_check_预览页"] forState:UIControlStateNormal];
        [rightItemView setImage:[UIImage imageNamed:@"checkbox_check_预览页"] forState:UIControlStateHighlighted];
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            rightItemView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                rightItemView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self updateSelectionStatus];
            }];
        }];
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(imageBrowser:didDeselectAsset:)]) {
            [self.delegate imageBrowser:self didDeselectAsset:asset];
        }
        [self updateSelectionStatus];
        
    }
}

- (void)deleteAction {
    
    NSInteger page = floor(self.collectionView.contentOffsetX/self.collectionView.width);
    ALAsset *asset = self.assetsArray[page];

    NSMutableArray *assetsArray = [NSMutableArray arrayWithArray:self.assetsArray];
    if ([assetsArray containsObject:asset]) {
        
        [assetsArray removeObject:asset];
        self.assetsArray = assetsArray;
        self.selectedAssetsArray = assetsArray;
        
        [self.collectionView performBatchUpdates:^{
            if (self.assetsArray.count == 0) {
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
            } else {
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:page inSection:0]]];
            }
        } completion:^(BOOL finished) {
            
            [self updateSelectionStatus];

            if ([self.delegate respondsToSelector:@selector(imageBrowser:didDeleteAsset:)]) {
                [self.delegate imageBrowser:self didDeleteAsset:asset];
            }
            
            if (assetsArray.count  == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    }
    
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KKPImageBrowserCell *cell = (KKPImageBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIndentifier
                                                                                               forIndexPath:indexPath];
    
    ALAsset *asset = self.assetsArray[indexPath.row];
    cell.asset = asset;
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.assetsArray.count > 0 ? 1 : 0;
}

#pragma mark - UICollectionLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.width+20, self.view.height);
}

#pragma mark - UICollectionDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateSelectionStatus];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateSelectionStatus];
}

#pragma mark - KKPImageBrowserCellDelegate

- (void)imageSingleTapDetected {
    self.fullscreen = !self.fullscreen;
}

@end
