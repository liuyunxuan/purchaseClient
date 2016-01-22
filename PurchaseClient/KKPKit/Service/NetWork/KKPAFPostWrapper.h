//
//  KKPAFWrapper.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//  简单的封装了一下AFNetWorking



#import <Foundation/Foundation.h>
@class KKPHttpRequestError;
@class KKPHttpDataPaser;

typedef void (^KKPHttpSuccessBlock)(NSURLResponse *response, NSDictionary* responseObject);
typedef void (^KKPHttpFailureBlock)(KKPHttpRequestError *error, NSURLResponse *response);

typedef NS_ENUM(NSUInteger, KKPURLCachePolicy)
{
    KKPURLCachePolicyAlwaysCache = 0,
    KKPURLCachePolicyNeverCache,
};

@interface KKPAFPostWrapper : NSObject

/**
 *  设置返回数据处理类，可设置dataParser的成功返回码，当请求返回的code等于成功返回码时，则进去成功block，否则进入失败block。
 *  同时将返回的nsdata，parse成dataParser的成员属性，包括返回码，返回提示语，返回数据
 */
@property (nonatomic, strong) KKPHttpDataPaser *dataParser;


- (KKPAFPostWrapper *(^)(NSString *url))requestUrl;
- (KKPAFPostWrapper *(^)(NSDictionary *params))params;
- (KKPAFPostWrapper *(^)(KKPURLCachePolicy cachePolicy))cahcePolicy;

- (void)getWithSuccess:(KKPHttpSuccessBlock)success fail:(KKPHttpFailureBlock)fail;
- (void)postWithSuccess:(KKPHttpSuccessBlock)success fail:(KKPHttpFailureBlock)fail;
- (void)cancel;

@end
