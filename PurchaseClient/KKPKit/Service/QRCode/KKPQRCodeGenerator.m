//
//  KKPQRCodeGenerator.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/7.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "KKPQRCodeGenerator.h"
static const CGFloat kKKPQRCodeRed = 60.0f/255.0f;
static const CGFloat kKKPQRCodeGreen = 74.0f/255.0f;
static const CGFloat kKKPQRCodeBlue = 89.0f/255.0f;
static const CGFloat kKKPQRCodeGeneratorDefaultSize = 180.f;



@interface KKPQRCodeGenerator ()

@end


@implementation KKPQRCodeGenerator

- (instancetype)init
{
    if (self = [super init]) {
        _qrCodeColor = [UIColor colorWithRed:kKKPQRCodeRed green:kKKPQRCodeGreen blue:kKKPQRCodeBlue alpha:1];
        _qrCodeSize = kKKPQRCodeGeneratorDefaultSize;
    }
    return self;
}


- (void)setDefauld
{
    self.qrCodeColor = [UIColor colorWithRed:kKKPQRCodeRed green:kKKPQRCodeGreen blue:kKKPQRCodeBlue alpha:1];
    self.qrCodeSize = kKKPQRCodeGeneratorDefaultSize;
}
- (UIImage *)build
{
    if (!self.qrString || self.qrString.length == 0) {
        return nil;
    }
    
    return [self buildWithString:self.qrString];
}

- (void)buildInBackGroundThreadComplete:(KKPQRCodeGeneratorCompeteBlock)complete
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self build];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(image);
            }
        });
    });
}

- (UIImage *)buildWithString:(NSString *)string
{
    CIImage *image = [KKPQRCodeGenerator createQRForString:string];
    UIImage *qrCode = [KKPQRCodeGenerator createNonInterpolatedUIImageFormCIImage:image withSize:self.qrCodeSize];
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [self.qrCodeColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    qrCode = [KKPQRCodeGenerator imageBlackToTransparent:qrCode withRed:red*255.0f andGreen:green*255.0f andBlue:blue*255.0f];
    return qrCode;
}

#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
static void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


@end
