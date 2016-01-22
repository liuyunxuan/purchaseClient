//
//  KKPMemoryCache.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/30.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KKPMemoryCache;

@interface KKPMemoryCache : NSObject

@property (copy, nonatomic) NSString *name;
@property (readonly, assign) NSUInteger totalCost;


#pragma mark - callBackBlock
@property (copy) void(^didReceiveMemoryWarningBlock)(KKPMemoryCache *cache);
@property (copy) void(^didEnterBackgroundBlock)(KKPMemoryCache *cache);


#pragma mark - limit

@property (assign) NSTimeInterval ageLimit;
/**
 *  默认是NSUIntegerMax, 如果超过这个，里面的有些对象会在子线程中清掉
 */
@property (assign) NSUInteger costLimit;
/**
 *  默认YES
 */
@property (assign) BOOL shouldRemoveAllObjectsOnMemoryWarning;
/**
 *  默认YES
 */
@property (assign) BOOL shouldRemoveAllObjectsWhenEnteringBackground;

#pragma mark - Intance

+ (instancetype)sharedInstance;

#pragma mark - action Method -  Synchronous method

- (BOOL)containsObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

- (void)trimToDate:(nullable NSDate *)date;
- (void)trimToCost:(NSUInteger)cost;
- (void)trimToCostByDate:(NSUInteger)cost;

@end

NS_ASSUME_NONNULL_END
