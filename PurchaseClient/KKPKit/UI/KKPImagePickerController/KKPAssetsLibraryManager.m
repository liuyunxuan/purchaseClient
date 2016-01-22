

#import "KKPAssetsLibraryManager.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface KKPAssetsLibraryManager ()

@property (nonatomic, readwrite) ALAssetsLibrary *assetsLibrary;

@end

@implementation KKPAssetsLibraryManager

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];

    return self;

}

+ (instancetype)sharedManager {
    static KKPAssetsLibraryManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[KKPAssetsLibraryManager alloc] init];
    });
    
    return _sharedManager;
}

@end
