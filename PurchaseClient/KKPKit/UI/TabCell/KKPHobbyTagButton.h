//
//  KKPHobbyTagButton.h
//  Account
//
//  Created by 刘特风 on 15/8/31.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KKPHobbyTagButtonType) {
    KKPHobbyTagButtonTypeNormal,
    KKPHobbyTagButtonTypeDelete,
    KKPHobbyTagButtonTypeAdd,
};

@interface KKPHobbyTagButton : UIButton

@property (nonatomic, strong) UIColor *heightLightColor;

@property (nonatomic, strong) UIColor *boardColor;

@property (nonatomic, assign) KKPHobbyTagButtonType type;

- (void)layoutBaseOnSelfType;


@end
