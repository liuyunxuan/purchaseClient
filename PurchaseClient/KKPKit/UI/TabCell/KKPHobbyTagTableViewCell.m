//
//  KKPHobbyTagTableViewCell.m
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/25.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import "KKPHobbyTagTableViewCell.h"
#import "FrameAccessor.h"
#import "KKPHobbyTagButton.h"
#import "EXTScope.h"
#import <math.h>

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]



#pragma mark - headView

typedef void(^KKPHobbyTagTableViewCellHeadViewClick) ();

@interface KKPHobbyTagTableViewCellHeadView : UIView

@property (nonatomic, assign) BOOL showIndicatorAndSeletable;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *grid;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *indicator;

@property (nonatomic, copy) KKPHobbyTagTableViewCellHeadViewClick clickBlock;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation KKPHobbyTagTableViewCellHeadView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.showIndicatorAndSeletable = NO;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)tapClick:(UITapGestureRecognizer *)gesture
{
    if (self.clickBlock) {
        self.clickBlock();
    }
}


#pragma mark - getter & setter

- (void)setShowIndicatorAndSeletable:(BOOL)showIndicatorAndSeletable
{
    _showIndicatorAndSeletable = showIndicatorAndSeletable;
    self.indicator.hidden = !showIndicatorAndSeletable;
    if (showIndicatorAndSeletable) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:self.tapGesture];
    }else {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] init];
        [_title setFont:[UIFont systemFontOfSize:12]];
        [_title setTextColor:[UIColor blackColor]];
        [self addSubview:_title];
    }
    return _title;
}

- (UIView *)grid
{
    if (!_grid) {
        _grid = [[UIView alloc]initWithFrame:CGRectMake(12, 0, 4, 12)];
        [_grid setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:_grid];
    }
    return _grid;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, .5)];
        [_line setBackgroundColor:[UIColor grayColor]];
        [self addSubview:_line];
    }
    return _line;
}

- (UIImageView *)indicator
{
    if (_indicator) {
        _indicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
        _indicator.image = [UIImage imageNamed:@"disclosure_indicator"];
        _indicator.hidden = YES;
        [self addSubview:_indicator];
    }
    return _indicator;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.grid.x = 12;
    self.grid.centerY = self.centerY;
    self.title.x = self.grid.right + 7;
    [self.title sizeToFit];
    self.title.centerY = self.centerY;
    self.line.x = self.title.right + 15;
    self.line.centerY = self.centerY;
    if (self.showIndicatorAndSeletable) {
        self.indicator.right = self.width - 12;
        self.indicator.centerY = self.centerY;
        self.line.width = self.indicator.left - self.line.x - 12;
    }else {
        self.line.width = self.width - self.line.x - 12;
    }
}



@end


















static const CGFloat MaxWidthForButtonText             = 250;

//static const CGSize deleteButtonSize                   = {15, 15};
static const CGFloat ButtonTopSpace                    = 10;
static const CGFloat ButtonButtomSpace                 = 10;
static const CGFloat ButtonVerticalSpace               = 5;
static const CGFloat ButtonHorizontalSpace             = 5;
static const CGFloat ButtonHeight                      = 30;
static const CGFloat CellLeftInSet                     = 12;
static const CGFloat CellRightInSet                    = 12;

static const CGFloat HeadHeight = 17 + 14 + 17;

static const NSTimeInterval deleteAnimationDuration    = 0.4;

NSString * const kHobbyTagTableViewCellReuseIdentifier = @"kHobbyTagTableViewCellReuseIdentifier";

static NSString * const kCacheForLineIndex             = @"kCacheForLineIndex";     //{text : line}
static NSString * const kCacheForSortIndex             = @"kCacheForSortIndex";     //{text : index}
static NSString * const kCacheForSortFrame             = @"kCacheForSortFrame";     //{text : frame}

#define TagFont                                        [UIFont  systemFontOfSize:14]
#define MoreButtonHeight                               self.bounds.size.height
#define SpaceForTagWidth \
([UIScreen mainScreen].bounds.size.width - CellRightInSet - CellLeftInSet)


