//
//  KKPHttpRequestError.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "KKPSessionTask.h"
#import "AFNetworking.h"
#import "objc/runtime.h"


static const char* kKKPSessionTaskExpirationTimeKey = "SessionTaskExpiration";
static const char* kKKPSessionCacheId = "SessionCacheId";
@implementation KKPSessionTask

- (instancetype)initWithSessionTask:(NSURLSessionTask *)sessionTask
{
    if ( self = [super init]) {
        _urlSessionTask = sessionTask;
    }
    return self;
}

- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)opertaion
{
    if (self = [super init]) {
        _requestOperation = opertaion;
    }
    return self;
}

- (void)setCacheExpirationTime:(NSNumber *)cacheExpirationTime
{
    objc_setAssociatedObject(self.urlSessionTask, kKKPSessionTaskExpirationTimeKey, cacheExpirationTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)cacheExpirationTime
{
    return objc_getAssociatedObject(self.urlSessionTask, kKKPSessionTaskExpirationTimeKey);
}

- (void)setCacheId:(NSString *)cacheId
{
    objc_setAssociatedObject(self.urlSessionTask, kKKPSessionCacheId, cacheId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)cacheId
{
    return objc_getAssociatedObject(self.urlSessionTask, kKKPSessionCacheId);
}



- (void)cancel
{
    if (self.urlSessionTask) {
        [self.urlSessionTask suspend];
        [self.urlSessionTask cancel];
    }
    
    if (self.requestOperation) {
        [self.requestOperation cancel];
    }
    
}
- (void)resume
{
    if (self.urlSessionTask) {
        [self.urlSessionTask resume];
    }
    
    if (self.requestOperation) {
        [self.requestOperation resume];
    }
    
}

@end


@implementation KKPHttpRequestError

@end
