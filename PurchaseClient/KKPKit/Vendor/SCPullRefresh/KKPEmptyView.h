

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KKPEmptyImageType) {
    
    /*! 搜索为空 */
    KKPEmptyImageType1,
    
    /*! 内容为空 */
    KKPEmptyImageType2,

    /*! 出错 */
    KKPEmptyImageType3,

    /*! 通用 */
    KKPEmptyImageType4,
};

@interface KKPEmptyView : UIView

@property (nonatomic, copy) NSString *emptyTitleString;
@property (nonatomic, copy) NSString *emptySubtitleString;
@property (nonatomic, copy) NSString *emptyButtonString;

@property (nonatomic, assign) KKPEmptyImageType emptyImageType;

@property (nonatomic, copy) void (^emptyButtonHandlerBlock)();

@property (nonatomic, assign) CGFloat emptyViewHeight;

@end
