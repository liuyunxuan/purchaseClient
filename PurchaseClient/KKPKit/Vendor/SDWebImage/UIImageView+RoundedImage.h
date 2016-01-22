//
//  UIImageView+RoundedImage.h
//  Hotspot
//
//  Created by wayne on 15/9/10.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (RoundedImage)
- (void)sd_setRoundedImageWithURL:(NSURL *)url placeholder:(UIImage *)image;
@end


@interface UIButton (RoundedImage)
- (void)sd_setRoundedImageWithURL:(NSURL *)url placeholder:(UIImage *)image;
@end