@interface KKPHobbyTagTableViewCell ()

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) NSMutableArray *tagButtonArray;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) NSInteger currentLine;
@property (nonatomic, assign) NSInteger currentX;
@property (nonatomic, strong) KKPHobbyTagTableViewCellHeadView *cellHeadView;



@end


@implementation KKPHobbyTagTableViewCell

#pragma mark - public Method

+ (CGFloat)caculateCellHeightWithTagTextArray:(NSArray *)textArray
                                needIndicator:(BOOL)needIndicator
                                     needLogo:(BOOL)needLogo
                                   isEditType:(BOOL)isEditType
                                     complete:(void(^)(NSDictionary *orderCache))com
{
    CGFloat real_SpaceForTagWidth = SpaceForTagWidth;
    real_SpaceForTagWidth = needIndicator ? real_SpaceForTagWidth - 10 - 10 - 12 : real_SpaceForTagWidth;
    real_SpaceForTagWidth = needLogo ? real_SpaceForTagWidth - 20 - 10 : real_SpaceForTagWidth;
    CGFloat BeginX = needLogo ? 12 + 20 + 18 : 0;
    CGFloat BeginY = 10;
    CGFloat bottomSpace = 10;
    for (id object in textArray) {
        if (![object isKindOfClass:[NSString class]]) {
            NSLog(@"textArray contain !NSSting Object !");
            return 0;
        }
    }
    
    return [KKPHobbyTagTableViewCell basiceCaculateCellHeightWithTexts:textArray
                                                           NeedResort:NO
                                                               beginX:BeginX
                                                               beginY:BeginY
                                                          bottomSpace:bottomSpace
                                                       availableSpace:real_SpaceForTagWidth
                                                           isEditType:isEditType
                                                             complete:^(NSDictionary *orderCache) {
        if (com) {
            com(orderCache);
        }
    }];
}


+ (CGFloat)caculateCellHeightWithTagTextArray:(NSArray *)textArray
                                     showHead:(BOOL)showHead
                                   isEditType:(BOOL)isEditType
                                     complete:(void(^)(NSDictionary *orderCache))com;
{
    CGFloat real_SpaceForTagWidth = SpaceForTagWidth;
    CGFloat BeginX = 0;
    CGFloat BeginY = showHead ? HeadHeight : ButtonTopSpace;
    CGFloat bottomSpace = showHead ? 17 : ButtonButtomSpace;
    for (id object in textArray) {
        if (![object isKindOfClass:[NSString class]]) {
            NSLog(@"textArray contain !NSSting Object !");
            return 0;
        }
    }
    
    return [KKPHobbyTagTableViewCell basiceCaculateCellHeightWithTexts:textArray
                                                           NeedResort:YES
                                                               beginX:BeginX
                                                               beginY:BeginY
                                                          bottomSpace:bottomSpace
                                                       availableSpace:real_SpaceForTagWidth
                                                           isEditType:isEditType
                                                             complete:^(NSDictionary *orderCache) {
        if (com) {
            com(orderCache);
        }
    }];
}

+ (CGFloat)caculateCellHeightWithOutReSortTagTextArray:(NSArray *)textArray
                                              showHead:(BOOL)showHead
                                            isEditType:(BOOL)isEditType
                                              complete:(void(^)(NSDictionary *orderCache))com
{
    CGFloat real_SpaceForTagWidth = SpaceForTagWidth;
    CGFloat BeginX = 12;
    CGFloat BeginY = showHead ? HeadHeight : ButtonTopSpace;
    CGFloat buttomSpace = showHead ? 17 : ButtonButtomSpace;
    for (id object in textArray) {
        if (![object isKindOfClass:[NSString class]]) {
            NSLog(@"textArray contain !NSSting Object !");
            return 0;
        }
    }
    return [KKPHobbyTagTableViewCell basiceCaculateCellHeightWithTexts:textArray
                                                           NeedResort:NO
                                                               beginX:BeginX
                                                               beginY:BeginY
                                                          bottomSpace:buttomSpace
                                                       availableSpace:real_SpaceForTagWidth
                                                           isEditType:isEditType
                                                             complete:^(NSDictionary *orderCache) {
        if (com) {
            com(orderCache);
        }
    }];
}



