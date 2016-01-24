//
//  NWBaseNetWorkService.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/5.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//  所有的网络service必须继承的基类,统一在此层中做code 与 info 的处理
//

#define DEBUG_HOST  @"http://ppfix.cn/newworld/"

#import <Foundation/Foundation.h>

typedef void(^ PCNetFailure) (NSString * info);

@interface NWBaseNetWorkService : NSObject

/**
 *  基本的post请求，所有的Service子类通过该函数调用基本的请求
 *
 *  @param uriString  访问服务器文件的相对路径
 *  @param parameters 参数
 *  @param success    成功的回调，data可能为空
 *  @param failure    这里的info进行一定的处理，当无法网络连接时统一返回网络错误，如果服务器返回错信息则按服务器为准
 */
+ (void)post:(NSString *)uriString
  parameters:(NSDictionary *)parameters
     success:(void(^)( id data, NSString *info))success
     failure:(void(^)( NSString *info))failure;


@end
