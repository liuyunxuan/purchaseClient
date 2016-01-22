/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: KKPSharePopupWindow
 *
 * Description	: KKPShare
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import "KKPSharePopupWindow.h"
#import "KKPShareBaseActivity.h"
#import "UIImage+REFrosted.h"
#import "UIView+REFrosted.h"
#import "KKPSharePageControl.h"
#import <math.h>

static const CGFloat LogoImgWidth                 = 60.0;
static const CGFloat LogoImgHeight                = LogoImgWidth;
static const CGFloat LogoTopSpace                 = 15;
static const CGFloat LogoTitleSpace               = 7;
static const CGFloat LogoVerticalSpace            = 10;
static const CGFloat TitleLabelHeight             = 11;
static const CGFloat IndicateHeight               = 5;
static const CGFloat IndicateButtomSpace          = 5;
static const CGFloat BottomViewSpace              = 45;
static const CGFloat CancelButtonWidth            = 30;
static const CGFloat CancelButtonHeight           = CancelButtonWidth;

static const CGFloat MaskViewHeight               = 258;

static const NSTimeInterval ItemAnimationInterval = 0.04;
static const NSTimeInterval ItemDuration          = 0.4;

#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define LogoHorizonSpace ((ScreenWidth - 3 * LogoImgWidth)/4)

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

CGSize ItemSize(){
    return (CGSize){LogoImgWidth, LogoImgHeight + LogoTitleSpace + TitleLabelHeight};
};

@interface KKPSharePopupWindow () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *itemList;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *btn_cancel;
@property (nonatomic, strong) NSMutableArray *scrollviewsArray;
@property (nonatomic, strong) UIImageView *blurBackGround;
@property (nonatomic, strong) UIView *interateView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, assign) NSInteger currentIndex;


@end

NSInteger myCeil(NSInteger a, NSInteger b)
{
    return (a + b - 1) / b;
}


@implementation KKPSharePopupWindow


#pragma mark - public method

- (instancetype)initWithASharedActivity:(NSArray *)shareActivity actionActivities:(NSArray *)actionActivities
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]){
        _itemList = [[NSMutableArray alloc] init];
        for (KKPShareBaseActivity *item in shareActivity) {
            [_itemList addObject:item];
        }
        for (KKPShareBaseActivity *item in actionActivities) {
            [_itemList addObject:item];
        }
    }
    return self;
}


- (void)show
{
    NSInteger ItemInPageCount = MIN(6, self.itemList.count);
    NSTimeInterval totalTime = (ItemInPageCount - 1) * ItemAnimationInterval + ItemDuration;
    self.pageControl.currentPage = 0;
    
    void (^showBlock)() = ^{
        for (int i=0; i < ItemInPageCount; i++) {
            CGFloat centerX = ((KKPShareBaseActivity *)self.itemList[i]).center.x;
            CGFloat centerY = ((KKPShareBaseActivity *)self.itemList[i]).center.y + MaskViewHeight;
            ((KKPShareBaseActivity *)self.itemList[i]).center = (CGPoint){centerX, centerY};
            [UIView animateWithDuration:ItemDuration
                                  delay:(i * ItemAnimationInterval)
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 KKPShareBaseActivity *temp = self.itemList[i];
                                 ((KKPShareBaseActivity *)self.itemList[i]).center = (CGPoint){temp.center.x, temp.center.y - MaskViewHeight};
                             }
                             completion:nil];
        }
        self.interateView.alpha = 0.0;
        self.blurBackGround.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.blurBackGround.alpha = 1;
        }];
        [UIView animateWithDuration:totalTime animations:^{
            self.interateView.alpha = 1;
        }];
        [self.btn_cancel.layer removeAllAnimations];
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI];
        rotationAnimation.duration = 0.4;
        rotationAnimation.cumulative = YES;
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        [self.btn_cancel.layer addAnimation:rotationAnimation forKey:@"totation"];
    };
    
    __block UIImage *image;
    image = [[UIApplication sharedApplication].keyWindow re_screenshot];
    [self makeKeyAndVisible];   ///<先让window出现。 防止因为时间差按钮被点击多次
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        image = [image re_applyBlurWithRadius:7.0
                                    tintColor:[UIColor colorWithWhite:1 alpha:0.85f]
                        saturationDeltaFactor:1.8
                                    maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configAllUI];
            [self.blurBackGround setImage:image];
            showBlock();
        });
    });
}

- (void)hide
{
    [self dismissWithAnimation];
}

#pragma mark - lifeCircle




