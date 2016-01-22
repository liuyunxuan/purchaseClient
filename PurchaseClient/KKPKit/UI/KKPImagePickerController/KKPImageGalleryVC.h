

#import "KKPBaseViewController.h"

@class KKPImageAssetsGroup;
@class KKPImagePickerController;
@interface KKPImageGalleryVC : KKPBaseViewController

@property (nonatomic, strong) KKPImageAssetsGroup *assetsGroup;
@property (nonatomic, weak) KKPImagePickerController *picker;

@end
