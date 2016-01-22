//
//  NSMutableArray+KKPaddtion.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (KKPaddtion)

- (NSMutableArray *)kkp_map:(id(^)(id value))transform;

@end
