

#import "KKPSettings.h"
#import "NSObject+KKPaddition.h"

//#define VERSION_UPGRADE     ///< 初次使用加密时，解码未加密数据会出现异常，今后稳定后可以删除


@interface KKPEncryptedDefaults : NSUserDefaults

@end

@implementation KKPEncryptedDefaults

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [super setObject:value forKey:defaultName];
}

- (id)objectForKey:(NSString *)defaultName
{

    
    return [super objectForKey:defaultName];
}

@end

@implementation NSUserDefaults (Encryption)

+ (NSUserDefaults *)encryptedUserDefaults
{
    [NSUserDefaults standardUserDefaults];			// 第一次调用该方法时会自动添加一些系统默认的字段
    
    static KKPEncryptedDefaults * encryptedInstance = nil;
    if (nil == encryptedInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            encryptedInstance = [[KKPEncryptedDefaults alloc] init];
        });
    }
    
    return encryptedInstance;
}

@end

@implementation KKPSettings

+ (KKPSettings *)sharedInstance
{
    static KKPSettings * g_instance = nil;
    if (nil == g_instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            g_instance = [[KKPSettings alloc] init];
        });
    }
    
    return g_instance;
}

#pragma mark -基础方法
- (id)objectForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] objectForKey:defaultName];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setObject:value forKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] removeObjectForKey:defaultName];
}

#pragma mark -获取设置项
- (NSString *)stringForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] stringForKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] arrayForKey:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] dictionaryForKey:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] dataForKey:defaultName];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] stringArrayForKey:defaultName];
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] integerForKey:defaultName];
}

- (float)floatForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] floatForKey:defaultName];
}

- (double)doubleForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] doubleForKey:defaultName];
}

- (BOOL)boolForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] boolForKey:defaultName];
}

- (NSURL *)URLForKey:(NSString *)defaultName
{
    return [[NSUserDefaults encryptedUserDefaults] URLForKey:defaultName];
}


#pragma mark -存储设置项
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setInteger:value forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setFloat:value forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setDouble:value forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setBool:value forKey:defaultName];
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName
{
    [[NSUserDefaults encryptedUserDefaults] setURL:url forKey:defaultName];
}


- (BOOL)synchronize
{
    return [[NSUserDefaults encryptedUserDefaults] synchronize];
}



@end
