//
//  KKPHttpDataPaser.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "KKPHttpDataPaser.h"


static NSString const *kKKPResponseStateKey = @"state";
static NSString const *kKKPResponseCodeKey = @"code";
static NSString const *kKKPResponseDesciptionKey = @"msg";

@implementation KKPHttpDataPaser
- (instancetype)initWithSuccessCode:(NSInteger)code
{
	if (self = [super init]) {
		_retCodeSuccess  = code;
	}

	return self;
}

- (instancetype)init
{
	if (self = [super init]) {
		_retCodeSuccess = KKPHTTPRetCodeSuccess;
	}
	return self;
}

- (instancetype)initWithResponseDictionary:(id)responseObject andSuccessCode:(NSInteger)code
{
	if (self = [self initWithSuccessCode:code]) {
		[self parseResponseDictionary:responseObject];
	}

	return self;
}

/**
 *  将初始化传进来的字典，翻译成Parse类的成员变量
 *
 *  @param responseOrError
 */
- (void)parseResponseDictionary:(id)responseOrError
{
	if (responseOrError == nil) {
		self.retCode = KKPHTTPRetCodeErrEmptyBody;
		self.retDescription = @"NetWorkError:It's a Empty Response Body due to m9 decode error";
		self.dataForm = [self constructErrorDictionaryWithMsg:_retDescription];
		return;
	}

	if ([responseOrError isKindOfClass:[NSData class]]) {
		NSData *responseObject = (NSData *)responseOrError;


		NSError *error;
		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject
		                                                                   options:NSJSONReadingMutableContainers
		                                                                     error:&error];
		if (error) {
			self.retCode = KKPHTTPRetCodeErrBodyParseError;
			self.retDescription = @"NetWorkError:Data parse Error,invalid json string";
			self.dataForm = [self constructErrorDictionaryWithMsg:_retDescription];
			return;
		}

		if (responseDictionary) {
			NSDictionary *state = responseDictionary[kKKPResponseStateKey];
			self.retCode = [state[kKKPResponseCodeKey] integerValue];
			self.retDescription = state[kKKPResponseDesciptionKey];
			self.dataForm = responseDictionary;
		} else {
			self.retCode = KKPHTTPRetCodeErrEmptyBody;
            self.retDescription = @"NetWorkError:Server returns a Empty Body";
			self.dataForm = [self constructErrorDictionaryWithMsg:_retDescription];
		}
	} else {
		NSAssert([responseOrError isKindOfClass:[NSError class]], @"object must be a NSError");
		NSError *error = (NSError *)responseOrError;

		//后续在此，根绝error NSURLErrorDomain，对_retCode进行翻译，现阶段此处全部返回-1

		self.retCode = KKPHTTPNetWorkError;
		self.retDescription = error.description;
		self.dataForm = [self constructErrorDictionaryWithMsg:_retDescription];
	}
}

- (NSDictionary *)constructErrorDictionaryWithMsg:(NSString *)msg
{
	NSDictionary *retDict = @{
                              @"id"    : @(-1),
		                      @"state" : @{
							  @"code"  : @(KKPHTTPNetWorkError),
							  @"msg"   : msg
							   }
	};

	return retDict;
}

@end
