/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPSharePopupWindow.h
 *
 * Description	: 控件，下方弹出框
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface KKPSharePopupWindow : UIWindow

- (instancetype)initWithASharedActivity:(NSArray *)shareActivity actionActivities:(NSArray *)actionActivities;

- (void)show;

- (void)hide;


@end
