/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPAssetsLibraryManager.h
 *
 * Description	: KKPAssetsLibraryManager
 *
 * Author		: Singro@ucweb.com
 *
 * History		: Creation, 7/28/15, Singro@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <Foundation/Foundation.h>

@class ALAssetsLibrary;
@interface KKPAssetsLibraryManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;

@end
