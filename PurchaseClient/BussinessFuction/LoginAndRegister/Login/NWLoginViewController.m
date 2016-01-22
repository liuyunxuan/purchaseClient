//
//  NWLoginViewController.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/9.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//  这里客户的逻辑是如果点击登陆的时候如果为填入密码或者账户，或者后台访问用户未注册，则跳入注册页面

#import "NWLoginViewController.h"
#import "NWTestWindow.h"
#import "MBProgressHUD+NW.h"
#import "NWInAppSetting.h"
#import "NWTestWindow.h"
#import "NWRegisterViewController.h"

@interface NWLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *lgoinButton;
@property (strong, nonatomic) UIWindow *testwindow;

@end

@implementation NWLoginViewController

/**
 *  这里判断逻辑是注册还是登陆
 *
 *  @param sender
 */
- (IBAction)login:(id)sender {
    if ([self.phoneTextField.text isEqualToString:@""]
        ||[self.passwordTextField.text isEqualToString:@""])
    {
        NWRegisterViewController *registerVC = [[NWRegisterViewController alloc] init];
        [self presentViewController:registerVC animated:YES completion:nil];
    }
    else
    {
//        [MBProgressHUD showWaitingHUDInKeyWindow];
//        [NWUserService loginWithPhone:self.phoneTextField.text
//                             password:self.passwordTextField.text
//                              houseId:nil
//                              success:^(NSString *token, NWUserInfo *info) {
//                                  NWInAppSetting *setting = [NWInAppSetting sharedInstance];
//                                  setting.token = token;
//                                  [MBProgressHUD hideAllWaitingHUDInKeyWindowCompletion:nil];
//                                  if ([self.delegate respondsToSelector:@selector(loginDidSuccess)])
//                                  {
//                                      setting.token = token;
//                                      setting.realName = info.realName;
//                                      setting.nickName = info.nickName;
//                                      setting.phone = info.phone;
//                                      setting.level = info.level;
////                                      [setting setLogined:YES];
//                                      [self.delegate loginDidSuccess];
//                                  }
//                              }
//                              failure:^(NSString *info) {
//                                  [MBProgressHUD hideAllWaitingHUDInKeyWindowCompletion:^{
//                                      [MBProgressHUD showQuickTipWithText:info];
//                                  }];
//                              }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
