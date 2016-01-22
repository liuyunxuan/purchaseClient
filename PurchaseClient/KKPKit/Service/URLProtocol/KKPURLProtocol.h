//
//  KKPURLProtocol.h
//  KKPKit
//
//  Created by 刘特风 on 16/1/9.
//  Copyright © 2016年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKPURLProtocol : NSURLProtocol

/**
 *  注册protocol，能拦截所有URL, 在app启动越早注册越好，可以在appdelega:didFinishLaunching里面注册
 */
+ (void)registerProtocol;



#pragma mark - 子类重写

+ (BOOL)needToHandleByCustomForRequest:(NSURLRequest *)request;

@end
