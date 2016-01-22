//
//  SCNavigationItem.m
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCNavigationItem.h"

#import "SCShared.h"

#import "UIViewController+SCNavigation.h"

@interface SCNavigationItem ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, assign) UIViewController *_sc_viewController;

@end

@implementation SCNavigationItem

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)setTitle:(NSString *)title {

    _title = title;

    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:20]];
        [_titleLabel setTextColor:kNavigationBarTintColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [__sc_viewController.sc_navigationBar addSubview:_titleLabel];
    }

    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
    _titleLabel.width = [UIScreen mainScreen].bounds.size.width - otherButtonWidth - 20;
    _titleLabel.centerY = 42;
    _titleLabel.centerX = [UIScreen mainScreen].bounds.size.width/2;

}

- (void)setLeftBarButtonItem:(SCBarButtonItem *)leftBarButtonItem {

    if (__sc_viewController) {
        [_leftBarButtonItem.view removeFromSuperview];
        leftBarButtonItem.view.x = 0;
        leftBarButtonItem.view.centerY = 42;
        [__sc_viewController.sc_navigationBar addSubview:leftBarButtonItem.view];
    }

    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setRightBarButtonItem:(SCBarButtonItem *)rightBarButtonItem {

    if (__sc_viewController) {
        [_rightBarButtonItem.view removeFromSuperview];
        rightBarButtonItem.view.x = [UIScreen mainScreen].bounds.size.width - rightBarButtonItem.view.width;
        rightBarButtonItem.view.centerY = 42;
        [__sc_viewController.sc_navigationBar addSubview:rightBarButtonItem.view];
    }

    _rightBarButtonItem = rightBarButtonItem;

}

- (UILabel *)titleLabel {
//    self.title = self.title;
    return _titleLabel;
}

@end
