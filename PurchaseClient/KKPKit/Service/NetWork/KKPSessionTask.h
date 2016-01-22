//
//  KKPHttpRequestError.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation, KKPSessionTask;

typedef void (^UploadProgressBlock)(KKPSessionTask *task, NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

@interface KKPSessionTask : NSObject

@property (nonatomic, strong) NSNumber *timeStamp;
@property (nonatomic, strong) NSURLSessionTask *urlSessionTask;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UploadProgressBlock uploadProgress;
/**
 *  缓存到期时间
 */
@property (nonatomic, assign) NSNumber *cacheExpirationTime;
/**
 *  缓存ID，根据请求参数（timeStamp除外）进行base64，作为缓存ID
 */
@property (nonatomic, strong) NSString *cacheId;
/**
 *  使用sesstionTask生成实例，开发者无需使用，KKPSessionTask实例由KKPHTTPRequest请求时生成。
 *
 */
- (instancetype)initWithSessionTask:(NSURLSessionTask *)sessionTask;
/**
 *  使用AFHTTPRequestOperation生成实例，开发者无需使用，KKPSessionTask实例由KKPHTTPRequest请求时生成。
 *
 */
- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)opertaion;

/**
 *  终止请求，终止之后不可resume
 */
- (void)cancel;
/**
 *  恢复请求，通过KKPHTTPRequest生成Task实例时，处于暂停状态，需要显式call resume
 */
- (void)resume;
@end

typedef NS_ENUM(NSInteger, KKPHttpRequestErrorType)
{
    kKKPHttpBizError = 1,
    kKKPHttpNetWorkError
};

@interface KKPHttpRequestError : NSObject
@property (nonatomic,assign) KKPHttpRequestErrorType errType;
@property (nonatomic,strong) NSString* errMessage;
@property (nonatomic,assign) NSInteger errCode;
@property (nonatomic,strong) id error;
@end
