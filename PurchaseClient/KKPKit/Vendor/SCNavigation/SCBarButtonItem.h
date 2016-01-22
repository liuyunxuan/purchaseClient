//
//  SCBarButtonItem.h
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCBarButtonItemStyle) {  // for future use
    SCBarButtonItemStylePlain,
    SCBarButtonItemStyleBordered,
    SCBarButtonItemStyleDone,
};

@interface SCBarButtonItem : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, copy) void (^actionBlock)(id);

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

- (instancetype)initWithTitle:(NSString *)title style:(SCBarButtonItemStyle)style handler:(void (^)(id sender))action;

- (instancetype)initWithImage:(UIImage *)image style:(SCBarButtonItemStyle)style handler:(void (^)(id sender))action;

@end
