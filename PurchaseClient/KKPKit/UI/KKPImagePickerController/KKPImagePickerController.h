
#import "SCNavigationController.h"

typedef NS_ENUM(NSUInteger, KKPImagePickerMode) {
    KKPImagePickerModeMultiple,  ///< 多选
    KKPImagePickerModeSingle,    ///< 单选，如果可编辑，选择后进入编辑页面，若不可编辑，点击后直接返回
};

typedef void (^KKPImagePickerResultBlcok)(UIImage *originalImage, UIImage *editImage);

@class KKPImagePickerController;
@class ALAsset;

@protocol KKPImagePickerControllerDelegate <NSObject>

@optional

/**
 *  选择多张图片并点确定按钮后回调
 *
 *  @param picker 选图的 Picker
 *  @param assets 一个 ALAsset 的数组
 */
- (void)imagePickerController:(KKPImagePickerController *)picker didFinishPickingImageAssets:(NSArray *)assets;

/**
 *  选择单图并确认后的回调
 *
 *  @param picker      选图的 Picker
 *  @param resultBlock 所选图片的 ALAsset
 */

- (void)imagePickerController:(KKPImagePickerController *)picker didFinishPickingImageAsset:(ALAsset *)asset;

/**
 *  选择单图并确认后的回调
 *
 *  @param picker        选图的 Picker
 *  @param originalImage 原图
 *  @param editImage     编辑后的图片，如果未编辑，则返回原图
 */
- (void)imagePickerController:(KKPImagePickerController *)picker didFinishPickingOriginalImage:(UIImage *)originalImage editImage:(UIImage *)editImage;

/**
 *  取消选图
 *
 *  @param picker 选图的 VC
 */
- (void)imagePickerControllerDidCancel:(KKPImagePickerController *)picker;

@end

@interface KKPImagePickerController : SCNavigationController

@property (nonatomic, assign) id<KKPImagePickerControllerDelegate> imagePickerDelegate;

/**
 *  允许选择的最大图片数目
 */
@property (nonatomic, assign) NSInteger maxSelecteImageCount;

/**
 *  ImagePicker 模式，可单选（编辑\不编辑）;多选
 *  默认是 KKPImagePickerModeMultiple
 */
@property (nonatomic, assign) KKPImagePickerMode mode;

/**
 *  单选时有效，点击图片会进入图片编辑页面
 */
@property (nonatomic, assign) BOOL allowEditing;

/**
 *  单选且克编辑时有效。 默认是 0， 表示正方形选图； 指定 >0 的高度时按指定高度切图
 */
@property (nonatomic, assign) NSUInteger editingImageHeight;

#pragma mark - Class Methods

/**
 *  获取相册授权
 *
 *  @param completeBlock 获取结果（成功、失败）
 */
+ (void)requestForPhotoLibraryPermissionComplete:(void (^)())completeBlock;

/**
 *  获取相机授权
 *
 *  @param completeBlock 获取结果（成功、失败）
 */
+ (void)requestForCameraPermissionComplete:(void (^)())completeBlock;

@end
