

#import "KKPTableViewCell.h"

#import "FrameAccessor.h"
#import "UIImageView+WebCache.h"
#import "UIControl+BlocksKit.h"
#import "EXTScope.h"

#import "KKPButton.h"
#import "KKPFont.h"
#import "KKPColor.h"

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

NSString *const KKPTableViewCellStyleName             = @"style";
NSString *const KKPTableViewCellRightStyleName        = @"rightStyle";
NSString *const KKPTableViewCellTitleName             = @"title";
NSString *const KKPTableViewCellImageURLName          = @"url";
NSString *const KKPTableViewCellSubtitleName          = @"subtitle";
NSString *const KKPTableViewCellRightTitleName        = @"rightTitle";
NSString *const KKPTableViewCellButtonTitleName       = @"buttonTitle";
NSString *const KKPTableViewCellButtonActionBlockName = @"buttonBlock";
NSString *const KKPTableViewCellSwitchValueName       = @"switchValue";
NSString *const KKPTableViewCellSwitchActionBlockName = @"switchBlock";
NSString *const KKPTableViewCellNeedsHighlightedName  = @"highlighted";

NSString *const KKPIndexPathName                      = @"indexPath";

static NSInteger const kAvatarCornerRadius    = 3;
static NSInteger const kAvatarHeightSmall     = 20;
static NSInteger const kAvatarHeightNormal    = 36;
static NSInteger const kAvatarHeightLarge     = 45;

static NSInteger const kButtonHeight          = 30;

static NSInteger const kTitleFontSize         = 16;
static NSInteger const kTitleFontWithoutImage = 14;
static NSInteger const kSubtitleFontSize      = 13;
static NSInteger const kRightLabelFontSize    = 13;

@interface KKPTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIImageView *rightArrowImageView;
@property (nonatomic, strong) KKPButton *rightButton;
@property (nonatomic, strong) UISwitch *rightSwitch;

@property (nonatomic, copy) void (^buttonHandlerBlock)();
@property (nonatomic, copy) void (^switchHandlerBlock)(BOOL);

@end

@implementation KKPTableViewCell

- (instancetype)initWithStyle:(KKPTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _cellStyle = style;
    
    return self;

}



#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarImageView.centerY = self.height/2;
    self.avatarImageView.x = 10;
    self.rightArrowImageView.centerY = self.height/2;

}

#pragma mark - _configureViews

- (void)_configureViews
{
    
    [self _configureAvatarImageView];
    [self _configureTitleLabel];
    [self _configureRightViews];

}

