//
//  NWNaviTabBar.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/2.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NWNaviTabBar,NWNaviTabBarItem;

@protocol NWNaviTabBarDelegate <NSObject>

/**
 * Asks the delegate if the specified tab bar item should be selected.
 */
- (BOOL)tabBar:(NWNaviTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBar:(NWNaviTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@end

@interface NWNaviTabBar : UIView

/**
 * The tab bar’s delegate object.
 */
@property (nonatomic, weak) id <NWNaviTabBarDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, weak) NWNaviTabBarItem *selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views,
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIView *backgroundView;

/*
 * contentEdgeInsets can be used to center the items in the middle of the tabBar.
 */
@property UIEdgeInsets contentEdgeInsets;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/**
 * Returns the minimum height of tab bar's items.
 */
- (CGFloat)minimumContentHeight;

/*
 * Enable or disable tabBar translucency. Default is NO.
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent;

@end
