//
//  KKPURLProtocol.m
//  KKPKit
//
//  Created by 刘特风 on 16/1/9.
//  Copyright © 2016年 kakapo. All rights reserved.
//

#import "KKPURLProtocol.h"

@interface KKPURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSURLConnection* connection;

@end

@implementation KKPURLProtocol


+ (void)registerProtocol
{
    [NSURLProtocol registerClass:[self class]];
}


#pragma marl - 子类重写

+ (BOOL)needToHandleByCustomForRequest:(NSURLRequest *)request
{
    return NO;
}


#pragma mark - handle 


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString* requestString = [[request URL]absoluteString];
    
    if (!requestString.length>0) {
        return NO;
    }
    
    BOOL flag = [self needToHandleByCustomForRequest:request];
    return flag;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust
                                                    delegate:self];
}
- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self
            didFailWithError:error];
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self
didReceiveAuthenticationChallenge:challenge];
}
- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self
didCancelAuthenticationChallenge:challenge];
}
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:(NSUInteger)[[self request] cachePolicy]];
}
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self
                 didLoadData:data];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}




@end
