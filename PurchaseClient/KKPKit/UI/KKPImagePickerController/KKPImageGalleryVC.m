

#import "KKPImageGalleryVC.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "UIViewController+SCNavigation.h"
#import "FrameAccessor.h"
#import "KKPAlertController.h"
#import "EXTScope.h"
#import "KKPButton.h"
#import "KKPColor.h"
#import "ALAsset+UIImage.h"

#import "KKPImagePickerController.h"
#import "KKPImageBrowser.h"
#import "KKPAssetsLibraryManager.h"
//#import "KKPImagePickerNoAccessVC.h"
//#import "KKPImageCropper.h"

#import "KKPImagePickerModel.h"

#import "KKPImagePickerImageCell.h"
#import "KKPImagePickerCameraView.h"

static NSString * const kCellIndentifier = @"KKPImagePickerImageCell";
static NSString * const kCameraCellIndentifier = @"KKPImagePickerCameraCell";

static CGFloat const kMargin = 5;
static CGFloat const kBottomBarHeight = 50;
static CGFloat const kButtonWidth = 55;
static CGFloat const kButtonHeight = 30;
static CGFloat const kCameraViewHeight = 150;

@interface KKPImageGalleryVC () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    KKPImageBrowserDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *selectedAssetsArray;

@property (nonatomic, assign) NSInteger maxSelectedImageCount;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) KKPButton *previewButton;
@property (nonatomic, strong) KKPButton *confirmButton;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) KKPImagePickerCameraView *cameraView;
@property (nonatomic, strong) UIView *backWhiteView;

@property (nonatomic, assign) BOOL hasCamera;

@property (nonatomic, assign) BOOL hasConfigureBottomViews;
@property (nonatomic, assign) BOOL willDismiss;

@end

@implementation KKPImageGalleryVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }

    _assetsArray = [NSMutableArray new];
    _selectedAssetsArray = [NSMutableArray new];
    _hasCamera = NO;

    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *cameraDevice;
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo] &&
            ([device position] == AVCaptureDevicePositionFront ||
            [device position] == AVCaptureDevicePositionBack)) {
            cameraDevice = device;
                _hasCamera = YES;
        }
    }
    
    _hasConfigureBottomViews = NO;
    _willDismiss = NO;

    return self;

}

- (void)dealloc
{
    
}

- (void)loadView
{
    [super loadView];
    
    [self cameraView];
    [self collectionView];

    // Configure Bottom Views
    if (!self.hasConfigureBottomViews) {
        self.hasConfigureBottomViews = YES;
        
        switch (self.picker.mode) {
            case KKPImagePickerModeMultiple: {
                [self configureBottomBar];
                self.collectionView.contentInsetBottom = kBottomBarHeight;
                [self.collectionView registerClass:[KKPImagePickerImageCell class] forCellWithReuseIdentifier:kCellIndentifier];
                break;
            }
                
            case KKPImagePickerModeSingle: {
                [self.collectionView registerClass:[KKPImagePickerImageOnlyCell class] forCellWithReuseIdentifier:kCellIndentifier];
                break;
            }
                
            default: {
                break;
            }
        }
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // configure here for show as setViewControllers:
    KKPImagePickerController *picker = self.picker;
    self.maxSelectedImageCount = picker.maxSelecteImageCount;
    
    self.sc_navigationItem.title = self.assetsGroup.assetsGroupName;
    @weakify(picker);
    self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithTitle:@"取消" style:0 handler:^(id sender) {
        @strongify(picker);
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([picker.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
                [picker.imagePickerDelegate imagePickerControllerDidCancel:picker];
            }
            
        }];
    }];
    

    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Camera Access
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self.cameraView updateCamera];
        }];
    }
    

    
    [self updateSelectionStatus];
    
    if (!self.willDismiss) {
        [self.cameraView updateCamera];
    }

}

#pragma mark - Configure Views

- (KKPImagePickerCameraView *)cameraView
{
    if (nil == _cameraView) {
        
        KKPImagePickerCameraView *cameraView = [[KKPImagePickerCameraView alloc] initWithFrame:(CGRect){0, 64, self.view.width, kCameraViewHeight}];
        [self.view addSubview:cameraView];
        
        _cameraView = cameraView;
        
        self.backWhiteView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.backWhiteView.backgroundColor = [UIColor whiteColor];
        self.backWhiteView.y = cameraView.bottom;
        [self.view addSubview:self.backWhiteView];
        
    }
    
    return _cameraView;
}

