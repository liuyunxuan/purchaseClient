

#import <UIKit/UIKit.h>

#import "KKPAlertCustomView.h"
#import "KKPAlertAction.h"

typedef NS_ENUM(NSInteger, KKPAlertControllerStyle) {
    
    /*! Action Sheet， 点击背景取消显示， 自动生成取消按钮， 支持 title、message、customView */
    KKPAlertControllerStyleActionSheet = 0,
    
    /*! Alert 点击按钮才会关闭，按钮超过 2 个换行显示， 支持 title、message、customView */
    KKPAlertControllerStyleAlert,
    
};

@interface KKPAlertController : UIViewController

/**
 *  设置 Alert 样式，可以是：Action Sheet、 Alert
 */
@property (nonatomic, readonly) KKPAlertControllerStyle preferredStyle;

/**
 *  设置取消actionSheet的title，默认不设置
 */
@property (nonatomic, copy) NSString * cancelTitle;

@property (nonatomic, copy) void (^didDismissBlock)();

/**
 *  返回加入操作数组
 */
@property (nonatomic, readonly) NSArray *actions;

/**
 *  创建一个 AlertController 可以是:
 *  @code KKPAlertControllerStyleActionSheet
 * KKPAlertControllerStyleAlert @endcode
 *
 *  @param title          显示的标题
 *  @param message        描述文字
 *  @param preferredStyle 显示样式
 *  @return AlertController 实例
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle;

/**
 *  创建自定义 View 的 AlertController
 *
 *  @param title          显示的标题
 *  @param message        描述文字
 *  @param preferredStyle 显示样式
 *  @param customView     自定义的 View， 该 View 最好继承自 KKPAlertCustomView， 通过它的 data 获取数据，
 *  可参考 KKPPasswordInputView 的实现。 该 View 会被无视 orgin 居中显示加入到 AlertController 中。
 *  Alert 下弹出键盘后会自动调整位置适应屏幕
 *  @return 该实例
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
                              customView:(KKPAlertCustomView *)customView;

/**
 *  创建一个 AlertController 可以是:
 *  @code KKPAlertControllerStyleActionSheet
 * KKPAlertControllerStyleAlert @endcode
 *
 *  @param title          显示的标题
 *  @param attributedMessage  描述文字的 NSAttributedString
 *  @param preferredStyle 显示样式
 *  @return AlertController 实例
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title
                       attributedMessage:(NSAttributedString *)attributedMessage
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle;

/**
 *  创建自定义 View 的 AlertController
 *
 *  @param title              显示的标题
 *  @param attributedMessage  描述文字的 NSAttributedString
 *  @param preferredStyle     显示样式
 *  @param customView         自定义的 View， 该 View 最好继承自 KKPAlertCustomView， 通过它的 data 获取数据，
 *  可参考 KKPPasswordInputView 的实现。 该 View 会被无视 orgin 居中显示加入到 AlertController 中。
 *  Alert 下弹出键盘后会自动调整位置适应屏幕
 *  @return 该实例
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title
                       attributedMessage:(NSAttributedString *)attributedMessage
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
                              customView:(KKPAlertCustomView *)customView;

/**
 *  添加 alert 按钮
 *
 *  @param action KKPAlertAction
 */
- (void)addAction:(KKPAlertAction *)action;

/**
 *  添加一组 alert
 *
 *  @param actions 一个 KKPAlertAction 的数组
 */
- (void)addActions:(NSArray *)actions;

/**
 *  直接添加操作按钮
 *
 *  @param title   按钮文字
 *  @param style   按钮样式
 *  @param handler 按钮操作
 *
 *  @return 添加的按钮对应的 KKPAlertAction
 */
- (KKPAlertAction *)addActionWithTitle:(NSString *)title
                                style:(KKPAlertActionStyle)style
                              handler:(void (^)(KKPAlertAction *action))handler;

- (void)setCancelTitle:(NSString *)title;

///**
// *  显示 AlertController
// *
// *  @param viewController AlertController 将在该 view controller 上 present 显示。
// */
//- (void)showAlertInViewController:(UIViewController *)viewController;

/**
 *  显示 Alert
 */
- (void)show;

- (void)dismiss;

/**
 *  在 view 中显示 Alert
 *
 *  @param view 将要显示在的 View
 */
- (void)showInView:(UIView *)view;


//- (void)dismissAlertCompletion:(void (^)())complectionBlock;

+ (CGFloat)containerWidth;



@end
