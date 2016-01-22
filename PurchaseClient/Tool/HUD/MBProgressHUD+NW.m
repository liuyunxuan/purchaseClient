//
//  MBProgressHUD+NW.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/2.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "MBProgressHUD+NW.h"

@implementation MBProgressHUD (NW)


+ (void)showQuickTipWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                              animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:text];
    [hud hide:YES afterDelay:2.0f];
}

+ (void)showQuickTipWithTitle:(NSString *)title withText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow]
                                              animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:title];
    [hud setDetailsLabelText:text];
    [hud hide:YES afterDelay:2.0f];
}

+ (void)showWaitingHUDInKeyWindow
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       MBProgressHUD *hud = [[self alloc] initWithView:[UIApplication sharedApplication].keyWindow];
                       hud.mode = MBProgressHUDModeCustomView;
                       hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading"]];
                       
                       //添加动画
                       CABasicAnimation *animation = [CABasicAnimation animation];
                       animation.keyPath = @"transform.rotation";
                       animation.toValue = @(2 * M_PI);
                       animation.repeatCount = 10000;
                       animation.duration = 1.5;
                       [hud.customView.layer addAnimation:animation forKey:@"rotationAnimation"];
                       
                       hud.removeFromSuperViewOnHide = YES;
                       [[UIApplication sharedApplication].keyWindow addSubview:hud];
                       [hud show:NO];

                   });
}

+ (void)hideAllWaitingHUDInKeyWindowCompletion:(void (^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow
                                 animated:NO];
        if (completion)
        {
            completion();
        }
    });

}

@end