- (CGFloat)caculateCellHeightWidthTagTextArray:(NSArray *)textArray
                             widthContentWidth:(CGFloat)width
                                    isEditType:(BOOL)isEditType
                                      complete:(void(^)(NSDictionary *orderCache))com;
{
    CGFloat BeginX = 0;
    for (id object in textArray) {
        if (![object isKindOfClass:[NSString class]]) {
            NSLog(@"textArray contain !NSSting Object !");
            return 0;
        }
    }
    return [KKPHobbyTagTableViewCell basiceCaculateCellHeightWithTexts:textArray
                                                           NeedResort:YES
                                                               beginX:BeginX
                                                               beginY:ButtonTopSpace
                                                          bottomSpace:ButtonButtomSpace
                                                       availableSpace:width
                                                           isEditType:isEditType
                                                             complete:^(NSDictionary *orderCache) {
        if (com) {
            com(orderCache);
        }
    }];
}



- (void)reloadTagButtons
{
    BOOL isedit = NO;
    if (self.cellState == KKPHobbyTagTableViewCellDelete) {
        isedit = YES;
    }
    __weak __typeof(self)weakSelf = self;
    if (self.needResort) {
    self.cellHeight = [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                                         showHead:self.showHead
                                                                       isEditType:isedit
                                                                         complete:^(NSDictionary *orderCache) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.cacheAboutLayout = orderCache;
    }];
    }else {
        self.cellHeight = [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                                             showHead:self.showHead
                                                                           isEditType:isedit
                                                                             complete:^(NSDictionary *orderCache) {
                                                                                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                                                 strongSelf.cacheAboutLayout = orderCache;
                                                                             }];

    }
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutTagButtons];
    }];
}

- (UIButton *)buttonForTextIndex:(NSInteger)index
{
    return self.tagButtonArray[index];
}

- (void)removeButtonWithIndex:(NSInteger)index
{
    UIButton *temp = self.tagButtonArray[index];
    temp.hidden = YES;
    [self.tagButtonArray removeObject:temp];
    [self.buttonTagTextArray removeObjectAtIndex:index];
    BOOL isedit = NO;
    if (self.cellState == KKPHobbyTagTableViewCellDelete) {
        isedit = YES;
    }
    if (!self.needResort) {
    [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                       showHead:self.showHead
                                                     isEditType:isedit
                                                       complete:^(NSDictionary *orderCache) {
                                                           self.cacheAboutLayout = orderCache;
                                                       }];
    }else {
        [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                           showHead:self.showHead
                                                         isEditType:isedit
                                                           complete:^(NSDictionary *orderCache) {
                                                               self.cacheAboutLayout = orderCache;
                                                           }];
        
    }
    [UIView animateWithDuration:deleteAnimationDuration animations:^{
        [self layoutTagButtons];
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
        if (self.didDeleteBlock) {
            self.didDeleteBlock(index, temp.titleLabel.text);
        }
    }];
}

