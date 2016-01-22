

#import "KKPColor.h"

@interface KKPColor ()

@property (nonatomic, readonly) UIColor *c1; // black
@property (nonatomic, readonly) UIColor *c2; // darkGray
@property (nonatomic, readonly) UIColor *c3; // gray
@property (nonatomic, readonly) UIColor *c4; // lightGray
@property (nonatomic, readonly) UIColor *c5; // ultraLightGray
@property (nonatomic, readonly) UIColor *cb; // blue
@property (nonatomic, readonly) UIColor *cg; // green
@property (nonatomic, readonly) UIColor *cr; // red
@property (nonatomic, readonly) UIColor *cw; // white
@property (nonatomic, readonly) UIColor *co; // orange

@end

@implementation KKPColor

+ (instancetype)sharedColor {
    static KKPColor *_sharedColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedColor = [[KKPColor alloc] init];
    });
    
    return _sharedColor;
}

- (UIColor *)c1 {
    return RGB(0x333333, 1.0);
}

- (UIColor *)c2 {
    return RGB(0x666666, 1.0);
}

- (UIColor *)c3 {
    return RGB(0x999999, 1.0);
}

- (UIColor *)c4 {
    return RGB(0xdddddd, 1.0);
}

- (UIColor *)c5 {
    return RGB(0xededed, 1.0);
}

- (UIColor *)cb {
    return RGB(0x0088f1, 1.0);
}

- (UIColor *)cg {
    return RGB(0x60c926, 1.0);
}

- (UIColor *)cr {
    return RGB(0xf95656, 1.0);
}


- (UIColor *)cw {
    return RGB(0xffffff, 1.0);
}

- (UIColor *)co {
    return RGB(0xf67b29, 1.0);
}

- (UIColor *)colorBlack {
    return self.c1;
}

- (UIColor *)colorDarkGray {
    return self.c2;
}

- (UIColor *)colorGray {
    return self.c3;
}

- (UIColor *)colorLightGray {
    return self.c4;
}

- (UIColor *)colorUltraLightGray {
    return self.c5;
}

- (UIColor *)colorBlue {
    return self.cb;
}

- (UIColor *)colorGreen {
    return self.cg;
}

- (UIColor *)colorRed {
    return self.cr;
}

- (UIColor *)colorWhite {
    return self.cw;
}

- (UIColor *)colorOrange {
    return self.co;
}

- (UIColor *)colorBackgroundGray {
    return RGB(0xf3f3f3, 1.0);
}

- (UIColor *)colorNavigationBarGray {
    return RGB(0xececec, .98);
}

- (UIColor *)colorYellow {
    return RGB(0xffd014, 1.0);
}
@end
