

#import "KKPColor+Button.h"

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

@implementation KKPColor (Button)

- (UIColor *)colorButtonRed {
    return kColor.colorRed;
}

- (UIColor *)colorButtonDarkRed {
    return RGB(0xe93e3e, 1.0);
}

- (UIColor *)colorButtonOrange {
    return RGB(0xff8c40, 1.0);
}

- (UIColor *)colorButtonDarkOrange {
    return RGB(0xf07524, 1.0);
}

- (UIColor *)colorButtonLightOrange {
    return RGB(0xffefe4, 1.0);
}

- (UIColor *)colorButtonLightGray {
    return RGB(0xc9c9c9, 1.0);
}

- (UIColor *)colorBorderGray {
    return RGB(0x979797, 1.0);
}

- (UIColor *)colorBorderLightGray {
    return RGB(0xbababa, 1.0);
}

- (UIColor *)colorBorderUltraLightGray {
    return RGB(0xd0d0d0, 1.0);
}

- (UIColor *)colorBorderLightOrange {
    return RGB(0xffc097, 1.0);
}

@end