- (BOOL)addTagTextAtFont:(NSString *)text atIndex:(NSInteger)index
{
    for (NSString *temp in self.buttonTagTextArray) {
        if ([text isEqualToString:temp]) {
            return NO;                       //有相同的 跳出
        }
    }
    [self.buttonTagTextArray insertObject:text atIndex:index];
    
    KKPHobbyTagButton *temp = [[KKPHobbyTagButton alloc] init];
    temp.tag = index;
    [temp setTitle:text forState:UIControlStateNormal];
    temp.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [temp addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:temp];
    [self.tagButtonArray insertObject:temp atIndex:index];
    temp.boardColor = self.tagColor;
    [temp setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
    BOOL isedit = NO;
    if (self.cellState == KKPHobbyTagTableViewCellDelete) {
        isedit = YES;
    }
    if (self.tagButtonHeightLightColor) {
        temp.heightLightColor = self.tagButtonHeightLightColor;
    }
    
    if (!self.needResort) {
    [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                       showHead:self.showHead
                                                     isEditType:isedit
                                                       complete:^(NSDictionary *orderCache) {
                                                           self.cacheAboutLayout = orderCache;
                                                       }];

    }else {
        [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                                    showHead:self.showHead
                                                                  isEditType:isedit
                                                                    complete:^(NSDictionary *orderCache) {
                                                                        self.cacheAboutLayout = orderCache;
                                                                    }];

    }
    if (self.didAddBlock) {
        self.didAddBlock(temp);
    }
    [UIView animateWithDuration:deleteAnimationDuration animations:^{
        [self layoutTagButtons];
    } completion:^(BOOL finished) {
    }];
    return YES;

}

//居中
- (void)makeLayoutCenterWithWidth:(CGFloat)width;
{
    if (!(self.buttonTagTextArray.count > 0)) {
        return;
    }
    CGFloat originAvailableSpace = width;
    CGFloat real_SpaceForTagWidth = originAvailableSpace;
    BOOL isedit = NO;
    if (self.cellState == KKPHobbyTagTableViewCellDelete) {
        isedit = YES;
    }
    @weakify(self);
    if (!self.cacheAboutLayout) {
        [self caculateCellHeightWidthTagTextArray:self.buttonTagTextArray
                                widthContentWidth:width
                                       isEditType:isedit
                                         complete:^(NSDictionary *orderCache) {
            @strongify(self);
            self.cacheAboutLayout = orderCache;
        }];
    }
    NSMutableDictionary *tempForMinX = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tempForMaxX = [[NSMutableDictionary alloc] init];
    NSDictionary *dicForFrame = self.cacheAboutLayout[kCacheForSortFrame];
    NSDictionary *dicForLine = self.cacheAboutLayout[kCacheForLineIndex];
    NSMutableDictionary *SpaceNeedToAddForLine = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *newFrame = [[NSMutableDictionary alloc] init];
    [self caculateOneWithMinX:tempForMinX max:tempForMaxX dicForLine:dicForLine dicForFrame:dicForFrame];
    [self caculateTwoWithMinX:tempForMinX
                          max:tempForMaxX
        real_SpaceForTagWidth:real_SpaceForTagWidth
        SpaceNeedToAddForLine:SpaceNeedToAddForLine];
    for (NSString *text in dicForLine.allKeys) {
        CGRect frame = ((NSValue *)dicForFrame[text]).CGRectValue;
        NSNumber *line = dicForLine[text];
        CGFloat temp = ((NSNumber *)SpaceNeedToAddForLine[line]).floatValue;
        frame = (CGRect){frame.origin.x + temp, frame.origin.y, frame.size};
        newFrame[text] = [NSValue valueWithCGRect:frame];
    }
    
    NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] initWithDictionary:self.cacheAboutLayout copyItems:NO];
    dicTemp[kCacheForSortFrame] = newFrame;
    self.cacheAboutLayout = dicTemp;
    [self layoutTagButtons];
}

- (void)caculateOneWithMinX:(NSMutableDictionary *)tempForMinX max:(NSMutableDictionary *)tempForMaxX
                 dicForLine:(NSDictionary *)dicForLine dicForFrame:(NSDictionary *)dicForFrame
{
    for (NSString *text in self.buttonTagTextArray) {
        NSNumber *line = dicForLine[text];
        CGRect frame = ((NSValue *)dicForFrame[text]).CGRectValue;
        NSNumber *maxX = tempForMaxX[line];
        NSNumber *minX = tempForMinX[line];
        if (!maxX || (CGRectGetMaxX(frame) > maxX.floatValue) ) {
            tempForMaxX[line] = @(CGRectGetMaxX(frame));
        }
        if (!minX || (CGRectGetMinX(frame) < minX.floatValue) ) {
            tempForMinX[line] = @(CGRectGetMinX(frame));
        }
    }
}

- (void)caculateTwoWithMinX:(NSMutableDictionary *)tempForMinX
                        max:(NSMutableDictionary *)tempForMaxX
      real_SpaceForTagWidth:(CGFloat)real_SpaceForTagWidth
      SpaceNeedToAddForLine:(NSMutableDictionary *)SpaceNeedToAddForLine
{
    for (NSNumber *key in tempForMinX.allKeys) {
        NSNumber *minx = tempForMinX[key];
        NSNumber *maxX = tempForMaxX[key];
        CGFloat space = ((real_SpaceForTagWidth - maxX.floatValue) - minx.floatValue) / 2;
        SpaceNeedToAddForLine[key] = @(space);
    }
}



