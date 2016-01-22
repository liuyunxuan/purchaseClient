//
//  MBProgressHUD+NW.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/2.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (NW)
/**
 快速显示全局提示(显示两秒钟)
 @param  text    NSString    提示内容
 */
+ (void)showQuickTipWithText:(NSString *)text;

/**
 快速显示全局提示(显示两秒钟)
 @param  title   NSString    提示题目
 @param  text    NSString    提示内容
 */
+ (void)showQuickTipWithTitle:(NSString *)title withText:(NSString *)text;

/**
 显示全局等待提示
 */
+ (void)showWaitingHUDInKeyWindow;

/**
 隐藏所有全局等待提示
 */
+ (void)hideAllWaitingHUDInKeyWindowCompletion:(void(^)())completion;



@end
