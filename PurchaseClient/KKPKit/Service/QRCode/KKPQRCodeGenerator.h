//
//  KKPQRCodeGenerator.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/7.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KKPQRCodeGeneratorCompeteBlock) (UIImage *image);

@interface KKPQRCodeGenerator : NSObject

@property (nonatomic, strong) UIColor *qrCodeColor;
@property (nonatomic, assign) CGFloat qrCodeSize;
@property (nonatomic, strong) NSString *qrString;


- (void)setDefauld;
- (void)buildInBackGroundThreadComplete:(KKPQRCodeGeneratorCompeteBlock)complete;
- (UIImage *)build;
- (UIImage *)buildWithString:(NSString *)string;


+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
+ (CIImage *)createQRForString:(NSString *)qrString;
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;


@end
