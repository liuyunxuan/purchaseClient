
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KKPButtonType) {
    
    /*! 橙色背景、白色文字按钮 */
    KKPButtonType1,
    
    /*! 白色背景、橙色文字按钮 */
    KKPButtonType2,
    
    /*! 红色背景、白色文字按钮 */
    KKPButtonType3,
    
    /*! 白色背景、灰色文字按钮 */
    KKPButtonType4,
    
    /*! 橙色背景、白色文字按钮、加载提示符 */
    KKPButtonType5,
};

@interface KKPButton : UIControl

@property (nonatomic, copy)     NSString    *title;
@property (nonatomic, retain)   UIFont      *font;

@property (nonatomic, assign)   BOOL         showBorder;
@property (nonatomic, assign)   BOOL         boldFont;

@property (nonatomic, readonly) KKPButtonType buttonType;

@property(nonatomic, copy) NSString *accessibilityLabel;

+ (instancetype)buttonWithType:(KKPButtonType)buttonType;

- (void)sizeToFit;

- (void)setButtonType:(KKPButtonType)buttonType;

@end

@interface KKPButton (Hepler)

+ (CGFloat)widthForTitle:(NSString *)title;

@end