
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KKPAlertActionStyle) {
    KKPAlertActionStyleNormal,
    KKPAlertActionStyleCancel,
    KKPAlertActionStyleDefault, 
    KKPAlertActionStyleDestructive,
    KKPAlertActionStyleDefaultWithSelection,
};

@interface KKPAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title
                          style:(KKPAlertActionStyle)style
                        handler:(void (^)(KKPAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) KKPAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