- (UICollectionView *)collectionView
{
    if (nil == _collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.frame = CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height);
        collectionView.allowsMultipleSelection = YES;
        collectionView.contentInsetTop = 64;
        collectionView.contentInsetLeft = 5;
        collectionView.contentInsetRight = 5;
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(_collectionView.contentInsetTop, 0, _collectionView.contentInsetBottom, 0);
        collectionView.alwaysBounceVertical = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
        
        [collectionView registerClass:[KKPImagePickerCameraCell class] forCellWithReuseIdentifier:kCameraCellIndentifier];
    }
    
    return _collectionView;
}

- (void)configureBottomBar
{
    
    self.bottomBarView = [[UIView alloc] initWithFrame:(CGRect){0, self.view.height - kBottomBarHeight, self.view.width, kBottomBarHeight}];
//    self.bottomBarView.barStyle = UIBarStyleDefault;
    self.bottomBarView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.9];
    [self.view addSubview:self.bottomBarView];
    
    KKPButton *previewButton = [KKPButton buttonWithType:KKPButtonType4];
    previewButton.frame = (CGRect){10, 10, kButtonWidth, kButtonHeight};
    [previewButton addTarget:self action:@selector(previewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:previewButton];

    KKPButton *confirmButton = [KKPButton buttonWithType:KKPButtonType1];
    confirmButton.frame = (CGRect){10, 10, kButtonWidth, kButtonHeight};
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:confirmButton];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 10, kButtonWidth, kButtonHeight}];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:13];
    [self.bottomBarView addSubview:countLabel];
    
    // title
    self.previewButton = previewButton;
    self.confirmButton = confirmButton;
    self.countLabel = countLabel;
    previewButton.title = @"预览";
    confirmButton.title = @"确定";
    
    confirmButton.right = self.view.width - 10;
    countLabel.right = confirmButton.left - 10;
    
    self.countLabel.text = nil;
    self.previewButton.enabled = NO;
    self.confirmButton.enabled = NO;

}

#pragma mark - Data

- (void)loadData
{
    [self.assetsGroup.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.assetsGroup.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assetsArray addObject:result];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];

        });
    });
}

#pragma mark - Action

- (void)selectAsset:(ALAsset *)asset
{
    [self.selectedAssetsArray addObject:asset];
    
    [self updateBottomStatus];
}

- (void)deselectAsset:(ALAsset *)asset
{
    [self.selectedAssetsArray removeObject:asset];
    [self updateSelectionStatus];
}

- (void)updateSelectionStatus
{
    
    for (KKPImagePickerImageCell *cell in [self.collectionView visibleCells]) {
        if ([cell isKindOfClass:[KKPImagePickerImageCell class]]) {
            NSInteger number = 0;
            if ([self.selectedAssetsArray containsObject:cell.asset]) {
                number = [self.selectedAssetsArray indexOfObject:cell.asset] + 1;
            }
            [cell setNumber:number animated:NO];
        }
    }
    
    [self updateBottomStatus];
}

- (void)updateFadeStatus:(BOOL)willFade
{
    
    CGFloat fadeAlpha = 1;
    if (willFade) {
        fadeAlpha = 0.15;
    }
    
    for (KKPImagePickerImageCell *imageCell in self.collectionView.visibleCells) {
        if ([imageCell isKindOfClass:[KKPImagePickerImageCell class]]) {
            if (imageCell.number == 0) {
                [UIView animateWithDuration:0.2 animations:^{
                    imageCell.alpha = fadeAlpha;
                }];
            }
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                imageCell.alpha = fadeAlpha;
            }];
        }
    }
}

- (void)updateBottomStatus
{
    if (self.selectedAssetsArray.count > 0 && self.maxSelectedImageCount > 0) {
        self.previewButton.enabled = YES;
        self.confirmButton.enabled = YES;
        self.countLabel.textColor = kColor.colorDarkGray;
        self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.selectedAssetsArray.count, self.maxSelectedImageCount];
    } else {
        self.countLabel.textColor = kColor.colorLightGray;
        if (self.maxSelectedImageCount > 0) {
            self.countLabel.text = [NSString stringWithFormat:@"0/%zd", self.maxSelectedImageCount];
        } else {
            self.countLabel.text = nil;
        }
        self.previewButton.enabled = NO;
        self.confirmButton.enabled = NO;
    }
}

