//
//  KKPURLCache.h
//  KKPKit
//
//  Created by 刘特风 on 16/1/1.
//  Copyright © 2016年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kKKPCacheExpirationKey = @"KKPCacheExpirationKey";
static NSString * const kKKPSessionCacheId = @"SessionCacheId";
static NSString * const kKKPCachePolicyKey = @"KKPCachePolicyKey";

static NSString * const kKKPCachePolicyNeverCache = @"KKPCachePolicyNeverCache";
static NSString * const kKKPCachePolicyAlwaysCache = @"KKPCachePolicyAlwaysCache";

@interface KKPURLCache : NSURLCache

/**
 *  获取KKPURLCache单例
 *
 *  @return 返回KKPURLCache单例
 */
+ (instancetype)sharedCache;

/**
 *  将KKPURLCache缓存规则注册到程序中，需要在任意HTTP请求前注册，可在appDelegate:didFinishLaunching里面添加
 */
+ (void)registerCache;

@end