- (void)settagClickAble:(BOOL)enabel
{
    for (KKPHobbyTagButton *button in self.tagButtonArray) {
        button.enabled = enabel;
    }
}

#pragma mark - private Method

//基本的计算。包括重排序和不重排
static CGFloat real_SpaceForTagWidth;

+ (CGFloat)basiceCaculateCellHeightWithTexts:(NSArray *)textArray
                                  NeedResort:(BOOL)resort
                                      beginX:(CGFloat)beginx
                                      beginY:(CGFloat)beginy
                                 bottomSpace:(CGFloat)buttomSpace
                              availableSpace:(CGFloat)space
                                  isEditType:(BOOL)isEditType
                                    complete:(void(^)(NSDictionary *orderCache))com;
{
    real_SpaceForTagWidth = space;
    CGFloat BeginX = beginx - ButtonHorizontalSpace;
    CGFloat BeginY = beginy;
    for (id object in textArray) {
        if (![object isKindOfClass:[NSString class]]) {
            NSLog(@"textArray contain !NSSting Object !");
            return 0;
        }
    }
    NSMutableDictionary *cacheForOrder = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *cacheForFrame = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *cacheForLine = [[NSMutableDictionary alloc] init];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:textArray];
    NSInteger tempLine = 0;
    CGFloat availableSpace = real_SpaceForTagWidth;
    NSInteger i = 0;
    while ( i < textArray.count ) {
        NSString *temp = textArray[i];
        if (!cacheForOrder[temp]) {   //如果字典中这个字符尚未被赋值。
            CGFloat width = [KKPHobbyTagTableViewCell contentSizeForButtonTagText:temp withImg:isEditType].width;
            if ( availableSpace > width ) {  //如果可以 直接赋值
                cacheForOrder[temp] = @(i);
                cacheForLine[temp] = @(tempLine);
                CGFloat y = tempLine * (ButtonHeight + ButtonVerticalSpace) + BeginY;
                CGFloat x = real_SpaceForTagWidth - availableSpace + ButtonHorizontalSpace + BeginX;
                cacheForFrame[temp] = [NSValue valueWithCGRect:CGRectMake(x, y, width, ButtonHeight)];
                [mutableArray removeObject:temp];
                availableSpace = availableSpace - (width + ButtonHorizontalSpace);   //可用空间减少
            }else {
                if (!resort) {    //不用重排
                    tempLine ++;    //没有可以匹配的 那就换行。
                    availableSpace = real_SpaceForTagWidth; //重置可用.
                }else{            //需要重排
                    [self forReSortWithMutableArray:mutableArray
                                         isEditType:isEditType
                                     availableSpace:&availableSpace
                                      cacheForOrder:cacheForOrder
                                       cacheForLine:cacheForLine
                                      cacheForFrame:cacheForFrame
                                                  i:&i tempLine:&tempLine
                                             BeginY:&BeginY BeginX:&BeginX];
                }
                continue;
            }
        }
        i ++ ;
    }
    CGFloat height = (tempLine + 1) * (ButtonVerticalSpace + ButtonHeight) + BeginY - ButtonVerticalSpace + buttomSpace;
    NSDictionary *cache = @{ kCacheForSortFrame : cacheForFrame,
                             kCacheForLineIndex : cacheForLine,
                             kCacheForSortIndex : cacheForOrder};
    if (com) {
        com(cache);
    }
    return height;
}

