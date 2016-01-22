/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPShareActivity.h
 *
 * Description	: KKPShare
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import "KKPShareActivity.h"


#if !(TARGET_IPHONE_SIMULATOR)
#import <MessageUI/MessageUI.h>
#endif

NSString * const WeChatFriendsActivityType  = @"WeChatFriendsActivityType";
NSString * const WeChatLifeTimeActivityType = @"WeChatLifeTimeActivityType";
NSString * const SinaWeiBoActivityType      = @"SinaWeiBoActivityType";
NSString * const TencentFriendActivityType  = @"TencentFriendActivityType";
NSString * const TencentQQZoneActivityType  = @"TencentQQZoneActivityType";
NSString * const KKPLocalIMActivityType      = @"KKPLocalIMActivityType";


//微信好友
@implementation WeChatFriendsActivity


- (NSString *)activityType
{
    return WeChatFriendsActivityType;
}

- (NSString *)activityTitle
{
    return @"微信好友";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
  
}

@end

//微信朋友圈
@implementation WeChatLifeTimeActivity


- (NSString *)activityType
{
    return WeChatLifeTimeActivityType;
}

- (NSString *)activityTitle
{
    return @"朋友圈";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
    
}

@end

//sina微博
@implementation SinaWeiBoActivity


- (NSString *)activityType
{
    return SinaWeiBoActivityType;
}

- (NSString *)activityTitle
{
    return @"微博";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
    
  
}

@end


//腾讯qq好友
@implementation TencentFriendActivity


- (NSString *)activityType
{
    return TencentFriendActivityType;
}

- (NSString *)activityTitle
{
    return @"QQ好友";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
    
}

@end



//腾讯qq空间
@implementation TencentQQZoneActivity

- (NSString *)activityType
{
    return TencentQQZoneActivityType;
}

- (NSString *)activityTitle
{
    return @"QQ空间";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
    

}



@end

//九游好友
@implementation KKPLocalIMActivity

- (NSString *)activityType
{
    return KKPLocalIMActivityType;
}

- (NSString *)activityTitle
{
    return @"九游好友";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
    
}
@end

@implementation KKPShareCopyUrlActivity

- (NSString *)activityTitle
{
    return @"复制链接";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *) activityViewController
{
    return nil;
}

- (void) performActivity
{

}

@end


@implementation KKPShareRefreshActivity

- (NSString *)activityTitle
{
    return @"刷新";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *) activityViewController
{
    return nil;
}

- (void) performActivity
{
    
}

@end


@implementation  KKPShareMessageActivity

- (NSString *)activityTitle
{
    return @"短信分享";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *) activityViewController
{
    return nil;
}

- (void) performActivity
{
    
}

#pragma mark - private

-(void)displaySMSComposerSheetWithBodyString:(NSString *)body
{
}

@end

@implementation KKPshareSquareActivity

- (NSString *)activityTitle
{
    return @"动态";
}

- (UIImage *)activityImageNormal
{
    return [UIImage imageNamed:@"ico_share_pengyouquan"];
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *) activityViewController
{
    return nil;
}

- (void) performActivity
{
 
}



@end

