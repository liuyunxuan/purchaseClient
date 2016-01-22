//
//  KKPAFWrapper.m
//  KKPKit
//
//  Created by 刘特风 on 15/12/31.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "KKPAFPostWrapper.h"
#import "AFNetworking.h"
#import "NSString+KKPaddition.h"
#import "KKPURLCache.h"
#import "KKPHttpDataPaser.h"
#import "KKPSessionTask.h"
#import "AFURLRequestSerialization.h"

static NSTimeInterval KKPHttpRequestTimeOut = 30.f;
static NSUInteger   kKKPMaxRequestPerHost = 3;

#define IS_OS_GREATER_THAN_8 [[[UIDevice currentDevice]systemVersion]doubleValue]>=8.0

typedef NSCachedURLResponse * (^DataTaskWillCacheResponseBlock)(NSURLSession *session,
                                                                NSURLSessionDataTask *dataTask,
                                                                NSCachedURLResponse *proposedResponse) ;

@interface KKPAFPostWrapper ()

@property (nonatomic, strong) NSString *url_string;
@property (nonatomic, strong) NSDictionary *params_dict;
@property (nonatomic, copy) KKPHttpSuccessBlock success_block;
@property (nonatomic, copy) KKPHttpFailureBlock fail_block;
@property (nonatomic, assign) KKPURLCachePolicy cachePolicy_integer;

@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation KKPAFPostWrapper

- (KKPAFPostWrapper *(^)(NSString *url))requestUrl
{
    return ^KKPAFPostWrapper *(NSString *url) {
        self.url_string = url;
        return self;
    };
}
- (KKPAFPostWrapper *(^)(NSDictionary *params))params
{
    return ^KKPAFPostWrapper *(NSDictionary *params) {
        self.params_dict = params;
        return self;
    };
}

- (KKPAFPostWrapper *(^)(KKPURLCachePolicy cachePolicy))cahcePolicy
{
    return ^KKPAFPostWrapper *(KKPURLCachePolicy cachePolicy) {
        self.cachePolicy_integer = cachePolicy;
        return self;
    };
}

- (void)getWithSuccess:(KKPHttpSuccessBlock)success fail:(KKPHttpFailureBlock)fail
{
    [self requestWithMethod:@"GET" url:self.url_string params:self.params_dict cachePolicy:KKPURLCachePolicyNeverCache success:success fail:fail];
}
- (void)postWithSuccess:(KKPHttpSuccessBlock)success fail:(KKPHttpFailureBlock)fail
{
    [self requestWithMethod:@"POST" url:self.url_string params:self.params_dict cachePolicy:KKPURLCachePolicyNeverCache success:success fail:fail];
}


- (void)requestWithMethod:(NSString *const)method
                      url:(NSString *)url_string
                   params:(NSDictionary *)param
              cachePolicy:(KKPURLCachePolicy)cachePolicy
                  success:(KKPHttpSuccessBlock)success
                     fail:(KKPHttpFailureBlock)fail
{
    self.success_block = success;
    self.fail_block = fail;
    if (self.url_string.length <= 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:url_string];
    NSMutableURLRequest* request = [self makeRequestWithHTTPMethod:method param:param url:url];
    NSString* cacheId = [self makeCacheId:self.params_dict];
    request.timeoutInterval = KKPHttpRequestTimeOut/2;
    [request setValue:cacheId forHTTPHeaderField:[NSString stringWithFormat:@"%@", kKKPSessionCacheId]];
    
    if (cachePolicy==KKPURLCachePolicyNeverCache) {
        [request setValue:[kKKPCachePolicyNeverCache copy] forHTTPHeaderField:[kKKPCachePolicyKey copy]];
    }

    
    NSURLSessionDataTask *dataTask = [[self getSessionManager] dataTaskWithRequest:request
                                                                 completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if ( error == nil) {
            NSData* responseBody = [self serializeResponseBody:responseObject];
            KKPHttpDataPaser* parser = [[KKPHttpDataPaser alloc] initWithResponseDictionary:responseBody
                                                                           andSuccessCode:self.dataParser.retCodeSuccess];
            if ( parser.retCode == self.dataParser.retCodeSuccess ) {
                success(response, parser.dataForm);
            } else {
                KKPHttpRequestError* kerror = [self parseRequestErrorWithParser:parser type:kKKPHttpBizError];
                fail(kerror, response);
            }
        }else {
            KKPHttpDataPaser* parser = [[KKPHttpDataPaser alloc] initWithResponseDictionary:error andSuccessCode:self.dataParser.retCodeSuccess];
            
            KKPHttpRequestError* kerror = [self parseRequestErrorWithParser:parser type:kKKPHttpNetWorkError];
            fail(kerror, response);

        }
        
    }];
    self.task = dataTask;
    [dataTask resume];
}

- (void)cancel
{
    if (self.task) {
        [self.task cancel];
    }
}

#pragma mark - private