+ (void)forReSortWithMutableArray:(NSMutableArray *)mutableArray
                       isEditType:(BOOL)isEditType
                   availableSpace:(CGFloat *)availableSpace
                    cacheForOrder:(NSMutableDictionary *)cacheForOrder
                     cacheForLine:(NSMutableDictionary *)cacheForLine
                    cacheForFrame:(NSMutableDictionary *)cacheForFrame
                                i:(NSInteger *)i
                         tempLine:(NSInteger *)tempLine
                           BeginY:(CGFloat *)BeginY
                           BeginX:(CGFloat *)BeginX
{
    NSInteger innerI = 0;   //
    NSString *innerTemp;   //零时变量
    CGFloat width = 0;
    BOOL flagFind = NO;        //判断是否有添加到的
    for (innerI = 0; innerI < mutableArray.count; innerI ++) {
        innerTemp = mutableArray[innerI];
        width = [KKPHobbyTagTableViewCell contentSizeForButtonTagText:innerTemp withImg:isEditType].width;
        if ( *availableSpace > width ) {
            flagFind = YES;
            break;                       // 如果找到。直接break出for循环
        }
    }
    if (flagFind) {    //找到了
        cacheForOrder[innerTemp] = @(*i);  //赋值
        cacheForLine[innerTemp] = @(*tempLine);
        CGFloat y = *tempLine * (ButtonHeight + ButtonVerticalSpace) + *BeginY;
        CGFloat x = real_SpaceForTagWidth - *availableSpace + ButtonHorizontalSpace + *BeginX;
        cacheForFrame[innerTemp] = [NSValue valueWithCGRect:(CGRect){x, y, width, ButtonHeight}];
        *availableSpace = *availableSpace - (width + ButtonHorizontalSpace);   //可用空间减少
        [mutableArray removeObject:innerTemp];  //移除候选列表
    }else {
        *tempLine = *tempLine + 1;    //没有可以匹配的 那就换行。
        *availableSpace = real_SpaceForTagWidth; //重置可用.
    }
}

/*
 
 self findAndSetWidth:&width
 mutableArray:mutableArray
 innerI:&innerI
 innerTemp:innerTemp
 isEditType:isEditType
 availableSpace:&availableSpace
 */

+ (CGSize)contentSizeForButtonTagText:(NSString *)string withImg:(BOOL)img  //判断状态 是否有那个添加或者删除img
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSDictionary * attributes = @{NSFontAttributeName : TagFont,
                                      NSParagraphStyleAttributeName : paragraphStyle};
    CGSize contentSize = [string boundingRectWithSize:CGSizeMake(MaxWidthForButtonText , ButtonHeight)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  attributes:attributes
                                                     context:nil].size;
    CGFloat width = contentSize.width + 16; //左右各8;
    width = img ? width + 15 + 4 : width;
    CGSize temp = (CGSize){width, contentSize.height};
    return temp;
}

#pragma mark - lifeCircle

- (instancetype)init
{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self generateProperty];
        [self configBaseUI];
    }
    return self;
}

#pragma mark - Getter & Setter

- (void)setTagButtonHeightLightColor:(UIColor *)tagButtonHeightLightColor
{
    _tagButtonHeightLightColor = tagButtonHeightLightColor;
    for (KKPHobbyTagButton *button in self.tagButtonArray) {
        button.heightLightColor = _tagButtonHeightLightColor;
    }
}

-(void)setHeadEnable:(BOOL)headEnable
{
    _headEnable = headEnable;
    self.cellHeadView.showIndicatorAndSeletable = headEnable;
}

- (void)setShowHead:(BOOL)showHead
{
    _showHead = showHead;
    self.cellHeadView.title.text = self.headTitle;
    [self.cellHeadView.title sizeToFit];
    if (_showHead) {
        self.cellHeadView.hidden = NO;
    }else {
        self.cellHeadView.hidden = YES;
    }
}

- (void)setHeadTitle:(NSString *)headTitle
{
    _headTitle = headTitle;
    self.cellHeadView.title.text = self.headTitle;
}

- (KKPHobbyTagTableViewCellHeadView *)cellHeadView
{
    if (!_cellHeadView) {
        _cellHeadView = [[KKPHobbyTagTableViewCellHeadView alloc] init];
        _cellHeadView.height = HeadHeight;
        _cellHeadView.width = self.width;
        _cellHeadView.x = 0;
        _cellHeadView.y = 0;
        _cellHeadView.hidden = YES;
        [self addSubview:_cellHeadView];
    }
    return _cellHeadView;
}

