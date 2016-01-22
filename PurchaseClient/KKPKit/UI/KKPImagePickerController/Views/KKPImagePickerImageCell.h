
#import <UIKit/UIKit.h>

@class ALAsset;
@interface KKPImagePickerImageCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, copy) BOOL (^didSelectBlock)(BOOL isSelected);

- (void)setNumber:(NSInteger)number animated:(BOOL)animated;

@end


@interface KKPImagePickerCameraCell : UICollectionViewCell

@end

@interface KKPImagePickerImageOnlyCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;

@end
