//
//  KKPURLCache.m
//  KKPKit
//
//  Created by 刘特风 on 16/1/1.
//  Copyright © 2016年 kakapo. All rights reserved.
//

#import "KKPURLCache.h"

static NSUInteger const kKKPCacheMemroyCapacity = 10*1024*1024;
static NSUInteger const kKKPDiskCapacity = 100*1024*1024;

static NSMutableDictionary* requests;
@implementation KKPURLCache

+(void)registerCache
{
    [NSURLCache setSharedURLCache:[KKPURLCache sharedCache]];
}

+(instancetype)sharedCache
{
    static KKPURLCache* _sharedInstance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        _sharedInstance = [[KKPURLCache alloc]initWithMemoryCapacity:kKKPCacheMemroyCapacity diskCapacity:kKKPDiskCapacity diskPath:nil];
        
        requests = [[NSMutableDictionary alloc]init];
    });
    
    return _sharedInstance;
}
-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    if ([request.URL.absoluteString hasSuffix:@"jpg"] || [request.URL.absoluteString hasSuffix:@"png"]) {
        //缓存图片
        NSCachedURLResponse *cacheResponse = [super cachedResponseForRequest:request];
        return cacheResponse;
    }
    
    NSCachedURLResponse* cachedResponse = [super cachedResponseForRequest:request];
    
    if (!cachedResponse) {
        return nil;
    }
    
    
    NSString* requestCachePolicy = request.allHTTPHeaderFields[kKKPCachePolicyKey];
    NSString* requestCacheId = request.allHTTPHeaderFields[kKKPSessionCacheId];
    NSString* responseCacheId = cachedResponse.userInfo[kKKPSessionCacheId];
    NSDate* cacheExpirationDate = cachedResponse.userInfo[kKKPCacheExpirationKey];
    NSDate* nowDate = [NSDate date];
    
    if ([requestCachePolicy isEqualToString:[kKKPCachePolicyNeverCache copy]]) {
        return nil;
    }
    
    if (cacheExpirationDate == nil || responseCacheId == nil) {
        return nil;
    }
    //先比较requestCacheId跟responseCacheId不一样，则不返回缓存
    if ( ![responseCacheId isEqualToString:requestCacheId]) {
        [self removeCachedResponseForRequest:request];
        return nil;
    }
    if ([cacheExpirationDate compare:nowDate] == NSOrderedAscending) {
        [self removeCachedResponseForRequest:request];
        return nil;
    }
    
    
    return cachedResponse;
}

-(void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    [super storeCachedResponse:cachedResponse forRequest:request];
}

@end