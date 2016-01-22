//
//  PCOrderCollectionViewCell.m
//  PurchaseClient
//
//  Created by  liuyunxuan on 16/1/22.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "PCOrderCollectionViewCell.h"

@implementation PCOrderCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PCOrderCollectionViewCell" owner:self options:nil] firstObject];
    self.backgroundColor = [UIColor whiteColor];
    if (self)
    {
        
    }
    return self;
}

@end
