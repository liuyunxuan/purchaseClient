
#import "KKPAlertAction.h"

@interface KKPAlertAction ()

@property (nonatomic, copy) void (^handlerBlock)(KKPAlertAction *action);

@end

@implementation KKPAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(KKPAlertActionStyle)style handler:(void (^)(KKPAlertAction *action))handler {
    return [[KKPAlertAction alloc] initWithTitle:title style:style handler:handler];

}

- (instancetype)initWithTitle:(NSString *)title style:(KKPAlertActionStyle)style handler:(void (^)(KKPAlertAction *action))handler {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _title = title;
    _style = style;
    _handlerBlock = handler;
    
    return self;

}

@end