- (BOOL)didActSelect:(BOOL)willSelect withAsset:(ALAsset *)asset
{

    NSInteger index = [self.assetsArray indexOfObject:asset];
    if (self.hasCamera) {
        index ++;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    KKPImagePickerImageCell *cell = (KKPImagePickerImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (willSelect) {
        if (self.maxSelectedImageCount == 0 || self.selectedAssetsArray.count < self.maxSelectedImageCount) {
            [self selectAsset:asset];
            [cell setNumber:self.selectedAssetsArray.count animated:YES];

            [self updateSelectionStatus];
            
            if (self.selectedAssetsArray.count == self.maxSelectedImageCount) {
                [self updateFadeStatus:YES];
            }
            
        } else {
            if ([self.navigationController.visibleViewController isKindOfClass:[KKPImageBrowser class]]) {
                NSString *message = [NSString stringWithFormat:@"最多选择 %zd 张图", self.maxSelectedImageCount];
                KKPAlertController *alert = [KKPAlertController alertControllerWithTitle:nil
                                                                               message:message
                                                                        preferredStyle:KKPAlertControllerStyleAlert];
                [alert addActionWithTitle:@"确定" style:KKPAlertActionStyleCancel handler:^(KKPAlertAction *action) {
                    
                }];
                [alert showInView:self.navigationController.visibleViewController.view];
            }
            return NO;
        }
    } else {
        
        if (self.selectedAssetsArray.count == self.maxSelectedImageCount) {
            [self updateFadeStatus:NO];
        }
        
        [cell setNumber:0 animated:YES];
        [self deselectAsset:asset];
    }
    
    return YES;
}

- (void)addImageFromCameraAsset:(ALAsset *)asset
{
    
    NSInteger index = 0;
    
    if (self.hasCamera) {
        index ++;
    }

    NSMutableArray *currentAssets = [NSMutableArray arrayWithArray:self.assetsArray];
    [currentAssets insertObject:asset atIndex:0];
    self.assetsArray = currentAssets;
    
    if (self.maxSelectedImageCount == 0 || self.selectedAssetsArray.count < self.maxSelectedImageCount) {
        [self selectAsset:asset];
    }
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:^(BOOL finished) {
        
        if (self.selectedAssetsArray.count == self.maxSelectedImageCount) {
            [self updateFadeStatus:YES];
        } else {
            [self updateFadeStatus:NO];
        }

        [self updateSelectionStatus];
    }];
    
}

- (void)previewAction
{
    
    KKPImageBrowser *browser = [[KKPImageBrowser alloc] init];
    browser.assetsArray = self.selectedAssetsArray;
    browser.selectedAssetsArray = self.selectedAssetsArray;
    browser.maxSelectedImageCount = self.maxSelectedImageCount;
    browser.delegate = self;
    [self.navigationController pushViewController:browser animated:YES];
    
}

- (void)confirmAction
{
    
    KKPImagePickerController *picker = (KKPImagePickerController *)self.navigationController;

    [picker dismissViewControllerAnimated:YES completion:^{
        if ([picker.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImageAssets:)]) {
            [picker.imagePickerDelegate imagePickerController:picker didFinishPickingImageAssets:self.selectedAssetsArray];
        }
    }];

}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.hasCamera) {
        return self.assetsArray.count + 1;
    }
    
    return self.assetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger dataIndex = indexPath.row;
    
    if (self.hasCamera) {
        dataIndex --;
        
        if (indexPath.row == 0) {
            
            KKPImagePickerCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraCellIndentifier
                                                                                      forIndexPath:indexPath];
            
            if (self.selectedAssetsArray.count == self.maxSelectedImageCount && self.maxSelectedImageCount > 0) {
                cell.alpha = 0.15;
            } else {
                cell.alpha = 1;
            }
            
            return cell;
        }
    }
    
    UICollectionViewCell *resultCell = nil;

    switch (self.picker.mode) {
        case KKPImagePickerModeMultiple: {
            
            KKPImagePickerImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIndentifier
                                                                                     forIndexPath:indexPath];
            
            ALAsset *asset = self.assetsArray[dataIndex];
            [self configureImagePickerImageCell:cell withAsset:asset];

            resultCell = cell;
            break;
        }
        case KKPImagePickerModeSingle: {
            
            KKPImagePickerImageOnlyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIndentifier
                                                                                         forIndexPath:indexPath];
            
            cell.asset = self.assetsArray[dataIndex];

            resultCell = cell;
            break;
        }
        default: {
            break;
        }
    }
    
    return resultCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.assetsArray.count > 0 ? 1 : 0;
}

