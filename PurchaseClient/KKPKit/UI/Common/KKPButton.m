
#import "KKPButton.h"

#import "FrameAccessor.h"

#import "KKPFont.h"
#import "KKPColor.h"
#import "KKPColor+Button.h"

static NSInteger kCornerRadiuis = 4;
static NSInteger kBorderWidth   = 1;

@interface KKPButton ()

@property (nonatomic, readwrite) KKPButtonType buttonType;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *backgroundView; // 避免使用 clipToBounds，方便加入小红点
@property (nonatomic, strong) UIImageView *ivActivity;    // 加载提示符

@property (nonatomic) UIColor *backgroundColorNormal;
@property (nonatomic) UIColor *backgroundColorHighlighted;
@property (nonatomic) UIColor *backgroundColorDisabled;
@property (nonatomic) UIColor *textColorNormal;
@property (nonatomic) UIColor *textColorHighlighted;
@property (nonatomic) UIColor *textColorDisabled;
@property (nonatomic) UIColor *borderColorNormal;
@property (nonatomic) UIColor *borderColorHighlighted;
@property (nonatomic) UIColor *borderColorDisabled;

@end

@implementation KKPButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.titleLabel.frame];
    backgroundView.layer.cornerRadius = kCornerRadiuis;
    backgroundView.clipsToBounds = YES;
    backgroundView.layer.borderWidth = kBorderWidth;
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    titleLabel.font = self.font;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    _boldFont = NO;
    _showBorder = YES;
    _font = kFont.f15;
    _buttonType = KKPButtonType1;
    
    self.highlighted = NO;
    self.accessibilityTraits = UIAccessibilityTraitButton;

    return self;
}

- (instancetype)init
{
    return [[KKPButton alloc] initWithFrame:CGRectZero];
}

+ (instancetype)buttonWithType:(KKPButtonType)buttonType
{
    KKPButton *button = [[KKPButton alloc] initWithFrame:CGRectZero];
    button.buttonType = buttonType;
    return button;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL isHighlighted = (self.state & (UIControlStateHighlighted|UIControlStateSelected)) > 0;
    
    if (self.state == UIControlStateDisabled) {
        self.enabled = NO;
    } else if (isHighlighted) {
        self.highlighted = YES;
    } else {
        self.highlighted = NO;
    }
    
    self.titleLabel.centerX = self.width / 2;
    self.titleLabel.centerY = self.height / 2;
    
    self.backgroundView.width = self.width;
    self.backgroundView.height = self.height;
}

#pragma mark - Public Setters

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel
{
    _accessibilityLabel = accessibilityLabel;
    
    self.titleLabel.accessibilityLabel = accessibilityLabel;
    self.titleLabel.accessibilityTraits = UIAccessibilityTraitButton;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = self.title;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    self.titleLabel.font = font;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}
/**
 *  根据 Button 类型设置各个样式
 *
 *  @param buttonType 按钮样式类型
 */