- (void)_configureAvatarImageView
{
    
    KKPTableViewCellStyle avatarStyle = (
                                        KKPTableViewCellStyleImageNormal|
                                        KKPTableViewCellStyleImageLarge|
                                        KKPTableViewCellStyleImageSmall);
    if (checkCellStyle(self.cellStyle, avatarStyle)) {
        if (self.avatarImageView == nil) {
            self.avatarImageView = [[UIImageView alloc] init];
            self.avatarImageView.clipsToBounds = YES;
            [self.contentView addSubview:self.avatarImageView];
        }
        self.avatarImageView.hidden = NO;
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.avatarImageView.layer.cornerRadius = kAvatarCornerRadius;
        
        if (checkCellStyle(self.cellStyle, KKPTableViewCellStyleImageLarge)) {
            self.avatarImageView.size = (CGSize){kAvatarHeightLarge, kAvatarHeightLarge};
        }
        if (checkCellStyle(self.cellStyle, KKPTableViewCellStyleImageNormal)) {
            self.avatarImageView.size = (CGSize){kAvatarHeightNormal, kAvatarHeightNormal};
        }
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)_configureTitleLabel
{
    
    if (checkCellStyle(self.cellStyle, KKPTableViewCellStyleButtonOnly)) {
        self.titleLabel.hidden = YES;
        self.subtitleLabel.hidden = YES;
        if (self.rightButton == nil) {
            self.rightButton = [KKPButton buttonWithType:KKPButtonType1];
            [self.contentView addSubview:self.rightButton];
            @weakify(self);
            [self.rightButton bk_addEventHandler:^(id sender) {
                @strongify(self);
                if (self.buttonHandlerBlock) {
                    self.buttonHandlerBlock();
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }
        self.rightButton.hidden = NO;
        return;
    }
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.titleLabel];
    }
    self.titleLabel.hidden = NO;
    self.titleLabel.font = kFont.f16;
    self.titleLabel.textColor = kColor.colorBlack;
    
    KKPTableViewCellStyle subtitleStyle = KKPTableViewCellStyleSubtitle|KKPTableViewCellStyleSubtitleLineBreak;
    if (checkCellStyle(self.cellStyle, subtitleStyle)) {
        if (self.subtitleLabel == nil) {
            self.subtitleLabel = [[UILabel alloc] init];
            self.subtitleLabel.numberOfLines = 0;
            self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.contentView addSubview:self.subtitleLabel];
        }
        self.subtitleLabel.hidden = NO;
        self.subtitleLabel.font = kFont.f13;
        self.subtitleLabel.textColor = kColor.colorGray;
        
        if (checkCellStyle(self.cellStyle, KKPTableViewCellStyleSubtitle)) {
            self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.subtitleLabel.numberOfLines = 1;
        }
        if (checkCellStyle(self.cellStyle, KKPTableViewCellStyleSubtitleLineBreak)) {
            self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.subtitleLabel.numberOfLines = 0;
        }
    } else {
        self.subtitleLabel.hidden = YES;
    }
}

- (void)_configureRightViews
{
    
    self.rightButton.hidden = YES;
    self.rightArrowImageView.hidden = YES;
    self.rightLabel.hidden = YES;
    self.rightSwitch.hidden = YES;
    
    // Button
    if (checkRightStyle(self.rightStyle, (KKPTableViewCellRightStyleButton)) ||
        checkCellStyle(self.cellStyle, KKPTableViewCellStyleButtonOnly)) {
        if (self.rightButton == nil) {
            self.rightButton = [KKPButton buttonWithType:KKPButtonType1];
            [self.contentView addSubview:self.rightButton];
            @weakify(self);
            [self.rightButton bk_addEventHandler:^(id sender) {
                @strongify(self);
                if (self.buttonHandlerBlock) {
                    self.buttonHandlerBlock();
                }
            } forControlEvents:UIControlEventTouchUpInside];
        }
        self.rightButton.hidden = NO;
    }
    
    // Switch
    if (checkRightStyle(self.rightStyle, KKPTableViewCellRightStyleSwitch)) {
        if (self.rightSwitch == nil) {
            self.rightSwitch = [self createSwitchButton];
            [self.contentView addSubview:self.rightSwitch];
            @weakify(self);
            [self.rightSwitch bk_addEventHandler:^(UISwitch *aSwitch) {
                @strongify(self);
                if (self.switchHandlerBlock) {
                    self.switchHandlerBlock(aSwitch.isOn);
                }
            } forControlEvents:UIControlEventValueChanged];
        }
        self.rightSwitch.hidden = NO;
    }
    
    [self configureRightViewDisclosureAndText];
    
}

- (void)configureRightViewDisclosureAndText
{
    // Disclosure
    if (checkRightStyle(self.rightStyle, KKPTableViewCellRightStyleDisclosure)) {
        if (self.rightArrowImageView == nil) {
            self.rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_indicator"]];
            [self.rightArrowImageView sizeToFit];
            [self.contentView addSubview:self.rightArrowImageView];
        }
        self.rightArrowImageView.hidden = NO;
    }
    
    // text
    if (checkRightStyle(self.rightStyle, KKPTableViewCellRightStyleText)) {
        if (self.rightLabel == nil) {
            self.rightLabel = [[UILabel alloc] init];
            [self.contentView addSubview:self.rightLabel];
        }
        self.rightLabel.hidden = NO;
        self.rightLabel.font = kFont.f13;
        self.rightLabel.textColor = kColor.colorGray;
    }
}

#pragma mark - Public Methods

- (CGFloat)configureRightWithDataDict:(NSDictionary *)dict rightStyle:(KKPTableViewCellRightStyle)rightStyle
{
    // Right
    CGFloat rightWidth = 0;
    
    if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleButton)) {
        NSString *buttonTitle = dict[KKPTableViewCellButtonTitleName];
        rightWidth = [KKPButton widthForTitle:buttonTitle] + 10;
        self.rightButton.title = buttonTitle;
        //        [self.rightButton sizeToFit];
        self.rightButton.size = (CGSize){rightWidth - 10, kButtonHeight};
        self.rightButton.centerY = self.height/2;
        self.rightButton.right = kScreenWidth - 10;
        void (^buttonBlock)() = dict[KKPTableViewCellButtonActionBlockName];
        self.buttonHandlerBlock = buttonBlock;
    } else if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleSwitch)) {
        rightWidth += 45;
        self.rightSwitch.size = (CGSize){30+20, kButtonHeight+14};
        self.rightSwitch.centerY = self.height/2;
        self.rightSwitch.right = kScreenWidth - 10;
        BOOL value = [dict[KKPTableViewCellSwitchValueName] boolValue];
        self.rightSwitch.on = value;
        void (^switchBlock)(BOOL) = dict[KKPTableViewCellSwitchActionBlockName];
        self.switchHandlerBlock = switchBlock;
    } else {
        if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleDisclosure)) {
            rightWidth += 20;
            self.rightArrowImageView.centerY = self.height/2;
            self.rightArrowImageView.x = kScreenWidth - 10 - self.rightArrowImageView.width;
        }
        if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleText)) {
            NSString *rightTitle = dict[KKPTableViewCellRightTitleName];
            CGFloat rightTitleWidth = [rightTitle widthWithFont:[UIFont systemFontOfSize:kRightLabelFontSize]];
            rightWidth += (rightTitleWidth + 10);
            self.rightLabel.text = rightTitle;
            [self.rightLabel sizeToFit];
            self.rightLabel.centerY = self.height/2;
            self.rightLabel.x = kScreenWidth - rightWidth;
        }
    }
    return rightWidth;
}

