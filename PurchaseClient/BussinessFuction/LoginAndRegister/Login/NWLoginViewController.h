//
//  NWLoginViewController.h
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/9.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NWLoginViewControllerDelegate <NSObject>

@optional

- (void)loginDidSuccess;

@end

@interface NWLoginViewController : UIViewController

@property (nonatomic, weak) id<NWLoginViewControllerDelegate>delegate;

@end
