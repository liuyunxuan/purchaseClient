

#import "KKPImagePickerModel.h"

#import <AssetsLibrary/AssetsLibrary.h>

@implementation KKPImageAssetsGroup

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.assetsGroup = assetsGroup;
    self.assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] integerValue];
    self.assetsGroupId = [assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    self.assetsGroupURL = [assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    self.assetsGroupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.assetsGroupNumber = assetsGroup.numberOfAssets;
    self.assetsGroupPosterImage = [UIImage imageWithCGImage:assetsGroup.posterImage];

    return self;

}

@end