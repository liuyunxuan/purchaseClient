//
//  PCMineViewController.m
//  PurchaseClient
//
//  Created by  liuyunxuan on 16/1/22.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "PCMineViewController.h"
#import "PCOrderViewController.h"
#import "UIImageView+WebCache.h"
#import "NWLoginViewController.h"

@interface PCMineViewController()<NWLoginViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation PCMineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.avatarImageView sd_setImageWithURL:nil
                            placeholderImage:[UIImage imageNamed:@"Portrait_512px_1187341_easyicon.net"]];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NWLoginViewController *loginVC = [[NWLoginViewController alloc] init];
        loginVC.delegate = self;
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    if (indexPath.row == 1)
    {
        PCOrderViewController *orderVC = [[PCOrderViewController alloc] init];
        [self.navigationController pushViewController:orderVC animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - loginDelegate
- (void)loginDidSuccess
{
    
}
@end