- (void)configureImagePickerImageCell:(KKPImagePickerImageCell *)cell withAsset:(ALAsset *)asset
{
    
    NSInteger number = 0;
    if ([self.selectedAssetsArray containsObject:asset]) {
        number = [self.selectedAssetsArray indexOfObject:asset] + 1;
    }
    cell.asset = asset;
    cell.number = number;
    
    @weakify(self, cell);
    [cell setDidSelectBlock:^BOOL(BOOL willSelect) {
        @strongify(self, cell);
        ALAsset *asset = cell.asset;
        return [self didActSelect:willSelect withAsset:asset];
    }];
    
    if (self.selectedAssetsArray.count == self.maxSelectedImageCount && self.maxSelectedImageCount > 0) {
        if (number > 0) {
            cell.alpha = 1.0;
        } else {
            cell.alpha = 0.15;
        }
    } else {
        cell.alpha = 1.0;
    }

}

#pragma mark - UICollectionLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self hasCamera] && indexPath.row == 0) {
        return CGSizeMake(self.view.width, kCameraViewHeight - 5);
    }
    
    NSUInteger index = indexPath.row;
    if (self.hasCamera) {
        index --;
    }
    CGFloat width = floor((self.view.width - 4 * kMargin)/3);
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

#pragma mark - UICollectionDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[KKPImagePickerCameraCell class]]) {

        [self didSelectActionForCameraCell];
    }
    
    if ([cell isKindOfClass:[KKPImagePickerImageCell class]]) {
        
        KKPImagePickerImageCell *imageCell = (KKPImagePickerImageCell *)cell;
        ALAsset *asset = imageCell.asset;
        
        [self didSelectActionForMultiPickerWithAsset:asset];
    }
    
    if ([cell isKindOfClass:[KKPImagePickerImageOnlyCell class]]) {
        
        
        KKPImagePickerImageOnlyCell *imageCell = (KKPImagePickerImageOnlyCell *)cell;
        ALAsset *asset = imageCell.asset;
        
        [self didSelectActionForSinglePickerWithImageAsset:asset navigationController:self.navigationController];
    }

}

- (void)didSelectActionForCameraCell
{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: // not used
        case AVAuthorizationStatusRestricted: {
            break;
        }
            
        case AVAuthorizationStatusDenied: {
            
//            KKPImagePickerNoAccessVC *noAccessVC = [[KKPImagePickerNoAccessVC alloc] init];
//            [self.navigationController pushViewController:noAccessVC animated:YES];
            
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = self.picker.allowEditing;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
            break;
        }
            
        default: {
            break;
        }
    }

}

- (void)didSelectActionForMultiPickerWithAsset:(ALAsset *)asset
{
    
    NSInteger index = MAX(0, MIN([self.assetsArray indexOfObject:asset], self.assetsArray.count - 1));
    
    KKPImageBrowser *browser = [[KKPImageBrowser alloc] init];
    browser.assetsArray = self.assetsArray;
    browser.selectedAssetsArray = self.selectedAssetsArray;
    browser.selectedIndex = index;
    browser.maxSelectedImageCount = self.maxSelectedImageCount;
    browser.delegate = self;
    [self.navigationController pushViewController:browser animated:YES];

}

