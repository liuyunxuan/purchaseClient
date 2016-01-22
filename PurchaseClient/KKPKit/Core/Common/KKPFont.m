

#import "KKPFont.h"

@implementation KKPFont

+ (instancetype)sharedFont
{
    static KKPFont *_sharedFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFont = [[KKPFont alloc] init];
    });
    
    return _sharedFont;
}

- (UIFont *)f10
{
    return [UIFont systemFontOfSize:10];
}

- (UIFont *)f11
{
    return [UIFont systemFontOfSize:11];
}

- (UIFont *)f12
{
    return [UIFont systemFontOfSize:12];
}

- (UIFont *)f13
{
    return [UIFont systemFontOfSize:13];
}

- (UIFont *)f14
{
    return [UIFont systemFontOfSize:14];
}

- (UIFont *)f15
{
    return [UIFont systemFontOfSize:15];
}

- (UIFont *)f16
{
    return [UIFont systemFontOfSize:16];
}

- (UIFont *)f17
{
    return [UIFont systemFontOfSize:17];
}

- (UIFont *)f18
{
    return [UIFont systemFontOfSize:18];
}

@end


@implementation NSString (KKPFont)

- (CGFloat)heightWithFont:(UIFont *)font Width:(CGFloat)width
{
    
    if (self.length == 0) {
        return 0;
    }
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 };
    CGRect expectedLabelRect = [self boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                  options:
                                NSStringDrawingUsesLineFragmentOrigin|
                                NSLineBreakByWordWrapping|
                                NSStringDrawingUsesFontLeading
                                               attributes:attributes
                                                  context:nil];
    return CGRectGetHeight(expectedLabelRect);
    
}

- (CGFloat)widthWithFont:(UIFont *)font
{
    if (self.length == 0) {
        return 0;
    }
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 };
    CGRect expectedLabelRect = [self boundingRectWithSize:(CGSize){CGFLOAT_MAX, 50}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return CGRectGetWidth(expectedLabelRect);
}


- (NSMutableAttributedString *)attributedStringWithLineSpace:(CGFloat)space
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = space;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self
                                                                                         attributes:@{
                                                                                                      NSParagraphStyleAttributeName: style
                                                                                                      }];
    
    return attributedString;
}

@end

@implementation NSAttributedString (KKPFont)

- (CGFloat)heightWithWidth:(CGFloat)width
{
    
    if (self.length == 0) {
        return 0;
    }
    
    CGRect expectedLabelRect = [self boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil];
    return CGRectGetHeight(expectedLabelRect);
}

@end

@implementation NSMutableAttributedString (KKPFont)

@dynamic font;
@dynamic textColor;
@dynamic lineSpace;

- (UIFont *)font
{
    return nil;
}

- (void)setFont:(UIFont *)font
{
    [self addAttribute:NSFontAttributeName value:font range:(NSRange){0, self.length}];
}

- (UIColor *)textColor
{
    return nil;
}

- (void)setTextColor:(UIColor *)textColor
{
    [self addAttribute:NSForegroundColorAttributeName value:textColor range:(NSRange){0, self.length}];
}

- (CGFloat)lineSpace
{
    return 0;
}

- (void)setLineSpace:(CGFloat)lineSpace
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [self addAttribute:NSParagraphStyleAttributeName value:style range:(NSRange){0, self.length}];
}

@end