- (void)configureImageWithDataDict:(NSDictionary *)dict
               titleHeightOffset_p:(NSInteger *)titleHeightOffset_p
                   titleFontSize_p:(NSInteger *)titleFontSize_p
                      imageWidth_p:(CGFloat *)imageWidth_p
                         cellStyle:(KKPTableViewCellStyle)cellStyle
{
    // Image
    *imageWidth_p = 0;
    
    NSString *imageURL = dict[KKPTableViewCellImageURLName];
    NSString *placeholderImageName = @"ico_default_36";
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageSmall)) {
        *imageWidth_p += (kAvatarHeightSmall + 10);
        self.avatarImageView.size = (CGSize){kAvatarHeightSmall, kAvatarHeightSmall};
        placeholderImageName = @"ico_default_36";
    } else if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageNormal)) {
        *imageWidth_p += (kAvatarHeightNormal + 10);
        self.avatarImageView.size = (CGSize){kAvatarHeightNormal, kAvatarHeightNormal};
        placeholderImageName = @"ico_default_36";
    } else if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageLarge)) {
        *imageWidth_p += (kAvatarHeightLarge + 10);
        self.avatarImageView.size = (CGSize){kAvatarHeightLarge, kAvatarHeightLarge};
        placeholderImageName = @"ico_default_45";
    } else {
        *titleFontSize_p = kTitleFontWithoutImage;
        *titleHeightOffset_p = 5;
    }
    
    if ([imageURL respondsToSelector:@selector(hasPrefix:)] && [imageURL respondsToSelector:@selector(length)]) {
        if ([imageURL hasPrefix:@"http"]) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:placeholderImageName]];
        } else {
            if (imageURL.length > 0) {
                self.avatarImageView.image = [UIImage imageNamed:imageURL];
            } else {
                self.avatarImageView.image = nil;
            }
        }
    } else {
        if ([imageURL isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)imageURL;
            self.avatarImageView.image = image;
        }
    }
}

