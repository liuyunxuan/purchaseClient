//
//  NWTestWindow.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/10.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ Action)();


@interface NWTestWindow : UIWindow

/**
 *  点击a按钮执行的行动，因为window持有block，记得不要循环引用
 */
@property (nonatomic, strong) Action actionA;
@property (nonatomic, strong) Action actionB;

+ (Action)action:(Action)action;
@end
