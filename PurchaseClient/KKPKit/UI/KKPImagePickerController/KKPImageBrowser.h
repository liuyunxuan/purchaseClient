

#import "KKPBaseViewController.h"

typedef NS_ENUM(NSUInteger, KKPImageBrowserType) {
    KKPImageBrowserTypeDefault,  ///< 默认选择器，包含 navi bar 的选择/取消选择按钮，底部确定按钮。用于多图选择
    KKPImageBrowserTypeDelete,   ///< 图片浏览，包含 navi bar 删除按钮。用于查看并删除已选择的图片
};

@class ALAsset;
@protocol KKPImageBrowserDelegate;

@interface KKPImageBrowser : KKPBaseViewController

@property (nonatomic, assign) KKPImageBrowserType browserType;

// 数据源
@property (nonatomic, copy) NSArray *assetsArray;
@property (nonatomic, strong) NSArray *selectedAssetsArray;
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *  最大图片选择数，超过后会弹出失败提升
 */
@property (nonatomic, assign) NSInteger maxSelectedImageCount;

@property (nonatomic, assign) id <KKPImageBrowserDelegate> delegate;

@end

@protocol KKPImageBrowserDelegate <NSObject>

@optional;

/**
 *  选择图片 (KKPImageBrowserTypeDefault)
 *
 *  @param imageBrowser 图片浏览器
 *  @param asset        将要选择图片的 ALAsset
 *
 *  @return 成功选择返回 Yes， 未成功则返回 No （超过图片可选数量）
 */
- (BOOL)imageBrowser:(KKPImageBrowser *)imageBrowser didSelectAsset:(ALAsset *)asset;

/**
 *  取消选择图片 (KKPImageBrowserTypeDefault)
 *
 *  @param imageBrowser 图片浏览器
 *  @param asset        取消选择图片的 ALAsset
 */
- (void)imageBrowser:(KKPImageBrowser *)imageBrowser didDeselectAsset:(ALAsset *)asset;

/**
 *  点击底部发送按钮 (KKPImageBrowserTypeDefault)
 *
 *  @param imageBrowser 图片选择器
 */
- (void)imageBrowserSendPressed:(KKPImageBrowser *)imageBrowser;

/**
 *  删除图片 (KKPImageBrowserTypeDelete)
 *
 *  @param imageBrowser 图片选择器
 *  @param asset        将要删除图片的 ALAsset
 */
- (void)imageBrowser:(KKPImageBrowser *)imageBrowser didDeleteAsset:(ALAsset *)asset;

@end
