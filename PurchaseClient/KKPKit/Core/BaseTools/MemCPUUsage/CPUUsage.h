
#import <Foundation/Foundation.h>

@interface KKPCPUUsage : NSObject

+ (KKPCPUUsage *)sharedInstance;

//返回0--1之间的值  获取当前进程的CPU利用率
- (float)currentProccessCPUUsage;

//返回0--1之间的值  获取当前机器的CPU利用率
- (float)totalCPUUsage;

//返回CPU核心数
- (NSUInteger)CPUCores;

@end
