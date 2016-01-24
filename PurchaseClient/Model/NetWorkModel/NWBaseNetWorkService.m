//
//  NWBaseNetWorkService.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/5.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "NWBaseNetWorkService.h"
#import "KKPAFPostWrapper.h"
#import "KKPSessionTask.h"
#import <Foundation/Foundation.h>

static NSString *kResponseCodeKey = @"code";
static NSString *kResponseInfoKey = @"info";
static NSString *kResponseDataKey = @"data";

typedef NS_ENUM(NSInteger,NWResponseCode)
{
    NWResponseCodeSuccess = 0,
    NWResponseCodeFail =1,
};

@interface NWBaseNetWorkService()

@property (nonatomic, strong) KKPAFPostWrapper *wrapper;

@end

@implementation NWBaseNetWorkService


+ (void) post:(NSString *)uriString
   parameters:(NSDictionary *)parameters
      success:(void (^)(id data, NSString *info))success
      failure:(void (^)(NSString *info))failure
{
    KKPAFPostWrapper *wrapper = [[KKPAFPostWrapper alloc] init];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",DEBUG_HOST,uriString];
    
    wrapper.requestUrl(urlStr).params(parameters);
    [wrapper postWithSuccess:^(NSURLResponse *response, NSDictionary *responseObject) {
        NSNumber *codeNumber = [responseObject objectForKey:kResponseCodeKey];
        if ([codeNumber integerValue] == NWResponseCodeSuccess)
        {
            id data = [responseObject objectForKey:kResponseDataKey];
            NSString *info = [responseObject objectForKey:kResponseInfoKey];
            success(data,info);
        }
        else
        {
            if (failure)
            {
                NSString *info = [responseObject objectForKey:kResponseInfoKey];
                failure(info);
            }
        }
    } fail:^(KKPHttpRequestError *error, NSURLResponse *response) {
        failure(@"网络错误");
    }];
}

@end
