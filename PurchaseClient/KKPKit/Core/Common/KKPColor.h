

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kColor [KKPColor sharedColor]

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

#define kLineColorBlackDark  RGB(0xdbdbdb, 1.0)
#define kLineColorBlackLight RGB(0xebebeb, 1.0)

@interface KKPColor : NSObject

+ (instancetype)sharedColor;

/**
 *  c1 - black
 */
@property (nonatomic, readonly) UIColor *colorBlack;

/**
 *  c2 - darkGray
 */
@property (nonatomic, readonly) UIColor *colorDarkGray;

/**
 *  c3 - gray
 */
@property (nonatomic, readonly) UIColor *colorGray;

/**
 *  c4 - lightGray
 */
@property (nonatomic, readonly) UIColor *colorLightGray;

/**
 *  c5 - ultraLightGray
 */
@property (nonatomic, readonly) UIColor *colorUltraLightGray;

/**
 *  cb - blue
 */
@property (nonatomic, readonly) UIColor *colorBlue;

/**
 *  cg - green
 */
@property (nonatomic, readonly) UIColor *colorGreen;

/**
 *  cr - red
 */
@property (nonatomic, readonly) UIColor *colorRed;

/**
 *  cw - white
 */
@property (nonatomic, readonly) UIColor *colorWhite;

/**
 *  co - orange
 */
@property (nonatomic, readonly) UIColor *colorOrange;

/**
 *  VC background color 0xf3f3f3
 */
@property (nonatomic, readonly) UIColor *colorBackgroundGray;

@property (nonatomic, readonly) UIColor *colorNavigationBarGray;

@property (nonatomic, readonly) UIColor *colorYellow;
@end