- (void)configureContentWithDataDict:(NSDictionary *)dict
                          rightWidth:(CGFloat)rightWidth
                          imageWidth:(CGFloat)imageWidth
                       titleFontSize:(NSInteger)titleFontSize
                           cellStyle:(KKPTableViewCellStyle)cellStyle
                   titleHeightOffset:(NSInteger)titleHeightOffset
{
    // content
    CGFloat contentHeight = 0;
    
    NSString *titleString = dict[KKPTableViewCellTitleName];
    CGFloat remainWidth = [UIScreen mainScreen].bounds.size.width - 20 - imageWidth - rightWidth;
    
    CGFloat titleHeight = 0;
    CGFloat subtitleHeight = 0;
    titleHeight = [titleString heightWithFont:[UIFont systemFontOfSize:titleFontSize] Width:remainWidth];
    self.titleLabel.text = titleString;
    self.titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
    self.titleLabel.size = (CGSize){remainWidth, titleHeight};
    self.titleLabel.centerY = self.height/2;
    self.titleLabel.x = 10 + imageWidth;
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitle) || checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitleLineBreak)) {
        NSString *subtitleString = dict[KKPTableViewCellSubtitleName];
        if (subtitleString) {
            //            subtitleHeight = [subtitleString heightWithFont:[UIFont systemFontOfSize:kSubtitleFontSize] Width:remainWidth] + 3;
            if (checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitleLineBreak)) {
                subtitleHeight = [subtitleString heightWithFont:[UIFont systemFontOfSize:kSubtitleFontSize] Width:remainWidth] + 3;
            } else {
                subtitleHeight = [subtitleString heightWithFont:[UIFont systemFontOfSize:kSubtitleFontSize] Width:CGFLOAT_MAX] + 3;
            }
            self.titleLabel.y = 10 + titleHeightOffset;
            self.subtitleLabel.text = subtitleString;
            self.subtitleLabel.size = (CGSize){remainWidth, subtitleHeight - 3};
            self.subtitleLabel.top = self.titleLabel.bottom + 3;
            self.subtitleLabel.left = 10 + imageWidth;
            if (checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitleLineBreak)) {
                self.subtitleLabel.numberOfLines = 0;
                self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            } else {
                self.subtitleLabel.numberOfLines = 1;
                self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            }
        }
    }
    contentHeight = titleHeight + subtitleHeight;
    if (imageWidth > contentHeight) {
        self.titleLabel.y = 10 + (imageWidth - contentHeight)/2;
        self.subtitleLabel.top = self.titleLabel.bottom + 3;
    }
}

- (void)setDataDict:(NSDictionary *)dict
{
    _dataDict = dict;
    
    KKPTableViewCellStyle cellStyle = [dict[KKPTableViewCellStyleName] integerValue];
    KKPTableViewCellRightStyle rightStyle = [dict[KKPTableViewCellRightStyleName] integerValue];
    self.cellStyle = cellStyle;
    self.rightStyle = rightStyle;
    [self _configureViews];
    
    id needsHighlightedObject = dict[KKPTableViewCellNeedsHighlightedName];
    if (needsHighlightedObject == nil) {
        if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleDisclosure)) {
            self.needsHighlighted = YES;
        } else {
            self.needsHighlighted = NO;
        }
    } else {
        self.needsHighlighted = [needsHighlightedObject boolValue];
    }
    
    // Button
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleButtonOnly)) {
        NSString *buttonTitle = dict[KKPTableViewCellButtonTitleName];
        self.rightButton.title = buttonTitle;
        self.rightButton.size = (CGSize){kScreenWidth - 20, 40};
        self.rightButton.centerY = self.height/2;
        self.rightButton.left = 10;
        self.needsHighlighted = NO;
        self.backgroundColor = [UIColor clearColor];
        self.topLineHidden = YES;
        self.bottomLineHidden = YES;
        void (^buttonBlock)() = dict[KKPTableViewCellButtonActionBlockName];
        self.buttonHandlerBlock = buttonBlock;
        return;
    }
    self.backgroundColor = [UIColor whiteColor];

    CGFloat rightWidth;
    rightWidth = [self configureRightWithDataDict:dict rightStyle:rightStyle];
    
    NSInteger titleFontSize = kTitleFontSize;
    NSInteger titleHeightOffset = 0;
    
    CGFloat imageWidth;
    [self configureImageWithDataDict:dict
                 titleHeightOffset_p:&titleHeightOffset
                     titleFontSize_p:&titleFontSize
                        imageWidth_p:&imageWidth
                           cellStyle:cellStyle];
    
    [self configureContentWithDataDict:dict
                            rightWidth:rightWidth
                            imageWidth:imageWidth
                         titleFontSize:titleFontSize
                             cellStyle:cellStyle
                     titleHeightOffset:titleHeightOffset];
    
}

