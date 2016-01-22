//
//  NWInAppSetting.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/9.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//  保存一些应用程序的配置信息以及个人用户的轻量级账户信息

#import <Foundation/Foundation.h>
//#import "NWUserDataObject.h"

@interface NWInAppSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, getter=isLogined) BOOL logined;

@property (nonatomic, strong) NSString *token;

//@property (nonatomic, strong) NWUserInfo *userInfo;

@property (nonatomic, strong) NSString *realName;

@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) NSString *phone;

@end