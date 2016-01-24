//
//  PCUserService.m
//  PurchaseClient
//
//  Created by  liuyunxuan on 16/1/24.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "PCUserService.h"

@implementation PCUserService

+ (instancetype)sharedInstance
{
    static dispatch_once_t once_token;
    static PCUserService *service = nil;
    if (service == nil)
    {
        dispatch_once(&once_token, ^{
            service = [[PCUserService alloc] init];
        });
    }
    return service;
}

+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
               houseId:(NSNumber *)houseId
               success:(void(^)(NSString *token))success
               failure:(PCNetFailure)failure
{
    
}

@end
