/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: ALAsset+UIImage.h
 *
 * Description	: ALAsset+UIImage
 *
 * Author		: Singro@ucweb.com
 *
 * History		: Creation, 8/27/15, Singro@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@class G9ImageUploadModel;
@interface ALAsset (UIImage)

@property (nonatomic, strong) UIImage *galleryThumbmailImage;

- (UIImage *)fullImage;

@end
