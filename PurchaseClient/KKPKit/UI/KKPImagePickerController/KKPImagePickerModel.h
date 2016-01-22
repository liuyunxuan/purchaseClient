

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAssetsGroup;
typedef NSUInteger ALAssetsGroupType;
@interface KKPImageAssetsGroup : NSObject

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, copy) NSString *assetsGroupId;
@property (nonatomic, assign) ALAssetsGroupType assetsGroupType;
@property (nonatomic, copy) NSString *assetsGroupName;
@property (nonatomic, copy) NSURL *assetsGroupURL;
@property (nonatomic, assign) NSInteger assetsGroupNumber;
@property (nonatomic, strong) UIImage *assetsGroupPosterImage;

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end
