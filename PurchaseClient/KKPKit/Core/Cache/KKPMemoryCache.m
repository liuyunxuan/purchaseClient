//
//  KKPMemoryCache.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/30.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "KKPMemoryCache.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import "EXTScope.h"

#define KKPDispatchOnCacheQueue(block) dispatch_async(_queue, block)
#define KKPDispatchAfter(time, block) dispatch_after(time, _queue, block)
#define KKPLockAction(block) do {                \
                                [self lock];     \
                                if (block) {     \
                                    block();     \
                                }                \
                                [self unlock];   \
                                } while(0)


NSString * const KKPMemoryCachePrefix = @"com.kakapo.KKPMemoryCache";

@interface KKPMemoryCache ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (assign) OSSpinLock spinLock;

@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSMutableDictionary *dates;
@property (strong, nonatomic) NSMutableDictionary *costs;

@end

@implementation KKPMemoryCache
@synthesize totalCost = _totalCost;
@synthesize ageLimit = _ageLimit;
@synthesize costLimit = _costLimit;
@synthesize didReceiveMemoryWarningBlock = _didReceiveMemoryWarningBlock;
@synthesize didEnterBackgroundBlock = _didEnterBackgroundBlock;


#pragma mark - lifeCircle

- (instancetype)init
{
    if (self = [super init]) {
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", KKPMemoryCachePrefix, self];
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _spinLock = OS_SPINLOCK_INIT;
        _dictionary = [NSMutableDictionary dictionary];
        _dates = [NSMutableDictionary dictionary];
        _costs = [NSMutableDictionary dictionary];
        
        _didEnterBackgroundBlock = nil;
        _didReceiveMemoryWarningBlock = nil;
        
        _ageLimit = 0.0;
        _costLimit = 0;
        _totalCost = 0;
        
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        _shouldRemoveAllObjectsWhenEnteringBackground = YES;
        
        [self addNotification];

    }
    return self;
}

- (void)addNotification
{
    for (NSString *name in @[UIApplicationDidReceiveMemoryWarningNotification, UIApplicationDidEnterBackgroundNotification]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:name
                                                   object:nil];
    }
}

#pragma mark - override

- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}


#pragma mark - Intance

+ (instancetype)sharedInstance
{
    static KKPMemoryCache *cache;
    static dispatch_once_t predicate;
    if (!cache) {
        dispatch_once(&predicate, ^{
            cache = [[self alloc] init];
            cache.name = @"sharedInstance";
        });
    }
    return cache;
}

#pragma mark - action Method -  Synchronous method

- (BOOL)containsObjectForKey:(id)key
{
    return NO;
}

- (id)objectForKey:(id)key
{
    if (!key) {
        return nil;
    }
    NSDate *now = [[NSDate alloc] init];
    [self lock];
    id object = _dictionary[key];
    [self unlock];

    if (object) {
        [self lock];
        _dates[key] = now;
        [self unlock];
    }
    
    return object;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    NSDate *now = [[NSDate alloc] init];
    __block NSUInteger costlimit;
    KKPLockAction(^{
        costlimit = _costLimit;
        _dictionary[key] = object;
        _dates[key] = now;
        _costs[key] = @(cost);
        _totalCost += cost;
    });
    if (costlimit > 0) {
        [self trimToCostLimitByDate:costlimit];
    }
}

- (void)removeObjectForKey:(NSString *)key
{
    KKPLockAction(^{
        NSNumber *cost = _costs[key];
        if (cost)
            _totalCost -= [cost unsignedIntegerValue];
        
        [_dictionary removeObjectForKey:key];
        [_dates removeObjectForKey:key];
        [_costs removeObjectForKey:key];
    });
}

- (void)removeAllObjects
{
    KKPLockAction(^{
        [_dictionary removeAllObjects];
        [_dates removeAllObjects];
        [_costs removeAllObjects];
        
        _totalCost = 0;
    });
}

- (void)trimToDate:(NSDate *)trimDate
{
    if (!trimDate)
        return;
    
    if ([trimDate isEqualToDate:[NSDate distantPast]]) {
        [self removeAllObjects];
        return;
    }
    
    [self trimMemoryToDate:trimDate];
}

- (void)trimToCost:(NSUInteger)cost
{
    [self trimToCostLimit:cost];
}

- (void)trimToCostByDate:(NSUInteger)cost
{
    [self trimToCostLimitByDate:cost];
}

#pragma mark - action Handler

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self handleNotification:notification];
    } else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self handleEnterBackground:notification];
    }
}

