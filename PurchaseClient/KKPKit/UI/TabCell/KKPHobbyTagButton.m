//
//  KKPHobbyTagButton.m
//  Account
//
//  Created by 刘特风 on 15/8/31.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//

#import "KKPHobbyTagButton.h"
#import "Masonry.h"
#import "FrameAccessor.h"

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]
static const CGFloat DeleteButtonWidth = 15;
static const CGFloat DeleteButtonHeight = 15;

static const CGFloat ButtonCornerRadius = 3;

static const CGFloat KKPHobbyTagButtonLeftSpace = 10;
//static const CGFloat KKPHobbyTagButtonRightSpace = 10;



@interface KKPHobbyTagButton ()


@property (nonatomic, strong) UIImageView *delete;
@property (nonatomic, strong) NSMutableDictionary *imageCacheTag;
@property (nonatomic, strong) NSMutableDictionary *imageCacheHightLight;

@end

@implementation KKPHobbyTagButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    return  [self initWithFrame:CGRectZero];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self makeBackGroundImageRound];
    [self makeHeightLightImageRound];
}

- (void)configUI
{
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self setTitleColor:RGB(0x333333, 1) forState:UIControlStateNormal];
    self.heightLightColor = RGB(0xd2d2d8, 1);
    self.boardColor = RGB(0xececf1, 1);
}

- (void)layoutBaseOnSelfType
{
    [self.titleLabel sizeToFit];
    switch (self.type) {
        case KKPHobbyTagButtonTypeAdd:
        {
            self.delete.x = KKPHobbyTagButtonLeftSpace;
            self.delete.centerY = CGRectGetMidY(self.bounds);
            self.titleLabel.x = self.delete.right + 4;
            self.titleLabel.centerY = CGRectGetMidY(self.bounds);
            break;
        }
        case KKPHobbyTagButtonTypeDelete:
        {
            self.titleLabel.x = KKPHobbyTagButtonLeftSpace;
            self.titleLabel.centerY = CGRectGetMidY(self.bounds);
            self.delete.x = self.titleLabel.right + 4;
            self.delete.centerY = CGRectGetMidY(self.bounds);
            break;
        }
        case KKPHobbyTagButtonTypeNormal:
        {
            self.titleLabel.centerX = CGRectGetMidX(self.bounds);
            self.titleLabel.centerY = CGRectGetMidY(self.bounds);
            break;
        }
        default:
            break;
    }

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBaseOnSelfType];
    
}

#pragma mark - getter & setter

- (void)setHeightLightColor:(UIColor *)heightLightColor
{
    if (!CGColorEqualToColor(heightLightColor.CGColor, _heightLightColor.CGColor)) {
        self.imageCacheHightLight = [[NSMutableDictionary alloc] init];
    }
    _heightLightColor = heightLightColor;

    [self makeHeightLightImageRound];
    [self setNeedsDisplay];
}

- (void)setType:(KKPHobbyTagButtonType)type
{
    _type = type;
    switch (_type) {
        case KKPHobbyTagButtonTypeNormal:
        {
            self.delete.hidden = YES;
            break;
        }
        case KKPHobbyTagButtonTypeDelete:
        {
            self.delete.hidden = NO;
            self.delete.image = [UIImage imageNamed:@"ico_delete_tag"];
            break;
        }
        case KKPHobbyTagButtonTypeAdd:
        {
            self.delete.hidden = NO;
            self.delete.image = [UIImage imageNamed:@"ico_add_tag"];
            break;
        }
        default:
            break;
    }
    [self layoutBaseOnSelfType];
    
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        if (self.selected) {
            self.alpha = .3;
        }else{
            self.alpha = 1;
        }
    }else {
        self.alpha = 0.3;
    }
}


- (void)setBoardColor:(UIColor *)boardColor
{
    if (!CGColorEqualToColor(boardColor.CGColor, _boardColor.CGColor)) {
        self.imageCacheTag = [[NSMutableDictionary alloc] init];
    }
    _boardColor = boardColor;
    [self makeBackGroundImageRound];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.alpha = 0.5;
    }else {
        self.alpha = 1;
    }
}