- (void)setButtonType:(KKPButtonType)buttonType
{
    _buttonType = buttonType;
    if (self.ivActivity) {
        [self.ivActivity removeFromSuperview];
    }
    switch (buttonType) {
        case KKPButtonType1: {
            self.backgroundColorNormal      = kColor.colorButtonOrange;
            self.backgroundColorHighlighted = kColor.colorButtonDarkOrange;
            self.backgroundColorDisabled    = RGB(0xffc59f, 1.0);
            self.textColorNormal            = kColor.colorWhite;
            self.textColorHighlighted       = kColor.colorWhite;
            self.textColorDisabled          = kColor.colorWhite;
            self.borderColorNormal          = kColor.colorButtonOrange;
            self.borderColorHighlighted     = kColor.colorButtonDarkOrange;
            self.borderColorDisabled        = RGB(0xffc59f, 1.0);
            break;
        }
        case KKPButtonType2: {
            self.backgroundColorNormal      = kColor.colorWhite;
            self.backgroundColorHighlighted = kColor.colorButtonLightOrange;
            self.backgroundColorDisabled    = kColor.colorWhite;
            self.textColorNormal            = kColor.colorOrange;
            self.textColorHighlighted       = kColor.colorOrange;
            self.textColorDisabled          = kColor.colorOrange;
            self.borderColorNormal          = self.showBorder ? kColor.colorButtonOrange : kColor.colorWhite;
            self.borderColorHighlighted     = self.showBorder ? kColor.colorButtonOrange : kColor.colorButtonLightOrange;
            self.borderColorDisabled        = self.showBorder ? kColor.colorBorderLightOrange : kColor.colorWhite;
            break;
        }
        case KKPButtonType3: {
            self.backgroundColorNormal      = kColor.colorButtonRed;
            self.backgroundColorHighlighted = kColor.colorButtonDarkRed;
            self.backgroundColorDisabled    = RGB(0xfcaaaa, 1.0);
            self.textColorNormal            = kColor.colorWhite;
            self.textColorHighlighted       = kColor.colorWhite;
            self.textColorDisabled          = kColor.colorWhite;
            self.borderColorNormal          = kColor.colorRed;
            self.borderColorHighlighted     = kColor.colorButtonDarkRed;
            self.borderColorDisabled        = RGB(0xfcaaaa, 1.0);
            break;
        }
        case KKPButtonType4: {
            self.backgroundColorNormal      = kColor.colorWhite;
            self.backgroundColorHighlighted = kColor.colorUltraLightGray;
            self.backgroundColorDisabled    = kColor.colorWhite;
            self.textColorNormal            = kColor.colorBlack;
            self.textColorHighlighted       = kColor.colorBlack;
            self.textColorDisabled          = kColor.colorBorderUltraLightGray;
            self.borderColorNormal          = self.showBorder ? kColor.colorBorderLightGray : kColor.colorWhite;
            self.borderColorHighlighted     = self.showBorder ? kColor.colorBorderGray : kColor.colorWhite;
            self.borderColorDisabled        = self.showBorder ? kColor.colorBorderUltraLightGray : kColor.colorWhite;
            break;
        }
        case KKPButtonType5: {
            [self buildButtonOfType5];
            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void)setShowBorder:(BOOL)showBorder
{
    _showBorder = showBorder;
    
    self.buttonType = self.buttonType;
    
}

- (void)setBoldFont:(BOOL)boldFont
{
    _boldFont = boldFont;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:self.titleLabel.font.pointSize];

}

- (void)sizeToFit
{
    [self.titleLabel sizeToFit];
    self.titleLabel.width += 30;
    self.titleLabel.height += 10;
    self.size = self.titleLabel.size;
}

#pragma mark - Private Methods

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.backgroundView.backgroundColor   = self.backgroundColorHighlighted;
        self.titleLabel.textColor             = self.textColorHighlighted;
        self.backgroundView.layer.borderColor = self.borderColorHighlighted.CGColor;
    } else {
        self.backgroundView.backgroundColor   = self.backgroundColorNormal;
        self.titleLabel.textColor             = self.textColorNormal;
        self.backgroundView.layer.borderColor = self.borderColorNormal.CGColor;
    }
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundView.backgroundColor   = self.backgroundColorHighlighted;
        self.titleLabel.textColor             = self.textColorHighlighted;
        self.backgroundView.layer.borderColor = self.borderColorHighlighted.CGColor;
    } else {
        self.backgroundView.backgroundColor   = self.backgroundColorNormal;
        self.titleLabel.textColor             = self.textColorNormal;
        self.backgroundView.layer.borderColor = self.borderColorNormal.CGColor;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        self.backgroundView.backgroundColor   = self.backgroundColorNormal;
        self.titleLabel.textColor             = self.textColorNormal;
        self.backgroundView.layer.borderColor = self.borderColorNormal.CGColor;
    } else {
        self.backgroundView.backgroundColor   = self.backgroundColorDisabled;
        self.titleLabel.textColor             = self.textColorDisabled;
        self.backgroundView.layer.borderColor = self.borderColorDisabled.CGColor;
    }

}

- (void)buildButtonOfType5
{
    self.backgroundColorNormal      = kColor.colorButtonOrange;
    self.backgroundColorHighlighted = kColor.colorButtonDarkOrange;
    self.backgroundColorDisabled    = RGB(0xffc59f, 1.0);
    self.textColorNormal            = kColor.colorWhite;
    self.textColorHighlighted       = kColor.colorWhite;
    self.textColorDisabled          = kColor.colorWhite;
    self.borderColorNormal          = kColor.colorButtonOrange;
    self.borderColorHighlighted     = kColor.colorButtonDarkOrange;
    self.borderColorDisabled        = RGB(0xffc59f, 1.0);
    
    // 加入加载提示符
    float fSize = 15.f;
    float fMargin = 6.f;
    
    self.ivActivity = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fSize, fSize)];
    
    // 计算文字的宽度
    NSString *sButtonText = self.titleLabel.text;
    UIFont *fontOfButton = self.titleLabel.font;
    CGSize textSize = [sButtonText sizeWithAttributes:@{NSFontAttributeName : fontOfButton}];
    
    // 根据文字宽度重新设置位置
    self.ivActivity.centerX = self.width/2-textSize.width/2-fMargin-self.ivActivity.width/2;
    self.ivActivity.centerY = self.height/2;
    
    // 旋转动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    rotationAnimation.duration = 0.8f;
    rotationAnimation.repeatCount = NSUIntegerMax;
    rotationAnimation.speed = 1.0f;
    rotationAnimation.removedOnCompletion = YES;
    
    self.ivActivity.image =[UIImage imageNamed:@"ico_waiting"];
    
    [self.ivActivity.layer addAnimation:rotationAnimation forKey:@"rotation"];
    
    [self addSubview:self.ivActivity];
}

#pragma mark - Class Methods

+ (CGFloat)widthForTitle:(NSString *)title
{
    return [title widthWithFont:kFont.f15] + 30;
}


@end