- (void)handleMemoryWarning:(NSNotification *)notification
{
    if (self.didReceiveMemoryWarningBlock) {
        self.didReceiveMemoryWarningBlock(self);
    }
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)handleEnterBackground:(NSNotification *)notification
{
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

#pragma mark - private Method

- (void)actionWithLock:(void(^)())block
{
    [self lock];
    if (block) {
        block();
    }
    [self unlock];
}

- (void)lock
{
    OSSpinLockLock(&_spinLock);
}

- (void)unlock
{
    OSSpinLockUnlock(&_spinLock);
}

- (void)trimToAgeLimitRecursively
{
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    
    if (ageLimit == 0.0)
        return;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-ageLimit];
    
    [self trimMemoryToDate:date];
    
    __weak KKPMemoryCache *weakSelf = self;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ageLimit * NSEC_PER_SEC));
    KKPDispatchAfter(time, ^{
        KKPMemoryCache *strongSelf = weakSelf;
        
        [strongSelf trimToAgeLimitRecursively];
    });
}


- (void)trimMemoryToDate:(NSDate *)trimDate
{
    [self lock];
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    NSDictionary *dates = [_dates copy];
    [self unlock];
    
    for (NSString *key in keysSortedByDate) { // 又旧到新
        NSDate *accessDate = dates[key];
        if (!accessDate)
            continue;
        
        if ([accessDate compare:trimDate] == NSOrderedAscending) { //比date老的
            [self removeObjectForKey:key];
        } else {
            break;
        }
    }
}

- (void)trimToCostLimit:(NSUInteger)limit
{
    [self lock];
    NSUInteger totalCost = _totalCost;
    NSArray *keysSortedByCost = [_costs keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit) {
        return;
    }
    
    for (NSString *key in [keysSortedByCost reverseObjectEnumerator]) { //最高消耗的－>最低
        [self removeObjectForKey:key];
        
        [self lock];
        NSUInteger totalCost = _totalCost;
        [self unlock];
        
        if (totalCost <= limit)
            break;
    }
}

- (void)trimToCostLimitByDate:(NSUInteger)limit  //一般都是用这个的
{
    [self lock];
    NSUInteger totalCost = _totalCost;
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit)
        return;
    
    for (NSString *key in keysSortedByDate) { // 最老－>最新
        [self removeObjectForKey:key];
        
        [self lock];
        NSUInteger totalCost = _totalCost;
        [self unlock];
        if (totalCost <= limit)
            break;
    }
}


#pragma mark - Safe setter & getter

- (NSUInteger)totalCost
{
    __block NSUInteger total;
    KKPLockAction(^{
        total = _totalCost;
    });
    return total;
}

- (NSTimeInterval)ageLimit
{
    __block NSTimeInterval ageLimit;
    KKPLockAction(^{
        ageLimit = _ageLimit;
    });
    return ageLimit;
}

- (void)setAgeLimit:(NSTimeInterval)ageLimit
{
    KKPLockAction(^{
        _ageLimit = ageLimit;
    });

    [self trimToAgeLimitRecursively];
}

- (NSUInteger)costLimit
{
    __block NSUInteger cost;
    KKPLockAction(^{
        cost = _costLimit;
    });
    return cost;
}

- (void)setCostLimit:(NSUInteger)costLimit
{
    KKPLockAction(^{
        _costLimit = costLimit;
    });
}

- (void (^)(KKPMemoryCache * _Nonnull))didReceiveMemoryWarningBlock
{
    __block void (^block)(KKPMemoryCache * cache);
    KKPLockAction(^{
        block = _didReceiveMemoryWarningBlock;
    });
    return block;
}

- (void)setDidReceiveMemoryWarningBlock:(void (^)(KKPMemoryCache * _Nonnull))didReceiveMemoryWarningBlock
{
    KKPLockAction(^{
        _didReceiveMemoryWarningBlock = didReceiveMemoryWarningBlock;
    });
}

- (void (^)(KKPMemoryCache * _Nonnull))didEnterBackgroundBlock
{
    __block void (^block)(KKPMemoryCache * cache);
    KKPLockAction(^{
        block = _didReceiveMemoryWarningBlock;
    });
    return block;
}

- (void)setDidEnterBackgroundBlock:(void (^)(KKPMemoryCache * _Nonnull))didEnterBackgroundBlock
{
    KKPLockAction(^{
        _didEnterBackgroundBlock = didEnterBackgroundBlock;
    });
}

@end
