//
//  KKPSlideMenu.h
//  Hotspot
//
//  Created by wayne on 15/8/7.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//


/*
 Example for init :
 
 - (KKPSlideMenu *)slideMenu
 {
 if (_slideMenu) {
     return _slideMenu;
 }
 NSArray *menus = @[@"动态", @"帖子", @"其他"];
 _slideMenu = [[KKPSlideMenu alloc] initWithMenus:menus contentView:self.scrollView];
 _slideMenu.y = 64;
 _slideMenu.willSlideToIndexBlock = ^(NSUInteger index) {
 };
 return _slideMenu;
 }
 
 PS : call [self.slideMenu setCurrentIndex:page animated:YES];  in your (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 
 */


#import <UIKit/UIKit.h>

typedef void (^KKPSlideMenuWillSlideToIndexBlock)(NSUInteger index);
typedef void (^KKPSlideMenuDidSlideToIndexBlock)(NSUInteger index);

FOUNDATION_EXTERN float const kKKPSlideMenuHeight;

@interface KKPSlideMenu : UIView

@property (nonatomic, copy) KKPSlideMenuDidSlideToIndexBlock didSlideToIndexBlock;
@property (nonatomic, copy) KKPSlideMenuWillSlideToIndexBlock willSlideToIndexBlock;
@property (nonatomic, readonly) NSArray *menu;
@property (nonatomic, strong) UIScrollView *contentView;

- (instancetype)initWithMenus:(NSArray *)menus;   //<< array of title string  @[@"title1", @"title2", @"title3"]
- (instancetype)initWithMenus:(NSArray *)menus contentView:(UIScrollView *)scrollView;

- (void)setCurrentIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)scrollWithPercentage:(CGFloat)percentage;
@end