- (NSMutableDictionary *)imageCacheTag
{
    if (!_imageCacheTag) {
        _imageCacheTag = [[NSMutableDictionary alloc] init];
    }
    return _imageCacheTag;
}

- (NSMutableDictionary *)imageCacheHightLight
{
    if (!_imageCacheHightLight) {
        _imageCacheHightLight = [[NSMutableDictionary alloc] init];
    }
    return _imageCacheHightLight;
}

- (UIImageView *)delete
{
    if (!_delete) {
        _delete = [[UIImageView alloc] init];
        [_delete setImage:[UIImage imageNamed:@"ico_delete_tag"]];
        _delete.width = DeleteButtonWidth;
        _delete.height = DeleteButtonHeight;
        _delete.hidden = YES;
        [self addSubview:_delete];
    }
    return _delete;
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    return [KKPHobbyTagButton createImageWithColor:color withSize:(CGSize){1.f, 1.f}];
}

+ (UIImage *)createImageWithColor:(UIColor *)color withSize:(CGSize)size
{
    if (!color) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width * 2, size.height * 2);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


+ (UIImage *)roundedImage:(UIImage *)originImage
{
    if (CGSizeEqualToSize(originImage.size, CGSizeZero)) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(originImage.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, originImage.size.width, originImage.size.height);
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:ButtonCornerRadius * 2];
    CGPathRef path = rounded.CGPath;
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    
    CGContextClip(context);
    CGContextDrawImage(context, rect, originImage.CGImage);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (void )roundedImage:(UIColor *)color withSize:(CGSize)size withComplete:(void(^)(UIImage *))complete
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return ;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsBeginImageContext((CGSize){size.width * 2, size.height * 2});
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);
        CGRect rect = CGRectMake(0, 0, size.width * 2, size.height * 2);
        UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:ButtonCornerRadius * 2];
        CGPathRef path = rounded.CGPath;
        CGContextAddPath(context, path);
        CGContextClosePath(context);
        
        CGContextClip(context);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(img);
        });
    });
    
    
//    return img;
}

+ (UIImage *)roundedImage:(UIColor *)color withSize:(CGSize)size
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    UIGraphicsBeginImageContext((CGSize){size.width * 2, size.height * 2});
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGRect rect = CGRectMake(0, 0, size.width * 2, size.height * 2);
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:ButtonCornerRadius * 2];
    CGPathRef path = rounded.CGPath;
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return img;
}

- (void)makeBackGroundImageRound
{

//    [KKPHobbyTagButton roundedImage:self.boardColor withSize:self.bounds.size withComplete:^(UIImage *image) {
//        [self setBackgroundImage:image forState:UIControlStateNormal];
//    }];
    UIImage *colorImg = self.imageCacheTag[[NSValue valueWithCGSize:self.bounds.size]];
    if (!colorImg) {
        colorImg = [KKPHobbyTagButton roundedImage:self.boardColor withSize:self.bounds.size];
        if (colorImg) {
            self.imageCacheTag[[NSValue valueWithCGSize:self.bounds.size]] = colorImg;
        }
    }
    
    [self setBackgroundImage:colorImg
                     forState:UIControlStateNormal];
}

- (void)makeHeightLightImageRound
{

//    [KKPHobbyTagButton roundedImage:self.heightLightColor withSize:self.bounds.size withComplete:^(UIImage *image) {
//        [self setBackgroundImage:image forState:UIControlStateHighlighted];
//    }];
    UIImage *colorImg = self.imageCacheHightLight[[NSValue valueWithCGSize:self.bounds.size]];
    if (!colorImg) {
        colorImg = [KKPHobbyTagButton roundedImage:self.heightLightColor withSize:self.bounds.size];
        if (colorImg) {
            self.imageCacheHightLight[[NSValue valueWithCGSize:self.bounds.size]] = colorImg;
        }
    }

    [self setBackgroundImage:colorImg
                    forState:UIControlStateHighlighted];
}

@end
