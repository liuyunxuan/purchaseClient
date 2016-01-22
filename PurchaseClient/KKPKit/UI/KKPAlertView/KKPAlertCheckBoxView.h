
#import <UIKit/UIKit.h>

@interface KKPAlertCheckBoxView : UIView

@property (nonatomic, copy) NSString *checkMessage;
@property (nonatomic, assign) BOOL checked;

@property (nonatomic, copy) void (^chekStatusChangeBlock)(BOOL isChecked);

@end
