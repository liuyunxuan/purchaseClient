//
//  NWInAppSetting.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/9.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "NWInAppSetting.h"
#import <UIKit/UIKit.h>

static NSString *kLoginKey = @"Key_UserDefault_isLogin";
static NSString *kTokenKey = @"Key_UserDefault_token";
static NSString *kNickName = @"Key_UserDefault_nickName";
static NSString *kRealName = @"Key_UserDefault_realName";
static NSString *kPhone     = @"Key_UserDefault_phone";
static NSString *kLevel    = @"Key_UserDefault_level";

@interface NWInAppSetting ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation NWInAppSetting

+ (instancetype)sharedInstance
{
    static NWInAppSetting *setting = nil;
    static dispatch_once_t once_token;
    if (!setting)
    {
        dispatch_once(&once_token, ^{
            setting = [[NWInAppSetting alloc] init];
        });
    }
    return setting;
}

- (void)setLogined:(BOOL)logined
{
    [self.userDefaults setObject:[NSNumber numberWithBool:logined] forKey:kLoginKey];
}

- (BOOL)isLogined
{
    NSNumber *number = [self.userDefaults objectForKey:kLoginKey];
    if (number == nil)
    {
        return NO;
    }
    return [number boolValue];
}

- (void)setToken:(NSString *)token
{
    [self.userDefaults setObject:token forKey:kTokenKey];
}

- (NSString *)token
{
    return [self.userDefaults objectForKey:kTokenKey];
}

- (void)setRealName:(NSString *)realName
{
    [self.userDefaults setObject:realName forKey:kRealName];
}

- (NSString *)realName
{
    return [self.userDefaults objectForKey:kRealName];
}

- (void)setNickName:(NSString *)nickName
{
    [self.userDefaults setObject:nickName forKey:kNickName];
}

- (NSString *)nickName
{
    return [self.userDefaults objectForKey:kNickName];
}

- (void)setPhone:(NSString *)phone
{
    [self.userDefaults setObject:phone forKey:kPhone];
}

- (NSString *)phone
{
    return [self.userDefaults objectForKey:kPhone];
}

- (void)setLevel:(NSInteger)level
{
    [self.userDefaults setObject:[NSNumber numberWithInteger:level] forKey:kLevel];
}

- (NSInteger)level
{
    return [[self.userDefaults objectForKey:kLevel] integerValue];
}

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}
@end