#pragma mark - private method
- (void)dismissWithAnimation
{
    [self.btn_cancel.layer removeAllAnimations];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self.btn_cancel.layer addAnimation:rotationAnimation forKey:@"totation"];
    
    NSInteger ItemInPageCount = MIN(6, self.itemList.count);
    NSTimeInterval totalTime = (ItemInPageCount - 1) * ItemAnimationInterval + ItemDuration;
    for (int i=0; i < MIN(6, self.itemList.count - self.currentIndex * ItemInPageCount); i++) {
        
        [UIView animateWithDuration:ItemDuration
                              delay:((ItemInPageCount - 1 -i) * ItemAnimationInterval)
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGFloat destinationX = ((KKPShareBaseActivity *)self.itemList[i + self.currentIndex * ItemInPageCount]).center.x;
                             CGFloat destinationY = ((KKPShareBaseActivity *)self.itemList[i + self.currentIndex * ItemInPageCount]).center.y + MaskViewHeight;
                             ((KKPShareBaseActivity *)self.itemList[i+self.currentIndex * ItemInPageCount]).center = (CGPoint){destinationX, destinationY};
                         } completion:nil];
        
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.buttonContainer.alpha = 0;
    }];
    [UIView animateWithDuration:totalTime animations:^{
        self.interateView.alpha = 0;
        self.pageControl.alpha = 0;
        self.blurBackGround.alpha = 0;
    } completion:^(BOOL finished) {
        [self resignKeyWindow];
        [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
        for (int i=0; i < ItemInPageCount; i++) {
            CGFloat destinationX = ((KKPShareBaseActivity *)self.itemList[i]).center.x;
            CGFloat destinationY = ((KKPShareBaseActivity *)self.itemList[i]).center.y - MaskViewHeight;
            ((KKPShareBaseActivity *)self.itemList[i]).center = (CGPoint){destinationX, destinationY};
        }
        NSLog(@"window Count : %@", @([UIApplication sharedApplication].windows.count));
    }];
}

- (void)configAllUI
{
    [self configInteratieView];
    [self configMaskView];
    [self configScrollView];
    [self.maskView bringSubviewToFront:_buttonContainer];
    [self.maskView bringSubviewToFront:_pageControl];
}

- (void)configInteratieView
{
    self.interateView = [[UIView alloc] initWithFrame:self.bounds];
    [self.interateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
    self.interateView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self addSubview:self.interateView];
}

- (void)cancelButtonClick:(id)sender
{
    [self dismissWithAnimation];
}

- (void)configScrollView
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = (CGRect){0, 0, ScreenWidth, MaskViewHeight};
    self.scrollView.contentSize = (CGSize){(myCeil(self.itemList.count, 6)) * ScreenWidth, MaskViewHeight};
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.clipsToBounds = YES;
    [self.maskView addSubview:self.scrollView];
    for (int i=0; i < self.itemList.count; i++) {
        CGFloat x = LogoHorizonSpace + (i % 3) * (LogoHorizonSpace + LogoImgWidth) + (ScreenWidth) * (i / 6);
        NSInteger row = (i / 3) % 2;
        CGFloat y = LogoTopSpace + (((KKPShareBaseActivity *)self.itemList[i]).bounds.size.height + LogoVerticalSpace) * row;
        ((KKPShareBaseActivity *)self.itemList[i]).frame = (CGRect){x, y, ((KKPShareBaseActivity *)self.itemList[i]).bounds.size};
        ((KKPShareBaseActivity *)self.itemList[i]).block = ^(){
            [self dismissWithAnimation];
        };
        [self.scrollView addSubview:((KKPShareBaseActivity *)self.itemList[i])];
    }
    
    CGFloat pageCTempY = MaskViewHeight - BottomViewSpace - IndicateButtomSpace - IndicateHeight;
    KKPSharePageControl *pageCTemp =[[KKPSharePageControl alloc] init];
    pageCTemp.frame = (CGRect){0, pageCTempY, ScreenWidth, 4};
    self.pageControl = pageCTemp;
    self.pageControl.currentPageIndicatorTintColor = RGB(0x999999, 1.0);
    self.pageControl.pageIndicatorTintColor = RGB(0xdbdbdb, 1.0);
    self.pageControl.numberOfPages = myCeil(self.itemList.count, 6);
    self.pageControl.userInteractionEnabled = NO;
    [self.maskView addSubview:self.pageControl];
}

- (void)configMaskView
{
    self.maskView = [[UIView alloc] initWithFrame:(CGRect){0, ScreenHeight - MaskViewHeight, ScreenWidth, MaskViewHeight}];
    self.maskView.backgroundColor = [UIColor clearColor];
    self.maskView.clipsToBounds = YES;
    [self addSubview:self.maskView];
    
    self.blurBackGround = [[UIImageView alloc] initWithFrame:(CGRect){0, - (ScreenHeight - MaskViewHeight), ScreenWidth, ScreenHeight}];
    [self.maskView addSubview:_blurBackGround];
    
    self.buttonContainer = [[UIView alloc] initWithFrame:(CGRect){-2, MaskViewHeight - BottomViewSpace, ScreenWidth + 4, BottomViewSpace + 2}];
    self.buttonContainer.backgroundColor = [UIColor clearColor];
    self.buttonContainer.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.buttonContainer.layer.borderWidth = 0.5;
    [self.maskView addSubview:self.buttonContainer];
    
    self.btn_cancel = [[UIButton alloc] initWithFrame:(CGRect){0, 0, CancelButtonWidth, CancelButtonHeight}];
    [self.btn_cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_cancel setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    self.btn_cancel.center = (CGPoint){self.buttonContainer.bounds.size.width/2, self.buttonContainer.bounds.size.height/2};
    [self.buttonContainer addSubview:self.btn_cancel];
    [self.maskView addSubview:self.buttonContainer];
}



#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int now = (int)round((scrollView.contentOffset.x / self.scrollView.frame.size.width));
    for (UIImageView *dot in [_pageControl subviews]) {
        dot.bounds = (CGRect){0, 0, 5, 5};
    }
    self.currentIndex = now;
    self.pageControl.currentPage = now;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int now = (int)round((scrollView.contentOffset.x / self.scrollView.frame.size.width));
    self.currentIndex = now;
    self.pageControl.currentPage = now;
}


@end
