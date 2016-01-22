/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPshareBaseActivity
 *
 * Description	: KKPShare
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import "KKPshareBaseActivity.h"

#define lableFont [UIFont systemFontOfSize:11.0]
#define LogoHeight 60.0
#define LableWidth LogoHeight
static const CGFloat LogoTitleSpace = 7;
static const CGFloat LableHeiht = 11;
#define ActivityHeight (LogoHeight + LableHeiht + LogoTitleSpace)


#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

@interface KKPShareBaseActivity ()

@property (nonatomic, strong) UIButton *logo;
@property (nonatomic, strong) UILabel *title;

@end

@implementation KKPShareBaseActivity

- (instancetype)init
{
    if (self = [super initWithFrame:(CGRect){0, 0, LableWidth, (LogoHeight + LogoTitleSpace + LableHeiht)}]) {
        [self configUI];
        if ([self activityImageNormal]) {
            [self.logo setBackgroundImage:[self activityImageNormal] forState:UIControlStateNormal];
        }
        if ([self activityImageClick]) {
            [self.logo setBackgroundImage:[self activityImageClick] forState:UIControlStateSelected];
        }
        self.logo.enabled = [self buttonEnable];
        [self.title setText:[self activityTitle]];
        self.title.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel
{
    [self.logo setAccessibilityLabel:accessibilityLabel];
}

- (void)configUI
{
    self.logo = [[UIButton alloc] initWithFrame:(CGRect){1, 0, LogoHeight, LogoHeight}];
    [self.logo addTarget:self action:@selector(logoClick:) forControlEvents:UIControlEventTouchUpInside];
    self.logo.layer.cornerRadius = 5.0;
    self.logo.userInteractionEnabled = YES;
    
    self.title = [[UILabel alloc] initWithFrame:(CGRect){0, LogoHeight + LogoTitleSpace, LableWidth, LableHeiht}];
    self.title.font = lableFont;
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.numberOfLines = 2;
    self.title.textColor = RGB(0x999999, 1.0);
    
    [self addSubview:self.logo];
    [self addSubview:self.title];
}
                                
- (void)logoClick:(id)sender
{
    NSLog(@"click");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.61 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self performActivity];
    });
    if (self.block) {
        self.block();
    }
}

- (NSString *)activityTitle
{
    return nil;
}

- (UIImage *)activityImageNormal
{
    return nil;
}
- (UIImage *)activityImageClick
{
    return nil;
}

- (UIViewController *) activityViewController {
    return nil;
}

- (void) performActivity {
  
}

- (BOOL)buttonEnable
{
    return YES;
}

@end





