//
//  NSArray+KKPadditon.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (KKPadditon)

- (NSArray *)kkp_map:(id(^)(id value))transform;
- (NSArray *)kkP_flatMap:(id(^)(id value))transform;
- (NSArray *)kkp_fliter:(BOOL(^)(id value))condition;

@end