- (UISwitch *)createSwitchButton
{

    UISwitch *aSwitch = [[UISwitch alloc] init];
    aSwitch.onTintColor = kColor.colorOrange;

    return aSwitch;
}

#pragma mark - Class Methods

+ (CGFloat)cellHeightForDict:(NSDictionary *)dict
{
    
    KKPTableViewCellStyle cellStyle = [dict[KKPTableViewCellStyleName] integerValue];

    // button
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleButtonOnly)) {
        return 40;
    }
    
    // Right
    CGFloat rightWidth = 0;
    
    KKPTableViewCellRightStyle rightStyle = [dict[KKPTableViewCellRightStyleName] integerValue];
    if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleButton)) {
        NSString *buttonTitle = dict[KKPTableViewCellButtonTitleName];
        rightWidth = [KKPButton widthForTitle:buttonTitle] + 10;
    } else if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleSwitch)) {
        rightWidth += 45;
    } else {
        if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleDisclosure)) {
            rightWidth += 20;
        }
        if (checkRightStyle(rightStyle, KKPTableViewCellRightStyleText)) {
            NSString *rightTitle = dict[KKPTableViewCellRightTitleName];
            CGFloat rightTitleWidth = [rightTitle widthWithFont:[UIFont systemFontOfSize:kRightLabelFontSize]];
            rightWidth += (rightTitleWidth + 10);
        }
    }
    
    NSInteger titleFontSize = kTitleFontSize;
    NSInteger titleHeightOffset = 20;
    // Image
    CGFloat imageWidth = 0;
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageSmall)) {
        imageWidth += (kAvatarHeightSmall + 10);
    } else if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageNormal)) {
        imageWidth += (kAvatarHeightNormal + 10);
    } else if (checkCellStyle(cellStyle, KKPTableViewCellStyleImageLarge)) {
        imageWidth += (kAvatarHeightLarge + 10);
    } else {
        titleHeightOffset = 30;
        titleFontSize = kTitleFontWithoutImage;
    }
    
    CGFloat contentHeight = [self configureCountentWithDataDict:dict
                                             rightWidth:rightWidth
                                             imageWidth:imageWidth
                                          titleFontSize:titleFontSize
                                              cellStyle:cellStyle];
    
    if (imageWidth > contentHeight) {
        return imageWidth + 20;
    }
    
    return contentHeight + titleHeightOffset;
}

+ (CGFloat)configureCountentWithDataDict:(NSDictionary *)dict
                              rightWidth:(CGFloat)rightWidth
                              imageWidth:(CGFloat)imageWidth
                           titleFontSize:(NSInteger)titleFontSize
                               cellStyle:(KKPTableViewCellStyle)cellStyle
{
    
    CGFloat contentHeight = 0;
    
    NSString *titleString = dict[KKPTableViewCellTitleName];
    CGFloat remainWidth = kScreenWidth - 20 - imageWidth - rightWidth;
    
    CGFloat titleHeight = 0;
    CGFloat subtitleHeight = 0;
    titleHeight = [titleString heightWithFont:[UIFont systemFontOfSize:titleFontSize] Width:remainWidth];
    if (checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitle)) {
        NSString *subtitleString = dict[KKPTableViewCellSubtitleName];
        if (subtitleString) {
            if (checkCellStyle(cellStyle, KKPTableViewCellStyleSubtitleLineBreak)) {
                subtitleHeight = [subtitleString heightWithFont:[UIFont systemFontOfSize:kSubtitleFontSize] Width:remainWidth] + 3;
            } else {
                subtitleHeight = [subtitleString heightWithFont:[UIFont systemFontOfSize:kSubtitleFontSize] Width:CGFLOAT_MAX] + 3;
            }
        }
    }
    contentHeight = titleHeight + subtitleHeight;
    return contentHeight;
}

static BOOL checkCellStyle(KKPTableViewCellStyle cellStyle, KKPTableViewCellStyle checkStype)
{
    NSUInteger styleValue = cellStyle & checkStype;
    if (styleValue > 0) {
        return YES;
    }
    
    return NO;
}

static BOOL checkRightStyle(KKPTableViewCellRightStyle cellStyle, KKPTableViewCellRightStyle checkStype)
{
    NSUInteger styleValue = cellStyle & checkStype;
    if (styleValue > 0) {
        return YES;
    }
    
    return NO;
}

@end
