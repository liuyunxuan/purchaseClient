//
//  UIImageView+RoundedImage.m
//  Hotspot
//
//  Created by wayne on 15/9/10.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//

#import "UIImageView+RoundedImage.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "UIButton+WebCache.h"
UIImage *roundedImage(UIImage *originImage, CGSize oSize)
{
    CGSize size = CGSizeMake(oSize.width * 2, oSize.height * 2);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:6];
    CGPathRef path = rounded.CGPath;
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    
    CGContextClip(context);
    [originImage drawInRect:rect];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

@implementation UIImageView (RoundedImage)

- (void)sd_setRoundedImageWithURL:(NSURL *)url placeholder:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
           placeholderImage:image
                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      NSString *imageKey = [NSString stringWithFormat:@"%@_SDRounded", url.absoluteString];
                      
                      UIImage *roundedImg = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:imageKey];
                      
                      if (roundedImg) {
                          strongSelf.image = roundedImg;
                      } else {
                          dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                          dispatch_async(queue, ^{
                              UIImage *rounded = roundedImage(image, self.frame.size);
                              [[SDWebImageManager sharedManager].imageCache storeImage:rounded forKey:imageKey];
                              dispatch_async(dispatch_get_main_queue(), ^{
//                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  strongSelf.image = rounded;
                              });
                          });
                      }

                  }];
}

@end

@implementation UIButton (RoundedImage)


- (void)sd_setRoundedImageWithURL:(NSURL *)url placeholder:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
                    forState:UIControlStateNormal
            placeholderImage:image
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                       NSString *imageKey = [NSString stringWithFormat:@"%@_SDRounded", url.absoluteString];
                       
                       UIImage *roundedImg = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:imageKey];
                       
                       if (roundedImg) {
                            [strongSelf setImage:roundedImg forState:UIControlStateNormal];
                       } else {
                           dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                           dispatch_async(queue, ^{
                               UIImage *rounded = roundedImage(image, self.frame.size);
                               [[SDWebImageManager sharedManager].imageCache storeImage:rounded forKey:imageKey];
                               dispatch_async(dispatch_get_main_queue(), ^{
//                                   __strong typeof(weakSelf) strongSelf = weakSelf;
                                   [strongSelf setImage:rounded forState:UIControlStateNormal];
                               });
                           });
                       }
                   }];

}

@end