- (void)setButtonTagTextArray:(NSMutableArray *)buttonTagTextArray
{
    _buttonTagTextArray = buttonTagTextArray;
    NSInteger count = buttonTagTextArray.count - self.tagButtonArray.count;
    NSMutableArray *newTagbutton = [NSMutableArray arrayWithArray:self.tagButtonArray];
    if (count > 0) {
        for (UIButton *button in self.tagButtonArray) {
            if (count <= 0) {
                break;
            }else {
                count --;
                [newTagbutton removeObject:button];
                [button removeFromSuperview];
            }
        }
    }else {
        NSInteger countAbs = labs(count);
        while (countAbs > 0) {
            for (UIButton *button in self.tagButtonArray) {
                [newTagbutton removeObject:button];
                [button removeFromSuperview];
                countAbs --;
            }
        }
    }
    self.tagButtonArray = newTagbutton;
    [self configTagButtons];
    [self layoutTagButtons];
}

- (void)setCellState:(KKPHobbyTagTableViewCellState)cellState
{
    _cellState = cellState;
    if (_cellState == KKPHobbyTagTableViewCellNormal) {
        if (self.needResort) {
        [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                           showHead:self.showHead
                                                         isEditType:NO
                                                           complete:^(NSDictionary *orderCache) {
            self.cacheAboutLayout = orderCache;
        }];
        }else {
            [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                                        showHead:self.showHead isEditType:NO
                                                                        complete:^(NSDictionary *orderCache) {
                self.cacheAboutLayout = orderCache;
            }];
        }
        [UIView animateWithDuration:deleteAnimationDuration animations:^{
            for (KKPHobbyTagButton *button in self.tagButtonArray) {
                if (button.type != KKPHobbyTagButtonTypeAdd ) {
                    button.type = KKPHobbyTagButtonTypeNormal;
                }
            }
            [self layoutTagButtons];
        } completion:^(BOOL finished) {
        }];
    }else if (_cellState == KKPHobbyTagTableViewCellDelete) {
        if (self.needResort) {
        [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                           showHead:self.showHead
                                                         isEditType:YES
                                                           complete:^(NSDictionary *orderCache) {
            self.cacheAboutLayout = orderCache;
        }];
        } else {
            [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                                        showHead:self.showHead
                                                                      isEditType:YES
                                                                        complete:^(NSDictionary *orderCache) {
                self.cacheAboutLayout = orderCache;
            }];
        }
        [UIView animateWithDuration:deleteAnimationDuration animations:^{
            for (KKPHobbyTagButton *button in self.tagButtonArray) {
                if (button.type != KKPHobbyTagButtonTypeAdd ) {
                    button.type = KKPHobbyTagButtonTypeDelete;
                }
            }
            [self layoutTagButtons];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)setTagEnable:(BOOL)tagEnable
{
    _tagEnable = tagEnable;
    for (UIButton *button in self.tagButtonArray)
    {
        button.enabled = _tagEnable;
    }
}

- (void)setSeleteAble:(BOOL)seleteAble
{
    _seleteAble = seleteAble;
    if (!seleteAble) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}

- (void)setTagColor:(UIColor *)tagColor
{
    _tagColor = tagColor;
    for (UIButton *tag in self.tagButtonArray) {
        ((KKPHobbyTagButton *)tag).boardColor = tagColor;
    }
}

- (void)setTagTitleColor:(UIColor *)tagTitleColor
{
    if (tagTitleColor) {
        _tagTitleColor = tagTitleColor;
        for (UIButton *tag in self.tagButtonArray) {
            [((KKPHobbyTagButton *)tag) setTitleColor:tagTitleColor forState:UIControlStateNormal];;
        }
    }
}

#pragma mark - inilizer

- (void)generateProperty
{
    self.buttonTagTextArray = [[NSMutableArray alloc] init];
    self.tagButtonArray = [[NSMutableArray alloc] init];
    self.tagButtonArray = [[NSMutableArray alloc] init];
    self.tagColor = RGB(0xececf1, 1);
    self.tagTitleColor = RGB(0x333333, 1);
    self.currentLine = 0;
    self.needResort = YES;
}

- (void)configBaseUI
{
    self.moreButton = [[UIButton alloc] init];
    [self.moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreButton setImage:[UIImage imageNamed:@"disclosure_indicator"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"disclosure_indicator"] forState:UIControlStateHighlighted];
    self.accessoryView = self.moreButton;
    
    self.imageView.image = [UIImage imageNamed:@"3_1引导_03"];
}

- (void)configTagButtons
{
    for (NSInteger i = 0; i < self.buttonTagTextArray.count; i++) {
        if (self.tagButtonArray.count > i) {
            KKPHobbyTagButton *temp = self.tagButtonArray[i];
            temp.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [temp addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [temp setTitle:self.buttonTagTextArray[i] forState:UIControlStateNormal];
            if (self.tagColor) {
                ((KKPHobbyTagButton *)temp).boardColor = self.tagColor;
                [((KKPHobbyTagButton *)temp) setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
            }
        }else {
            UIButton *temp = [[KKPHobbyTagButton alloc] init];
            temp.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [temp addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [temp setTitle:self.buttonTagTextArray[i] forState:UIControlStateNormal];
            if (self.tagColor) {
                ((KKPHobbyTagButton *)temp).boardColor = self.tagColor;
                [((KKPHobbyTagButton *)temp) setTitleColor:self.tagTitleColor forState:UIControlStateNormal];
            }
            [self.contentView addSubview:temp];
            [self.tagButtonArray addObject:temp];
        }
    }
}

#pragma mark - Action Handler

- (void)moreButtonClick:(UIButton *)button
{
    if (self.moreButtonClick) {
        self.moreButtonClick();
    }
}

- (void)tagButtonClick:(UIButton *)button
{
    if (self.cellState == KKPHobbyTagTableViewCellDelete) {
        KKPHobbyTagButton *tagButton = (KKPHobbyTagButton *)button;
        if (tagButton.type != KKPHobbyTagButtonTypeAdd) {
            NSInteger index = tagButton.tag;
            [self removeButtonWithIndex:index];
        }
    }
    if (self.tagClickBlock) {
        self.tagClickBlock(button.tag, button);
    }
}


#pragma mark - private Method


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.width = 20;
    self.imageView.height = 20;
    self.imageView.left = 12;
    self.imageView.centerY = self.contentView.centerY;
    self.imageView.hidden = !self.needLogo;
    self.moreButton.width = 10;
    self.moreButton.height = self.height;
    self.moreButton.right = self.width - 12;
    self.moreButton.centerY = self.contentView.centerY;
    self.moreButton.hidden = !self.needIndicator;
    self.cellHeadView.x = 0;
    self.cellHeadView.y = 0;
    self.cellHeadView.height = HeadHeight;
    self.cellHeadView.width = self.width;
    [self layoutTagButtons];
}



- (void)layoutTagButtons
{
    
    if (!self.cacheAboutLayout) {
        BOOL isedit = NO;
        if (self.cellState == KKPHobbyTagTableViewCellDelete) {
            isedit = YES;
        }
        if (self.needResort) {
        [KKPHobbyTagTableViewCell caculateCellHeightWithTagTextArray:self.buttonTagTextArray
                                                           showHead:self.showHead
                                                         isEditType:isedit
                                                           complete:^(NSDictionary *orderCache) {
                                                               self.cacheAboutLayout = orderCache;
                                                           }];
        }else {
            [KKPHobbyTagTableViewCell caculateCellHeightWithOutReSortTagTextArray:self.buttonTagTextArray
                                                               showHead:self.showHead
                                                             isEditType:isedit
                                                               complete:^(NSDictionary *orderCache) {
                                                                   self.cacheAboutLayout = orderCache;
                                                               }];
        }
    }
    
    NSDictionary *dic = self.cacheAboutLayout[kCacheForSortFrame];
    for (NSInteger i = 0; i < self.tagButtonArray.count; i ++) {
        KKPHobbyTagButton *button = self.tagButtonArray[i];
        if (button.type != KKPHobbyTagButtonTypeAdd){
            if (self.cellState == KKPHobbyTagTableViewCellTagButtonStateNormal) {
                button.type = KKPHobbyTagButtonTypeNormal;
            }else {
                button.type = KKPHobbyTagButtonTypeDelete;
            }
        }
        CGRect temp = ((NSValue *)dic[button.titleLabel.text]).CGRectValue;;
        button.frame = temp;
        button.tag = i; //更新一下
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

