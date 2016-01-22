//
//  NSMutableArray+KKPaddtion.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "NSMutableArray+KKPaddtion.h"

@implementation NSMutableArray (KKPaddtion)

////haskell's way
//- (NSMutableArray *)kkp_map:(id(^)(id value))transform
//{
//    NSMutableArray *value;
//    if (self.count == 0) {
//        value = [@[] mutableCopy];
//    } else {
//        id last = self.lastObject;
//        id newLast = transform(last);
//        @autoreleasepool {
//            [self removeLastObject];
//        }
//        value = [self kkp_map:transform];
//        [value addObject:newLast];
//    }
//    return value;
//}

@end
