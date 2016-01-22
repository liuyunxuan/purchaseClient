/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPShareActivity.h
 *
 * Description	: 自定义分享item
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <UIKit/UIKit.h>
#import "KKPShareBaseActivity.h"

extern NSString * const WeChatFriendsActivityType;
extern NSString * const WeChatLifeTimeActivityType;
extern NSString * const SinaWeiBoActivityType;
extern NSString * const TencentFriendActivityType;
extern NSString * const TencentQQZoneActivityType;
extern NSString * const KKPLocalIMActivityType;



@interface WeChatFriendsActivity : KKPShareBaseActivity

@end

@interface WeChatLifeTimeActivity : KKPShareBaseActivity

@end


@interface SinaWeiBoActivity : KKPShareBaseActivity

@end

@interface TencentFriendActivity : KKPShareBaseActivity

@end

@interface TencentQQZoneActivity : KKPShareBaseActivity

@end

@interface KKPLocalIMActivity : KKPShareBaseActivity

@end

@interface KKPShareCopyUrlActivity : KKPShareBaseActivity

@end

@interface KKPShareRefreshActivity : KKPShareBaseActivity

@end

@interface KKPShareMessageActivity : KKPShareBaseActivity

@end


@interface KKPshareSquareActivity : KKPShareBaseActivity

@end