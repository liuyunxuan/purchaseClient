

#import "KKPEmptyView.h"

#import "FrameAccessor.h"
#import "UIControl+BlocksKit.h"
#import "EXTScope.h"

#import "KKPColor.h"
#import "KKPButton.h"
#import "KKPFont.h"

static CGFloat const kSpace = 5;
static CGFloat const kEmptyViewWidth = 125;

#define kEmptyMaxWidth ([UIScreen mainScreen].bounds.size.width - 30)

@interface KKPEmptyView ()

@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyTitleLabel;
@property (nonatomic, strong) UILabel *emptySubtitleLabel;
@property (nonatomic, strong) KKPButton *emptyButton;

@end

@implementation KKPEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, kEmptyViewWidth, 0)];
    if (self) {
        _emptyImageType = KKPEmptyImageType4;
        
    }
    return self;
}

- (void)configureViews
{
    
    if (!self.emptyImageView) { // 空图片显示
        self.emptyImageView = [[UIImageView alloc] initWithImage:[self imageForCurrentEmptyImageType]];
        [self.emptyImageView sizeToFit];
        [self addSubview:self.emptyImageView];
    }
    self.emptyImageView.image = [self imageForCurrentEmptyImageType];
    
    if (!self.emptyTitleLabel && self.emptyTitleString.length > 0) { // 文字显示
        self.emptyTitleLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, kEmptyMaxWidth, 20}];
        self.emptyTitleLabel.numberOfLines  = 0;
        self.emptyTitleLabel.font = [UIFont systemFontOfSize:16];
        self.emptyTitleLabel.textColor = kColor.colorBlack;
        self.emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.emptyTitleLabel.centerX = self.width/2;
        [self addSubview:self.emptyTitleLabel];
    }
    self.emptyTitleLabel.text = self.emptyTitleString;
    CGFloat titleHeight = [self.emptyTitleString heightWithFont:self.emptyTitleLabel.font Width:kEmptyMaxWidth];
    self.emptyTitleLabel.height = titleHeight;
    
    if (!self.emptySubtitleLabel) { // 文字副标题位置
        self.emptySubtitleLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, kEmptyMaxWidth, 20}];
        self.emptySubtitleLabel.numberOfLines  = 0;
        self.emptySubtitleLabel.font = [UIFont systemFontOfSize:13];
        self.emptySubtitleLabel.textColor = kColor.colorGray;
        self.emptySubtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.emptySubtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.emptySubtitleLabel.centerX = self.width/2;
        [self addSubview:self.emptySubtitleLabel];
    }
    self.emptySubtitleLabel.text = self.emptySubtitleString;
    CGFloat subtitleHeight = [self.emptySubtitleString heightWithFont:self.emptySubtitleLabel.font Width:kEmptyMaxWidth];
    self.emptySubtitleLabel.height = subtitleHeight;
    
    if (!self.emptyButton && self.emptyButtonString.length > 0) { // 按钮
        self.emptyButton = [KKPButton buttonWithType:KKPButtonType4];
        self.emptyButton.height = 30;
        @weakify(self);
        [self.emptyButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.emptyButtonHandlerBlock) {
                self.emptyButtonHandlerBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.emptyButton];
    }
    
    if (self.emptyButtonString.length > 0) {
        self.emptyButton.hidden = NO;
    } else {
        self.emptyButton.hidden = YES;
    }
    self.emptyButton.title = self.emptyButtonString;
    [self.emptyButton sizeToFit];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offsetY = 0;
    self.emptyImageView.centerX = kEmptyViewWidth / 2;
    self.emptyImageView.y = offsetY;
    offsetY = self.emptyImageView.bottom;
    
    if (self.emptyTitleString.length > 0) {
        self.emptyTitleLabel.y = offsetY + kSpace;
        offsetY = self.emptyTitleLabel.bottom;
    }
    
    if (self.emptySubtitleString.length > 0) {
        self.emptySubtitleLabel.y = offsetY + kSpace;
        offsetY = self.emptySubtitleLabel.bottom;
    }
    
    if (self.emptyButtonString.length > 0) {
        self.emptyButton.y = offsetY + 15;
        self.emptyButton.centerX = kEmptyViewWidth/2;
        offsetY = self.emptyButton.bottom;
    }
    
    self.height = offsetY;
    
}

- (void)setEmptyTitleString:(NSString *)emptyTitleString
{
    _emptyTitleString = emptyTitleString;
    
    [self configureViews];
    [self setNeedsLayout];
}

- (void)setEmptyImageType:(KKPEmptyImageType)emptyImageType
{
    _emptyImageType = emptyImageType;
    
    [self configureViews];
    [self setNeedsLayout];
}

- (void)setEmptySubtitleString:(NSString *)emptySubtitleString
{
    _emptySubtitleString = emptySubtitleString;
    
    [self configureViews];
    [self setNeedsLayout];
}

- (void)setEmptyButtonString:(NSString *)emptyButtonString
{
    _emptyButtonString = emptyButtonString;
    
    [self configureViews];
    [self setNeedsLayout];
}

- (void)setEmptyButtonHandlerBlock:(void (^)())emptyButtonHandlerBlock
{
    _emptyButtonHandlerBlock = emptyButtonHandlerBlock;
}

- (UIImage *)imageForCurrentEmptyImageType
{
    UIImage *image;
    
    switch (self.emptyImageType) {
        case KKPEmptyImageType1: {
            image = [UIImage imageNamed:@"pic_搜索为空"];
            break;
        }
            
        case KKPEmptyImageType2: {
            image = [UIImage imageNamed:@"pic_内容为空"];
            break;
        }
            
        case KKPEmptyImageType3: {
            image = [UIImage imageNamed:@"pic_出错"];
            break;
        }
            
        default: {
            image = [UIImage imageNamed:@"pic_通用"];
            break;
        }
    }
    
    return image;
}

- (CGFloat)emptyViewHeight
{
    
    CGFloat height = kEmptyViewWidth;
    if (self.emptyTitleString) {
        height += (kSpace + self.emptyTitleLabel.height);
    }
    if (self.emptySubtitleString) {
        height += (kSpace + self.emptySubtitleLabel.height);
    }
    if (self.emptyButtonString) {
        height += (15 + 30);
    }
    
    return height;
}

@end
