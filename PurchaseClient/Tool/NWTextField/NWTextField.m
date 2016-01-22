//
//  NWTextField.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/9.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "NWTextField.h"

@interface NWTextField ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGes;

@end

@implementation NWTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (UITapGestureRecognizer *)tapGes
{
    if (!_tapGes)
    {
    }
    return _tapGes;
}

- (void)hideKeyborad
{
    [self resignFirstResponder];
}

#pragma mark - override
@end
