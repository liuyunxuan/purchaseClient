

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kFont [KKPFont sharedFont]

@interface KKPFont : NSObject

+ (instancetype)sharedFont;

- (UIFont *)f10; // 中文高 10pt, 英文 12pt
- (UIFont *)f11; // 中文高 11pt, 英文 13pt
- (UIFont *)f12; // 中文高 12pt, 英文 14pt
- (UIFont *)f13; // 中文高 13pt, 英文 15pt
- (UIFont *)f14; // 中文高 14pt, 英文 16pt
- (UIFont *)f15; // 中文高 15pt, 英文 17pt
- (UIFont *)f16; // 中文高 16pt, 英文 18pt
- (UIFont *)f17; // 中文高 17pt, 英文 19pt
- (UIFont *)f18; // 中文高 18pt, 英文 20pt

@end


@interface NSString (KKPFont)

- (CGFloat)heightWithFont:(UIFont *)font Width:(CGFloat)width;

- (CGFloat)widthWithFont:(UIFont *)font;

- (NSMutableAttributedString *)attributedStringWithLineSpace:(CGFloat)space;

@end

@interface NSAttributedString (KKPFont)

- (CGFloat)heightWithWidth:(CGFloat)width;

@end

@interface NSMutableAttributedString (KKPFont)

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpace;

@end
