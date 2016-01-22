//
//  KKPHttpDataPaser.h
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, KKPHTTPRequestRetCode)
{
    KKPHTTPRetCodeSuccess = 200,
    KKPHTTPNetWorkError = -1,
    KKPHTTPRetRequestTimeout = -1001,
    KKPHTTPRetCodeErrEmptyBody = 9998,
    KKPHTTPRetCodeErrBodyParseError = 9999
};

@interface KKPHttpDataPaser : NSObject
@property (nonatomic,assign) NSInteger retCodeSuccess;
@property (nonatomic,strong) NSDictionary* dataForm;

@property (nonatomic,assign) NSInteger retCode;
@property (nonatomic,copy)   NSString* retDescription;
@property (nonatomic,strong) NSError* error;
@property (nonatomic,strong) id responseObject;
@property (nonatomic,strong) NSURLResponse* response;

-(instancetype)initWithSuccessCode:(NSInteger)code;
-(instancetype)initWithResponseDictionary:(id)responseOrError andSuccessCode:(NSInteger)code;
@end
