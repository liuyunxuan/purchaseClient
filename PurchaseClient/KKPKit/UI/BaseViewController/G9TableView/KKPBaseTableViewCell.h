

#import <UIKit/UIKit.h>

@interface KKPBaseTableViewCell : UITableViewCell

/**
 *  用于显示在 cell 底部或者顶部的线，可以设置左间距、右间距、线条颜色
 */
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, assign, getter = isTopLineHidden) BOOL topLineHidden;
@property (nonatomic, copy  ) UIColor *topLineColor;
@property (nonatomic, assign) CGFloat topLineInsertLeft;
@property (nonatomic, assign) CGFloat topLineInsertRight;

@property (nonatomic, assign, getter = isBottomLineHideen) BOOL bottomLineHidden;
@property (nonatomic, copy  ) UIColor *bottomLineColor;
@property (nonatomic, assign) CGFloat bottomLineInsertLeft;
@property (nonatomic, assign) CGFloat bottomLineInsertRight;

/**
 *  是否需要 Cell 的选选中状态
 */
@property (nonatomic, assign) BOOL needsHighlighted;

@end
