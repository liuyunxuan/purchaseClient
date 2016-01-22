//
//  NWBaseRefreshViewController.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/2.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWBaseRefreshViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic) BOOL showRefreshHeader;//是否支持下拉刷新
@property (nonatomic) BOOL showRefreshFooter;//是否支持上拉加载
//@property (nonatomic) BOOL showBlankImage;   //是否无数据时显示默认背景

- (instancetype)initWithStyle:(UITableViewStyle)style;

/**
 *  代码启动下拉刷新事件，会调用到tableViewDidTriggerHeaderRefresh
 */
- (void)autoTriggerHeaderRefresh;

/**
 *  结束刷新
 *
 *  @param isHeader 结束刷新header还是footer
 *  @param reload   是否reloadData
 */
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload;

/**
 *  重写该函数
 */
- (void)tableViewDidTriggerHeaderRefresh;//下拉刷新事件
- (void)tableViewDidTriggerFooterRefresh;//上拉加载事件


@end