- (void)didSelectActionForSinglePickerWithImageAsset:(ALAsset *)selectedImageAsset
                           navigationController:(UINavigationController *)navigationController
{
    
    KKPImagePickerController *picker = (KKPImagePickerController *)self.picker;
    
    void (^finishPickingBlock)(UIImage *, UIImage *) = ^(UIImage *originalImage, UIImage *editImage) {
        
        self.willDismiss = YES;
        
        void (^dismissPickerBlock)() = ^{
            [picker dismissViewControllerAnimated:YES completion:^{
                if ([picker.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingOriginalImage:editImage:)]) {
                    [picker.imagePickerDelegate imagePickerController:picker
                                        didFinishPickingOriginalImage:originalImage
                                                            editImage:editImage];
                }
                if ([picker.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImageAsset:)]) {
                    [picker.imagePickerDelegate imagePickerController:picker
                                        didFinishPickingImageAsset:selectedImageAsset];
                }
            }];
        };
        
        if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
            
            [navigationController dismissViewControllerAnimated:NO completion:^{
                dismissPickerBlock();
            }];
            
        } else {
            
            dismissPickerBlock();
            
        }
        
    };
    
    UIImage *selectedImage = selectedImageAsset.fullImage;
    
    if (self.picker.allowEditing &&
        ![navigationController isKindOfClass:[UIImagePickerController class]]
        ) { // 编辑
//        
//        KKPImageCropper *cropper = [[KKPImageCropper alloc] initWithImage:selectedImage];
//        if (self.picker.editingImageHeight > 0) {
//            cropper.cropHeight = self.picker.editingImageHeight;
//        }
//        
//        [cropper setConfirmBlock:^(KKPImageCropper *imageCropper, UIImage *originalImage, UIImage *editImage) {
//            finishPickingBlock(originalImage, editImage);
//        }];
//        
//        [cropper setCancelBlock:^(KKPImageCropper *imageCropper) {
//            [imageCropper.navigationController popViewControllerAnimated:YES];
//        }];
        
//        [navigationController pushViewController:cropper animated:YES];
        
        
    } else { // 非编辑
        
        finishPickingBlock(selectedImage, selectedImage);
    }

}

- (void)didSelectImageFromCameraInfo:(NSDictionary *)info
{
    
    ALAssetsLibrary *library = [KKPAssetsLibraryManager sharedManager].assetsLibrary;
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    @weakify(library);
    [library writeImageToSavedPhotosAlbum:image.CGImage
                                 metadata:info[UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              @strongify(library);
                              [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                  
                                  [self addImageFromCameraAsset:asset];
                                  
                              } failureBlock:^(NSError *error) {
                              }];
                          }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat offsetY = scrollView.contentOffsetY;

    if (offsetY < -scrollView.contentInsetTop) {
        self.cameraView.y = -scrollView.contentOffsetY;
//        self.cameraView.height = -64 - offsetY + kCameraViewHeight;
    } else {
//        self.cameraView.height = kCameraViewHeight;
        self.cameraView.y = scrollView.contentInsetTop;
    }
    
    CGFloat backWhiteOffsetY = self.cameraView.height - offsetY;
    if (backWhiteOffsetY < 64) {
        self.backWhiteView.y = 64;
    } else {
        self.backWhiteView.y = backWhiteOffsetY;
    }
    
}

#pragma mark - KKPImageBrowserDelegate

- (BOOL)imageBrowser:(KKPImageBrowser *)imageBrowser didSelectAsset:(ALAsset *)asset
{
    return [self didActSelect:YES withAsset:asset];
}

- (void)imageBrowser:(KKPImageBrowser *)imageBrowser didDeselectAsset:(ALAsset *)asset
{
    [self didActSelect:NO withAsset:asset];
}

- (void)imageBrowserSendPressed:(KKPImageBrowser *)imageBrowser
{
    [self confirmAction];
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    switch (self.picker.mode) {
        case KKPImagePickerModeMultiple: {
            
            [self didSelectImageFromCameraInfo:info];
            [picker dismissViewControllerAnimated:YES completion:nil];
            
            break;
        }
            
        case KKPImagePickerModeSingle: {
            
            ALAssetsLibrary *library = [KKPAssetsLibraryManager sharedManager].assetsLibrary;
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            
            @weakify(library);
            [library writeImageToSavedPhotosAlbum:image.CGImage
                                         metadata:info[UIImagePickerControllerMediaMetadata]
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      @strongify(library);
                                      [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                          
                                          [self didSelectActionForSinglePickerWithImageAsset:asset
                                                                        navigationController:picker];
                                          
                                      } failureBlock:^(NSError *error) {
                                      }];
                                  }];

            
            
            break;
        }
            
        default: {
            break;
        }
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
