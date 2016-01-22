

//
//  PCOrderViewController.m
//  PurchaseClient
//
//  Created by  liuyunxuan on 16/1/22.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "PCOrderViewController.h"
#import "PCOrderCollectionViewCell.h"
@interface PCOrderViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *orderArray;
@end

static NSString * const kIdentifier_cell = @"PCOrderViewCell";

@implementation PCOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init getter
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.frame.size.width, 60);
        layout.minimumLineSpacing = 10;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_collectionView registerClass:[PCOrderCollectionViewCell class] forCellWithReuseIdentifier:kIdentifier_cell];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

-(NSMutableArray *)orderArray
{
    if (!_orderArray)
    {
        _orderArray = [NSMutableArray array];
        [_orderArray addObjectsFromArray:@[@"d",@"d",@"d",@"d"]];
    }
    return _orderArray;
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.orderArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCOrderCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier_cell forIndexPath:indexPath];
    
    return cell;
}
#pragma mark - UICollectionViewDelegate
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
