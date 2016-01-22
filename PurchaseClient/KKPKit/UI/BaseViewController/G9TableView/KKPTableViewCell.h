

#import "KKPBaseTableViewCell.h"

FOUNDATION_EXTERN NSString *const KKPTableViewCellStyleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellRightStyleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellTitleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellImageURLName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellSubtitleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellRightTitleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellButtonTitleName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellSwitchValueName;
FOUNDATION_EXTERN NSString *const KKPTableViewCellNeedsHighlightedName;

/**
 *  传入参数为空，返回为空的 Block
 */
FOUNDATION_EXTERN NSString *const KKPTableViewCellButtonActionBlockName;
/**
 *  传入参数为 Bool，表示是否选中， 返回为空的 Block
 */
FOUNDATION_EXTERN NSString *const KKPTableViewCellSwitchActionBlockName;

FOUNDATION_EXTERN NSString *const KKPIndexPathName;

typedef NS_ENUM(NSUInteger, KKPTableViewCellStyle) {
    KKPTableViewCellStyleDefault           = 0,       ///< Title Only
    KKPTableViewCellStyleImageSmall        = 1,       ///< 20*20 image
    KKPTableViewCellStyleImageNormal       = 1 << 1,  ///< 36*36 image
    KKPTableViewCellStyleImageLarge        = 1 << 2,  ///< 45*45 image
    KKPTableViewCellStyleSubtitle          = 1 << 3,  ///< 副标题
    KKPTableViewCellStyleSubtitleLineBreak = 1 << 4,  ///< 副标题自动换行
    KKPTableViewCellStyleButtonOnly        = 1 << 5,  ///< 只有按钮
};

typedef NS_ENUM(NSUInteger, KKPTableViewCellRightStyle) {
    KKPTableViewCellRightStyleNone       = 0,
    KKPTableViewCellRightStyleText       = 1,         ///< 右侧纯文字
    KKPTableViewCellRightStyleDisclosure = 1 << 1,    ///< 右侧小箭头
    KKPTableViewCellRightStyleButton     = 1 << 2,    ///< 右侧按钮
    KKPTableViewCellRightStyleSwitch     = 1 << 3,    ///< 右侧 Switch
};

@interface KKPTableViewCell : KKPBaseTableViewCell

/**
 *  设置 cell 右侧样式：无、纯文字、小箭头、纯文字＋小箭头、按钮
 * @helper 可以通过位运算同时设置两种样式，不过如果设置了按钮，会忽略其它样式设置
 */
@property (nonatomic, assign) KKPTableViewCellRightStyle rightStyle;
@property (nonatomic, assign) KKPTableViewCellStyle cellStyle;

/**
 *  用于 cell 显示的数据。 内容必须是以下为 key 的 dict， 对应
 *  的 key 不存在视为内容为空，不予显示。
 *  @classdesign Key（键值类型默认为 NSString）:
 *  @code  KKPTableViewCellTitle             标题
 *  KKPTableViewCellImageURL          标题右侧图片 URL
 *  KKPTableViewCellSubtitle          子标题
 *  KKPTableViewCellRightTitle        右侧文字
 *  KKPTableViewCellButtonTitle       右侧按钮文字
 *  KKPTableViewCellButtonActionBlock 按钮点击回调(Block)
 *  // 传入的 block 返回值和参数均为 void
 *  @endcode
 */
@property (nonatomic, strong) NSDictionary *dataDict;

/**
 *  创建 KKPTableViewCell
 *  @helper 支持对几种不同样式的位运算
 *   例如，有大图标显示、副标题支持换行的 cell 的 style 可表示为：
 *  @code KKPTableViewCellStyleImageLarge|KKPTableViewCellStyleSubtitleLineBreak @endcode
 *  @param style           cell 的样式
 *  @param reuseIdentifier 用于重用 cell 的字符串
 *
 *  @return 一个初始化之后的 KKPTableViewCell
 */
- (instancetype)initWithStyle:(KKPTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  通过数据计算 cell 的高度，变高的时候使用，一般情况直接设置定高
 *
 *  @param dict 包含数据的字典
 *
 *  @return 数据对应的 cell 高度
 */
+ (CGFloat)cellHeightForDict:(NSDictionary *)dict;

@end
