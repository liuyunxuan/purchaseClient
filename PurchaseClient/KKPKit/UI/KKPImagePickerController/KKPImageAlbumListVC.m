

#import "KKPImageAlbumListVC.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIViewController+SCNavigation.h"
#import "FrameAccessor.h"
#import "KKPTableViewCell.h"
#import "KKPTableViewCell+Private.h"

#import "KKPImagePickerModel.h"

#import "KKPImageGalleryVC.h"


@interface KKPImageAlbumListVC () //<UITableViewDelegate, UITableViewDataSource>


@end

@implementation KKPImageAlbumListVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    

    return self;

}

- (void)loadView {
    [super loadView];
    

}


#pragma mark - Data

- (void)setAlbumList:(NSArray *)albumList {
    _albumList = albumList;
    
    NSMutableArray *dataList = [NSMutableArray new];
    for (KKPImageAssetsGroup *group in albumList) {
        [dataList addObject:[self dataDictWithGroupModel:group]];
    }
    self.dataList = @[dataList];
    [self.tableView reloadData];
}

- (NSDictionary *)dataDictWithGroupModel:(KKPImageAssetsGroup *)group {
    return @{
             KKPTableViewCellStyleName: @(KKPTableViewCellStyleImageLarge|KKPTableViewCellStyleSubtitle),
             KKPTableViewCellRightStyleName: @(KKPTableViewCellRightStyleDisclosure),
             KKPTableViewCellSubtitleName: [NSString stringWithFormat:@"%zd", group.assetsGroupNumber],
             KKPTableViewCellTitleName: group.assetsGroupName ?: @"",
             KKPTableViewCellImageURLName: group.assetsGroupPosterImage ?: [UIImage new],
             };
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KKPTableViewCell *cell = (KKPTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[KKPTableViewCell class]]) {
        cell.avatarImageView.layer.cornerRadius = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KKPImageAssetsGroup *group = self.albumList[indexPath.row];
    KKPImageGalleryVC *galleryVC = [[KKPImageGalleryVC alloc] init];
    galleryVC.picker = (KKPImagePickerController *)self.navigationController;
    galleryVC.assetsGroup = group;
    [self.navigationController pushViewController:galleryVC animated:YES];
    
}

@end
