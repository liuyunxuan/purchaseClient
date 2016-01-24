//
//  PCUserService.h
//  PurchaseClient
//
//  Created by  liuyunxuan on 16/1/24.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "NWBaseNetWorkService.h"

@interface PCUserService : NWBaseNetWorkService

/**
 *  获取单例
 *
 *  @return 单例
 */
+ (instancetype)sharedInstance;

/**
 *  登陆   2.3
 *
 *  @param phone    手机号码
 *  @param password 密码
 *  @param houseId  物业id
 *  @param success  成功回调 token 和 试用者信息
 *  @param failure  失败回调
 */
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               houseId:(NSNumber *)houseId
               success:(void(^)(NSString *token))success
               failure:(PCNetFailure)failure;
@end
