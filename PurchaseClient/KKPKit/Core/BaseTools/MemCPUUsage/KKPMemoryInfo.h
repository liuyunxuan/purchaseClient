
#import <Foundation/Foundation.h>

@interface KKPMemoryInfo : NSObject

+ (unsigned long long)totalMemorySize;      ///< 物理内存大小
+ (unsigned long long)availableMemorySize;  ///< 当前可用内存

+ (NSString *)fileSizeToString:(unsigned long long)fileSize; ///< Size格式化, 例如：3.5M，512K


@end
