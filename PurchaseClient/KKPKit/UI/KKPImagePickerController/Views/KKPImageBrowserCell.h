

#import <UIKit/UIKit.h>

@class ALAsset;
@protocol KKPImageBrowserCellDelegate;
@interface KKPImageBrowserCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) id<KKPImageBrowserCellDelegate> delegate;

@end

@protocol KKPImageBrowserCellDelegate <NSObject>

@optional;
- (void)imageSingleTapDetected;

@end