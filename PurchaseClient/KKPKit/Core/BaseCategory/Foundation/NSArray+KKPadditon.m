//
//  NSArray+KKPadditon.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "NSArray+KKPadditon.h"

@implementation NSArray (KKPadditon)

- (NSArray *)kkp_map:(id(^)(id value))transform
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (NSInteger i = 0; i < self.count; i++) {
        id value = self[i];
        id newValue = transform(value);
        NSAssert(newValue, @"newValue cannot  be nil!");
        [array addObject:newValue];
    }
    return array;    
}

- (NSArray *)kkp_flatMap:(id (^)(id))transform
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (NSInteger i = 0; i < self.count; i++) {
        id value = self[i];
        id newValue = transform(value);
        [array addObject:newValue];
    }
    return array;
}

- (NSArray *)kkp_fliter:(BOOL(^)(id value))condition
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (NSInteger i = 0; i < self.count; i++) {
        id value = self[i];
        if (condition(value)) {
            [array addObject:value];
        }
    }
    return array;
}

@end
