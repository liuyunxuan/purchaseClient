//
//  SPViewController+NaviBar.h
//
//  Created by Singro on 5/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCNavigationItem.h"
#import "SCBarButtonItem.h"

@interface UIViewController (SCNavigation)

@property (nonatomic, strong) SCNavigationItem *sc_navigationItem;
@property (nonatomic, strong) UIView *sc_navigationBar;
@property (nonatomic, strong) UIImage *sc_backButtonImage;


@property(nonatomic, getter = sc_isNavigationBarHidden) BOOL sc_navigationBarHidden;
@property (nonatomic, getter = sc_isNavigationBarNoNeedTransition) BOOL sc_navigationBarNoNeedTransition;

- (void)sc_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)naviBeginRefreshing;
- (void)naviEndRefreshing;

- (UIView *)createNavigationBar;

@end