static AFURLSessionManager* sessionManager = nil;


- (AFURLSessionManager*)getSessionManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        //NSURLCache在ios7下缓存的bug，暂时区分处理
        if (IS_OS_GREATER_THAN_8) {
            [config setRequestCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        }
        else
        {
            [config setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
        }
        
        [config setAllowsCellularAccess:YES];
        [config setURLCache:[[KKPURLCache alloc]init]];
        [config setHTTPMaximumConnectionsPerHost:kKKPMaxRequestPerHost];
        sessionManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        DataTaskWillCacheResponseBlock cacheResponseBlock = ^NSCachedURLResponse *(NSURLSession *session,
                                                                                   NSURLSessionDataTask *dataTask,
                                                                                   NSCachedURLResponse *proposedResponse) {
            
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
            //设置过期时间
            KKPSessionTask* sessionTask = [[KKPSessionTask alloc]initWithSessionTask:dataTask];
            NSNumber* num = sessionTask.cacheExpirationTime;
            NSString* cacheId = sessionTask.cacheId;
            if ( num != nil && ![num isEqual:@(0)] ) {
                userInfo[kKKPCacheExpirationKey] = [NSDate dateWithTimeIntervalSinceNow:num.floatValue];
                userInfo[kKKPSessionCacheId] = cacheId;
            }
            else
            {
                return nil;
            }
            
            NSCachedURLResponse* newCachedURLResonse = [[NSCachedURLResponse alloc] initWithResponse:proposedResponse.response
                                                                                                data:proposedResponse.data
                                                                                            userInfo:userInfo
                                                                                       storagePolicy:NSURLCacheStorageAllowed];
            
            return newCachedURLResonse;
        };
        
        [sessionManager setDataTaskWillCacheResponseBlock:cacheResponseBlock];
    });
    
    return sessionManager;
}

//- (AFURLSessionManager*)getSessionManager
//{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    return manager;
//}




- (NSMutableURLRequest*)makeRequestWithHTTPMethod:(NSString const*)method param:(NSDictionary*)param url:(NSURL*)url
{
    NSMutableURLRequest* request;
    if (!param) {
        param = @{};
    }
    
    if ( [method isEqualToString:@"GET"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"]) {
        NSString* newUrlStr = [self appendParam:param withBaseUrl:url];
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:newUrlStr]];
        request.HTTPMethod = [[NSString alloc]initWithFormat:@"%@",method];
    }
    else if ( [method isEqualToString:@"POST"])
    {
//        request = [[NSMutableURLRequest alloc]initWithURL:url];
//        request.HTTPMethod = @"POST";
//        request.HTTPBody = [self serializePostBody:param];
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        NSError *serializationError = nil;
        request = [serializer requestWithMethod:@"POST" URLString:url.absoluteString parameters:param error:&serializationError];
//        NSError *error = [[NSError alloc] init];
//        request = [serializer requestWithMethod:@"POST" URLString:url.absoluteString parameters:param error:&error];
        
    }
    
    [request setTimeoutInterval:KKPHttpRequestTimeOut];
    
    return  request;
}

- (KKPHttpRequestError *)parseRequestErrorWithParser:(KKPHttpDataPaser *)parser type:(KKPHttpRequestErrorType)type
{
    KKPHttpRequestError* error = [[KKPHttpRequestError alloc] init];
    error.errType = type;
    error.errCode = parser.retCode;
    error.errMessage = parser.retDescription;
    error.error = parser.dataForm;
    
    return error;
}


#pragma Utils
- (NSString *)appendParam:(NSDictionary*)param withBaseUrl:(NSURL*)url
{
    if (param == nil || param.count==0) {
        return [NSString stringWithString:url.absoluteString];
    }
    
    NSMutableString* queryString = [[NSMutableString alloc]init];
    [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [queryString appendFormat:@"%@=%@&",(NSString*)key,(NSString*)obj];
    }];
    [queryString replaceCharactersInRange:NSMakeRange(queryString.length-1, 1) withString:@""];
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [url absoluteString],
                           [url query] ? @"&" : @"?", queryString];
    return URLString;
    
}

- (NSString *)makeCacheId:(NSDictionary*)param
{
    NSDictionary* paramBefore;
    if (param==nil) {
        paramBefore = @{};
    }
    else
    {
        paramBefore = [param copy];
    }
    NSData* dataParam = [NSJSONSerialization dataWithJSONObject:paramBefore options:NSJSONWritingPrettyPrinted error:nil];
    NSData* baseData = [dataParam base64EncodedDataWithOptions:0];
    NSString* ret = [[NSString alloc]initWithData:baseData encoding:NSUTF8StringEncoding];
    ret = ret.MD5;
    return ret;
}

#pragma customed serialize post body
- (NSData *)serializePostBody:(NSDictionary *)param
{
    return [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)serializeResponseBody:(NSData *)paramData
{
    return paramData;
}



@end
