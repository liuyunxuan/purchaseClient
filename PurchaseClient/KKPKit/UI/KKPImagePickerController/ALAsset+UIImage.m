/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: ALAsset+Resize.m
 *
 * Description	: ALAsset+Resize
 * https://gist.githubusercontent.com/jder/4331450/raw/cc6b38febbf3217794d5850956dcbd2c253e5e9f/Downscaling%20ALAssets
 *
 * Author		: Singro@ucweb.com
 *
 * History		: Creation, 7/30/15, Singro@ucweb.com, Create the file
 ******************************************************************************
 **/

#import "ALAsset+UIImage.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>


// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

@implementation ALAsset (UIImage)

@dynamic galleryThumbmailImage;

- (UIImage *)galleryThumbmailImage
{
    UIImage *image = objc_getAssociatedObject(self, @selector(galleryThumbmailImage));
    
    if (nil == image) {
        image = [UIImage imageWithCGImage:self.aspectRatioThumbnail];
        self.galleryThumbmailImage = image;
    }
    
    return image;
}

- (void)setGalleryThumbmailImage:(UIImage *)galleryThumbmailImage
{
    objc_setAssociatedObject(self, @selector(galleryThumbmailImage), galleryThumbmailImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)imageWithMaxPixelSize:(NSUInteger)size
{
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    NSDictionary *params =  @{
                              (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                              (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
                              (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                              };
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)params);
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];

    CFRelease(imageRef);
    
    return image;
}

- (UIImage *)fullImage
{
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    
    CGFloat maxPixel = MAX(rep.dimensions.width, rep.dimensions.height);
    
    return [self imageWithMaxPixelSize:maxPixel];
}

@end