/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPShareBaseActivity
 *
 * Description	: 基础按钮item，基类，若想自定义item。需要继承此类。重写各个方法
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <UIKit/UIKit.h>

//用来给KKPShareActivityViewController用的。
typedef void(^clickBlock)();

@interface KKPShareBaseActivity : UIView

@property (nonatomic, copy) clickBlock block;


/**
 *  测试用的。为logo加上setAccessibilityLabel;
 *
 *  @param accessibilityLabel 
 */
- (void)setAccessibilityLabel:(NSString *)accessibilityLabel;

/**
 *  文字标题
 *
 *  @return 
 */
- (NSString *)activityTitle;
/**
 *  按钮一般状态下图片
 *
 *  @return
 */
- (UIImage *)activityImageNormal;
/**
 *  按钮点击状态下图片
 *
 *  @return
 */
- (UIImage *)activityImageClick;
/**
 *  按钮点击会执行的行为，注意如果是弹出viewcontroller之类的。因为分享组件件是个UIWindow， 可以考虑是否需要dispatch_after 0.61 后执行。
 */
- (void)performActivity;

/**
 *  按钮是否可点击。默认YES
 *
 *  @return YES
 */
- (BOOL)buttonEnable;
@end


