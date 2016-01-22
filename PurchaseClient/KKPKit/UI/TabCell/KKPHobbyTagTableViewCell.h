//
//  KKPHobbyTagTableViewCell.h
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/25.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, KKPHobbyTagTableViewCellState) {
    KKPHobbyTagTableViewCellNormal = 0,
    KKPHobbyTagTableViewCellDelete,
};

typedef NS_ENUM(NSUInteger, KKPHobbyTagTableViewCellTagButtonState) {
    KKPHobbyTagTableViewCellTagButtonStateNormal = 0,
    KKPHobbyTagTableViewCellTagButtonStateSeleted,
};

typedef void(^KKPHobbyTagButtonClickBlock) (NSInteger index, UIButton *button);
typedef void(^KKPHobbyMoreButtonClickBlock) ();
typedef void(^KKPHobbyDidDeleteBlock) (NSInteger index, NSString *text);
typedef void (^KKPHobbyDidAddBlock)(UIButton *button);

FOUNDATION_EXTERN NSString * const kHobbyTagTableViewCellReuseIdentifier;

@interface KKPHobbyTagTableViewCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *buttonTagTextArray;
@property (nonatomic, strong) NSString *headTitle;

@property (nonatomic, copy) KKPHobbyMoreButtonClickBlock moreButtonClick;
@property (nonatomic, copy) KKPHobbyTagButtonClickBlock tagClickBlock;
@property (nonatomic, copy) KKPHobbyDidDeleteBlock didDeleteBlock;
@property (nonatomic, copy) KKPHobbyDidAddBlock didAddBlock;
@property (nonatomic, strong) NSDictionary *cacheAboutLayout;   //缓存button顺序,如果有就赋值。没有只能重算 {}
@property (nonatomic, assign) BOOL seleteAble;
@property (nonatomic, strong) UIColor *tagColor;
@property (nonatomic, strong) UIColor *tagTitleColor;
@property (nonatomic, assign) KKPHobbyTagTableViewCellState cellState;
@property (nonatomic, assign) BOOL tagEnable;
@property (nonatomic, assign) BOOL headEnable;
@property (nonatomic, assign) BOOL showHead;
@property (nonatomic, strong) UIColor *tagButtonHeightLightColor;

@property (nonatomic, assign) BOOL needIndicator;   //是否需要显示那个箭头，可点击的
@property (nonatomic, assign) BOOL needLogo;        //是否需要显示左边logo 对应imageView

@property (nonatomic, assign) BOOL needResort; //是否需要重排


+ (CGFloat)caculateCellHeightWithTagTextArray:(NSArray *)textArray
                                needIndicator:(BOOL)needIndicator
                                     needLogo:(BOOL)needLogo
                                   isEditType:(BOOL)isEditType
                                     complete:(void(^)(NSDictionary *orderCache))com;

/**
 *  计算以textArray为内容时。cell的高度。已经布局信息。
 *
 *  @param textArray textArray description
 *  @param complete  complete 回传的参数中包含布局信息。以text为key（因为text内容不为空。）NSValue<frame>为值字典。
 *                   是同步返回的。
 *  @param complete
 *
 *  @return return Cell高度。
 */
+ (CGFloat)caculateCellHeightWithTagTextArray:(NSArray *)textArray
                                     showHead:(BOOL)showHead
                                   isEditType:(BOOL)isEditType
                                     complete:(void(^)(NSDictionary *orderCache))com;
/**
 *  不会自己重排的 像傻瓜一样。
 *
 *  @param textArray                           textArray description
 *  @param showHead                            showHead description
 *  @param isEditType                          isEditType description
 *  @param caculateCellHeightWidthTagTextArray caculateCellHeightWidthTagTextArray description
 *  @param textArray                           textArray description
 *  @param width                               width description
 *  @param isEditType                          isEditType description
 *  @param com                                 com description
 *
 *  @return return value description
 */
+ (CGFloat)caculateCellHeightWithOutReSortTagTextArray:(NSArray *)textArray
                                              showHead:(BOOL)showHead
                                            isEditType:(BOOL)isEditType
                                              complete:(void(^)(NSDictionary *orderCache))com;

/**
 *  当tableView不是屏幕宽度时可能会用到这个
 *
 *  @param textArray textArray description
 *  @param size      size description
 *  @param com       com description
 *
 *  @return return value description
 */
- (CGFloat)caculateCellHeightWidthTagTextArray:(NSArray *)textArray
                             widthContentWidth:(CGFloat)width
                                    isEditType:(BOOL)isEditType
                                      complete:(void(^)(NSDictionary *orderCache))com;



/**
 *  重新设置数据buttonTagTextArray之后调用reload。会根据新的内容。重新布局
 */
- (void)reloadTagButtons;

- (UIButton *)buttonForTextIndex:(NSInteger)index;

- (void)removeButtonWithIndex:(NSInteger)index;

/**
 *  会插入到第一个不是+的敌方
 *
 *  @param text
 *
 *  @return 
 */
- (BOOL)addTagTextAtFont:(NSString *)text atIndex:(NSInteger)index;

- (void)makeLayoutCenterWithWidth:(CGFloat)width;

- (void)settagClickAble:(BOOL)enabel;

@end
