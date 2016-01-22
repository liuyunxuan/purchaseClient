

#import "KKPImagePickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+SCNavigation.h"
#import "SCBarButtonItem.h"
#import "EXTScope.h"
#import "KKPAssetsLibraryManager.h"

#import "KKPImageGalleryVC.h"
#import "KKPImageAlbumListVC.h"
#import "KKPImagePickerNoAccessVC.h"

#import "KKPImagePickerModel.h"

static NSString * const kPreviousAlbum = @"KKPImagePickerPreviousAlbum";


@interface KKPImagePickerController ()

@property (nonatomic, strong) NSArray *albumList;

@end

@implementation KKPImagePickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    _maxSelecteImageCount = 0;
    _mode = KKPImagePickerModeMultiple;
    _allowEditing = NO;
    _editingImageHeight = 0;

    return self;

}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAlbumList];
    
}

#pragma mark - Setter

- (void)setAlbumList:(NSArray *)albumList {
    _albumList = albumList;
    
    KKPImageAssetsGroup *willShowGroup = albumList.firstObject;
    
    // Show library
    for (KKPImageAssetsGroup *group in albumList) {
        if (group.assetsGroupType == ALAssetsGroupSavedPhotos) {
            willShowGroup = group;
            break;
        }
    }
    
    // Show previous closed album
    NSString *previousGroupId = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousAlbum];
    if (previousGroupId) {
        for (KKPImageAssetsGroup *group in albumList) {
            if ([previousGroupId isEqualToString:group.assetsGroupId]) {
                willShowGroup = group;
                break;
            }
        }
    }
    
    // Show first album
    [self showGalleryViewAssetsGroup:willShowGroup];
}

#pragma mark - Private Methods

- (void)showGalleryViewAssetsGroup:(KKPImageAssetsGroup *)assetsGroup {
    
    KKPImageAlbumListVC *albumListVC = [[KKPImageAlbumListVC alloc] init];
    albumListVC.albumList = self.albumList;

    
    KKPImageGalleryVC *imageGalleryVC = [[KKPImageGalleryVC alloc] init];
    imageGalleryVC.picker = self;
    imageGalleryVC.assetsGroup = assetsGroup;
    
    
    [self setViewControllers:@[albumListVC, imageGalleryVC]];
    [albumListVC createNavigationBar];
    [imageGalleryVC createNavigationBar];

    @weakify(self);
    albumListVC.sc_navigationItem.leftBarButtonItem = nil;
    albumListVC.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithTitle:@"取消" style:0 handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
                [self.imagePickerDelegate imagePickerControllerDidCancel:self];
            }
            
        }];
    }];
    albumListVC.sc_navigationItem.title = @"选择图片";

    imageGalleryVC.sc_navigationItem.title = assetsGroup.assetsGroupName;
    imageGalleryVC.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithTitle:@"取消" style:0 handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
                [self.imagePickerDelegate imagePickerControllerDidCancel:self];
            }
            
        }];
    }];
}

- (void)showNoAccessVC {
    
    KKPImagePickerNoAccessVC *noAccessVC = [[KKPImagePickerNoAccessVC alloc] init];

    [self setViewControllers:@[noAccessVC]];
    [noAccessVC createNavigationBar];

    @weakify(self);
    noAccessVC.sc_navigationItem.leftBarButtonItem = nil;
    noAccessVC.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithTitle:@"取消" style:0 handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
                [self.imagePickerDelegate imagePickerControllerDidCancel:self];
            }
            
        }];
    }];

}

- (void)getAlbumList {
    
    NSMutableArray *albumList = [NSMutableArray new];
    
    [[KKPAssetsLibraryManager sharedManager].assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary|ALAssetsGroupAlbum|ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop)
     {
         if (assetsGroup == nil && *stop ==  NO) {
             *stop = YES;
             self.albumList = albumList;
             return;
         }
         
         KKPImageAssetsGroup *group = [[KKPImageAssetsGroup alloc] initWithAssetsGroup:assetsGroup];
         if (group.assetsGroupNumber > 0) {
             [albumList addObject:group];
         }
     }
                               failureBlock:^(NSError *error)
     {
         
         [self showNoAccessVC];
         
     }];

}

#pragma mark - Class Methods

+ (void)requestForPhotoLibraryPermissionComplete:(void (^)())completeBlock {
    
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    
    if (authStatus == ALAuthorizationStatusNotDetermined) {
        
        [[KKPAssetsLibraryManager sharedManager].assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                            usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
                                                                                if (*stop) {
                                                                                    if (completeBlock) {
                                                                                        completeBlock();
                                                                                    };
                                                                                } else {
                                                                                    *stop = YES;
                                                                                }
                                                                            }
                                                                          failureBlock:^(NSError *error) {
                                                                              if (completeBlock) {
                                                                                  completeBlock();
                                                                              };
                                                                          }];
        
    } else {
        if (completeBlock) {
            completeBlock();
        };
    }

    
}

+ (void)requestForCameraPermissionComplete:(void (^)())completeBlock
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock();
            });
        }
    }];
}


@end
