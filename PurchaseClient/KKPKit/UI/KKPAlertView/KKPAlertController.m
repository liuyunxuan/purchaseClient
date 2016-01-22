

#import "KKPAlertController.h"

#import "KKPFont.h"
#import "KKPColor.h"
#import "KKPButton.h"
#import "KKPButton+Private.h"

#import "FrameAccessor.h"
#import "UIControl+BlocksKit.h"
#import "EXTScope.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static CGSize screenSize()
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

static BOOL isIOS7Lanscape()
{
    return (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

static CGFloat kButtonHeight = 55;
static CGFloat const kCancelSpace  = 7;
static CGFloat const kContainerWidth = 270;

@interface KKPAlertController (Helpers)

+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width;

@end

@interface KKPAlertAction (private)

@property (nonatomic, copy) void (^handlerBlock)(KKPAlertAction *action);

@end

@interface KKPAlertWindowVC : UIViewController

@end

@implementation KKPAlertWindowVC

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

/**
 *  当以 self.view 形式 Add 到 view 时，会丢失 self， 此时用来临时持有 self，避免 dismiss 时 self 不可以
 */
static KKPAlertController *sharedSelf = nil;


@interface KKPAlertController ()

@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *alertMessage;
@property (nonatomic, copy) NSAttributedString *alertAttributedMessage;

@property (nonatomic, readwrite) KKPAlertControllerStyle preferredStyle;
@property (nonatomic, strong) KKPAlertCustomView *customView;

@property (nonatomic, strong) NSMutableArray *mutaActions;

@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) NSMutableArray *buttonArray;

// For Action Sheet only
@property (nonatomic, strong) KKPButton *cancelButton;

// For ShowInView only
@property (nonatomic, weak) UIView *showInView;

// Patch iOS 7 layoutSubViews after viewDidAppears
@property (nonatomic, assign) BOOL hasLayout;

@property (nonatomic, assign, getter=isShowing) BOOL showing;

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIWindow *currentWindow;
@end

@implementation KKPAlertController

@synthesize alertWindow = _alertWindow;

+ (CGFloat)containerWidth {
    return kContainerWidth;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
{
    return [[KKPAlertController alloc] initWithTitle:title
                                            message:message
                                  attributedMessage:nil
                                     preferredStyle:preferredStyle
                                         customView:nil];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
                              customView:(KKPAlertCustomView *)customView
{
    return [[KKPAlertController alloc] initWithTitle:title
                                            message:message
                                  attributedMessage:nil
                                     preferredStyle:preferredStyle
                                         customView:customView];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                       attributedMessage:(NSAttributedString *)attributedMessage
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
{
    return [[KKPAlertController alloc] initWithTitle:title
                                            message:nil
                                  attributedMessage:attributedMessage
                                     preferredStyle:preferredStyle
                                         customView:nil];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                       attributedMessage:(NSAttributedString *)attributedMessage
                          preferredStyle:(KKPAlertControllerStyle)preferredStyle
                              customView:(KKPAlertCustomView *)customView
{
    return [[KKPAlertController alloc] initWithTitle:title
                                            message:nil
                                  attributedMessage:attributedMessage
                                     preferredStyle:preferredStyle
                                         customView:customView];
}


- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            attributedMessage:(NSAttributedString *)attributedMessage
               preferredStyle:(KKPAlertControllerStyle)preferredStyle
                   customView:(KKPAlertCustomView *)customView
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.modalPresentationStyle = UIModalPresentationCustom;

    _alertTitle = title;
    _alertMessage = message;
    _alertAttributedMessage = attributedMessage;
    _preferredStyle = preferredStyle;
    _customView = customView;
    _mutaActions = [NSMutableArray new];
    _buttonArray = [NSMutableArray new];
    _showing = NO;
    _hasLayout = NO;
    
    return self;

}

#pragma mark - Life Cycle

- (void)loadView
{
    [super loadView];
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        kButtonHeight = 50;
    }

    [self configureAlert];
    [self configureCustomView];
    [self configureButtons];
    [self configureCancelButton];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveKeyboardHiddenNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveChangeOrientation:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isShowing) {
        self.showing = YES;
        if (self.hasLayout) {
            [self showViews];
        }
    }

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)dealloc
{
    [self removeParallaxEffect];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.hasLayout) {
        return;
    }
    self.view.size = screenSize();
    
    CGFloat kOffsetY = 0;
    kOffsetY = [self layoutTopWithOffsetY:kOffsetY];
    kOffsetY = [self layoutBodyWithOffsetY:kOffsetY];

    BOOL isIos7 = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        isIos7 = YES;
    }

    if ((self.isShowing && !self.hasLayout) || isIos7) {
        self.showing = YES;
        [self showViews];
    }
    self.hasLayout = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)layoutTopWithOffsetY:(CGFloat)offsetY
{
    CGFloat kOffsetY = offsetY;

    if (self.alertTitle) {
        kOffsetY += 20;
        self.titleLabel.y = kOffsetY;
        self.titleLabel.centerX = self.containerView.width/2;
        kOffsetY = self.titleLabel.bottom;
    }
    
    if (self.alertMessage || self.alertAttributedMessage) {
        if (self.alertTitle) {
            kOffsetY += 4;
        } else {
            kOffsetY += 20;
        }
        self.messageLabel.y = kOffsetY;
        self.messageLabel.centerX = self.containerView.width/2;
        kOffsetY = self.messageLabel.bottom;
        if (self.messageLabel.height > 16 && self.alertTitle != nil) {
            self.messageLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
        }
    }

    return kOffsetY;
}

- (CGFloat)layoutBodyWithOffsetY:(CGFloat)offsetY
{
    CGFloat kOffsetY = offsetY;
    
    if (self.customView) {
        kOffsetY += 10;
        self.customView.y = kOffsetY;
        self.customView.centerX = self.containerView.width/2;
        kOffsetY = self.customView.bottom;
    }
    
    if (kOffsetY > 1) {
        kOffsetY += 10;
    }
    
    self.buttonContainerView.y = kOffsetY;
    self.containerView.height = self.buttonContainerView.bottom;
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        self.containerView.centerX = screenSize().width/2;
        self.containerView.y = screenSize().height;
        self.cancelButton.centerX = self.view.width/2;
        self.cancelButton.y = self.containerView.bottom;
    } else {
       self.containerView.center = CGPointMake(screenSize().width / 2, screenSize().height / 2);
    }

    return kOffsetY;
}

#pragma mark - Configure Views
- (UIWindow *)alertWindow
{
    if (_alertWindow) {
        return _alertWindow;
    }
    
    //如果定位为最高层级，有可能弹窗把键盘挡住，如果弹窗上需要用户输入的话会输不了
    //    NSArray *windows = [[UIApplication sharedApplication] windows];
    //    UIWindow *lastWindow = (UIWindow *)[windows lastObject];
    
    _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _alertWindow.windowLevel = UIWindowLevelStatusBar + 50;
    _alertWindow.hidden = NO;
    _alertWindow.backgroundColor = [UIColor clearColor];
    //[_alertWindow makeKeyAndVisible];
    return _alertWindow;
}

- (void)setAlertWindow:(UIWindow *)alertWindow
{
    NSLog(@"alert%@", alertWindow);
    _alertWindow = alertWindow;
}

- (void)configureAlert
{
    
    self.backgroundButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.2];
        button.alpha = 0;
        [self.view addSubview:button];
        button;
    });
    
    self.containerView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 10;
        view.clipsToBounds = YES;
        [self.view addSubview:view];
        view;
    });
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        self.containerView.layer.cornerRadius = 0;
        self.containerView.clipsToBounds = NO;
    }
    
    if (self.alertTitle) { // 创建标题
        self.titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:16];
            label.textColor = kColor.colorBlack;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            [self.containerView addSubview:label];
            label;
        });
        if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
            self.titleLabel.textColor = kColor.colorGray;
            self.titleLabel.font = kFont.f13;
        }
    }
    
    if (self.alertMessage || self.alertAttributedMessage) { // 创建描述文字
        self.messageLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = kFont.f13;
            label.textColor = kColor.colorBlack;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            [self.containerView addSubview:label];
            label;
        });
        if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
            self.messageLabel.textColor = kColor.colorGray;
            self.messageLabel.font = kFont.f12;
        }
    }
    
    [self configureAlertLayout];
    
    // handlers
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        [self.backgroundButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configureAlertLayout
{
    
    self.titleLabel.text = self.alertTitle;
    
    if (self.alertMessage) {
        self.messageLabel.text = self.alertMessage;
    } else if (self.alertAttributedMessage) {
        self.messageLabel.attributedText = self.alertAttributedMessage;
    }
    
    CGRect rect = CGRectMake(0, 0, screenSize().width, screenSize().height);
    self.backgroundButton.frame = rect;
                             
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        self.containerView.width = self.view.width;
    } else {
        self.containerView.width = kContainerWidth;
        [self addParallaxEffect];
    }
    
    CGFloat titleHeight = [[self class] getTextHeightWithText:self.alertTitle
                                                         Font:self.titleLabel.font
                                                        Width:self.containerView.width - 44];
    self.titleLabel.size = (CGSize){self.containerView.width - 44, titleHeight};
    
    CGFloat messageHeight;
    
    if (self.alertMessage) {
        messageHeight = [[self class] getTextHeightWithText:self.alertMessage
                                                               Font:self.messageLabel.font
                                                              Width:self.containerView.width - 44];
    } else if (self.alertAttributedMessage) {
        CGSize maxSize = (CGSize){self.containerView.width - 44, CGFLOAT_MAX};
        CGRect rect = [self.alertAttributedMessage boundingRectWithSize:maxSize
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  context:nil];
        messageHeight = CGRectGetHeight(rect);
    }
    
    self.messageLabel.size = (CGSize){self.containerView.width - 44, messageHeight};

}

- (void)configureCustomView
{
    
    if (self.customView) {
        [self.containerView addSubview:self.customView];
    }
    
}

/**
 *  设置按钮界面
 */
- (void)configureButtons
{
    
    if (self.mutaActions.count) {
        
        self.buttonContainerView = ({
            UIView *view = [[UIView alloc] init];
            view.size = (CGSize){self.containerView.width, kButtonHeight};
            [self.containerView addSubview:view];
            
            view;
        });
        
        UIView *topLineView = ({
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = kColor.colorLightGray;
            lineView.size = (CGSize){self.buttonContainerView.width, 0.5};
            [self.buttonContainerView addSubview:lineView];
            lineView;
        });

        if (1 == self.mutaActions.count && KKPAlertControllerStyleAlert == self.preferredStyle) {
            KKPAlertAction *action = self.mutaActions.firstObject;
            KKPButton *actionButton = [self buttonWithAlertAction:action];
            actionButton.size = self.buttonContainerView.size;
            [self.buttonArray addObject:actionButton];
            
        } else if (2 == self.mutaActions.count && KKPAlertControllerStyleAlert == self.preferredStyle) {
            
            for (NSInteger i = 0; i < self.mutaActions.count; i ++) {
                KKPAlertAction *action = self.mutaActions[i];
                KKPButton *actionButton = [self buttonWithAlertAction:action];
                actionButton.size = self.buttonContainerView.size;
                actionButton.width /= 2;
                actionButton.x = actionButton.width * i;
                [self.buttonArray addObject:actionButton];
            }
            
            UIView *midLineView = ({
                UIView *lineView = [[UIView alloc] init];
                lineView.backgroundColor = kColor.colorLightGray;
                lineView.size = (CGSize){0.5, self.buttonContainerView.height};
                [self.buttonContainerView addSubview:lineView];
                lineView;
            });
            midLineView.x = self.buttonContainerView.centerX;

        } else {
            
            self.buttonContainerView.height = self.mutaActions.count * kButtonHeight;
            [self configureActionButtons];
            
        }
        
        [self.buttonContainerView bringSubviewToFront:topLineView];
    }
}

- (void)configureActionButtons
{
    
    for (NSInteger i = 0; i < self.mutaActions.count; i ++) {
        KKPAlertAction *action = self.mutaActions[i];
        KKPButton *actionButton = [self buttonWithAlertAction:action];
        actionButton.size = (CGSize){self.buttonContainerView.width, kButtonHeight};
        actionButton.y = kButtonHeight * i;
        [self.buttonArray addObject:actionButton];
        
        if (action.style == KKPAlertActionStyleDefaultWithSelection) {
            // 添加打勾标识
            float fSizeOfImage = 15.f;
            UIImageView *ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fSizeOfImage, fSizeOfImage)];
            ivSelected.centerX = self.buttonContainerView.right-fSizeOfImage-fSizeOfImage/2;
            ivSelected.centerY = actionButton.centerY;
            [ivSelected setImage:[UIImage imageNamed:@"ico_选择"]];
            [self.buttonContainerView addSubview:ivSelected];
        }
        
        if (i != self.mutaActions.count - 1) {
            UIView *bottomLineView = ({
                UIView *lineView = [[UIView alloc] init];
                lineView.backgroundColor = kColor.colorLightGray;
                lineView.size = (CGSize){self.buttonContainerView.width, 0.5};
                [self.buttonContainerView addSubview:lineView];
                lineView;
            });
            bottomLineView.y = actionButton.bottom - 0.5;
        }
    }

}

- (void)configureCancelButton
{
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        
        self.cancelButton = [KKPButton buttonWithType:KKPButtonType2];
        self.cancelButton.showBorder = NO;
        self.cancelButton.title = _cancelTitle ? _cancelTitle : @"取消";
        self.cancelButton.size = (CGSize){self.buttonContainerView.width, kButtonHeight};
        self.cancelButton.textColorNormal = kColor.colorBlack;
        self.cancelButton.textColorHighlighted = kColor.colorBlack;
        self.cancelButton.borderColorHighlighted = kColor.colorUltraLightGray;
        self.cancelButton.backgroundColorHighlighted = kColor.colorUltraLightGray;
        self.cancelButton.font = kFont.f18;
        self.cancelButton.backgroundColor = kColor.colorWhite;

        [self.view addSubview:self.cancelButton];
        
        UIView *backView = [[UIView alloc] initWithFrame:(CGRect){0, -kCancelSpace, self.buttonContainerView.width, kCancelSpace}];
        backView.backgroundColor = kColor.colorUltraLightGray;
        [self.cancelButton addSubview:backView];
        
        @weakify(self);
        [self.cancelButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [self dismissAlertCompletion:^{
                @strongify(self);
                if (self.didDismissBlock) {
                    self.didDismissBlock();
                }
            }];
        } forControlEvents:UIControlEventTouchUpInside];

    }
}

#pragma mark - Configure Motion Effect

- (void)addParallaxEffect
{
    UIInterpolatingMotionEffect *effectHorizontal =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"position.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    UIInterpolatingMotionEffect *effectVertical =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"position.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    [effectHorizontal setMaximumRelativeValue:@(10.0f)];
    [effectHorizontal setMinimumRelativeValue:@(-10.0f)];
    [effectVertical setMaximumRelativeValue:@(20.0f)];
    [effectVertical setMinimumRelativeValue:@(-20.0f)];
    [self.containerView addMotionEffect:effectHorizontal];
    [self.containerView addMotionEffect:effectVertical];
}

- (void)removeParallaxEffect
{
    [self.containerView.motionEffects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.containerView removeMotionEffect:obj];
    }];
}


#pragma mark - Public Methods

- (NSArray *)actions
{
    return self.mutaActions;
}

- (void)addAction:(KKPAlertAction *)action
{
    [self.mutaActions addObject:action];
}

- (void)addActions:(NSArray *)actions
{
    [self.mutaActions addObjectsFromArray:actions];
}

- (KKPAlertAction *)addActionWithTitle:(NSString *)title
                                style:(KKPAlertActionStyle)style
                              handler:(void (^)(KKPAlertAction *action))handler
{
    
    KKPAlertAction *action = [KKPAlertAction actionWithTitle:title style:style handler:handler];
    [self.mutaActions addObject:action];
    
    return action;
}

- (void)showAlertInViewController:(UIViewController *)viewController
{
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0 && self.showInView == nil) {
        [viewController presentViewController:self animated:NO completion:^{
        }];
        sharedSelf = nil;
    } else {
        [self showInView:viewController.view];
    }

}

- (void)show
{
    self.currentWindow = [UIApplication sharedApplication].keyWindow;
    KKPAlertWindowVC *vc = [[KKPAlertWindowVC alloc] init];
    self.alertWindow.rootViewController = vc;
    [self showAlertInViewController:vc];
}

- (void)showInView:(UIView *)view
{
    self.showInView = view;
    [view addSubview:self.view];
    sharedSelf = self;
}


- (void)showViews
{
    self.backgroundButton.alpha = 0;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundButton.alpha = 1;
    }];
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        CGFloat containerY = kScreenHeight - kCancelSpace - kButtonHeight - self.containerView.height;
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:3.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.containerView.y = containerY;
            self.cancelButton.y = kScreenHeight - kButtonHeight;
        } completion:^(BOOL finished) {
        }];
    } else {
        self.containerView.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:3.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.containerView.alpha = 1;
            self.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismiss
{
    [self.alertWindow endEditing:YES];
    [self dismissAlertCompletion:self.didDismissBlock];
}

- (void)dismissAlertCompletion:(void (^)())complectionBlock
{
    
    void (^completion)() = ^{
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0 && self.showInView == nil) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (complectionBlock) {
                    complectionBlock();
                }
            }];
        } else {
            sharedSelf = nil;
            [self.view removeFromSuperview];
            if (complectionBlock) {
                complectionBlock();
            }
        }
    };
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundButton.alpha = 0;
            self.containerView.y = kScreenHeight;
            self.cancelButton.y = kScreenHeight + self.containerView.height + kButtonHeight + kCancelSpace;
        } completion:^(BOOL finished) {
            completion();
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundButton.alpha = 0;
            self.containerView.alpha = 0;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    
    self.alertWindow.hidden = NO;
    self.alertWindow.rootViewController = nil;
    self.alertWindow = nil;
    //[self.currentWindow makeKeyAndVisible];
    self.currentWindow = nil;
}

#pragma mark - Private Methods

- (KKPButton *)buttonWithAlertAction:(KKPAlertAction *)action
{
    
    KKPButton *actionButton = ({
        KKPButton *button = [KKPButton buttonWithType:KKPButtonType2];
        button.showBorder = NO;
        button.backgroundColorHighlighted = kColor.colorUltraLightGray;
        button.borderColorHighlighted = kColor.colorUltraLightGray;
        [self.buttonContainerView addSubview:button];
        button;
    });
    
    if (action.handlerBlock) {
        @weakify(self);
        [actionButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [self dismissAlertCompletion:^{
                if (action.handlerBlock) {
                    action.handlerBlock(sender);
                }
                if (self.didDismissBlock) {
                    self.didDismissBlock();
                }
            }];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    actionButton.title = action.title;
    
    if (KKPAlertControllerStyleActionSheet == self.preferredStyle) {
        actionButton.textColorNormal = kColor.colorBlack;
        actionButton.textColorHighlighted = kColor.colorBlack;
        actionButton.textColorDisabled = kColor.colorBlack;
        actionButton.font = kFont.f18;
    }
    
    switch (action.style) {
        case KKPAlertActionStyleNormal: // 表现与 Cancel 一样
        case KKPAlertActionStyleCancel: {
            break;
        }
            
        case KKPAlertActionStyleDefault: {
            actionButton.boldFont = YES;
            break;
        }
            
        case KKPAlertActionStyleDestructive: {
            actionButton.boldFont = YES;
            actionButton.textColorNormal = kColor.colorRed;
            actionButton.textColorHighlighted = kColor.colorRed;
            actionButton.textColorDisabled = kColor.colorRed;
            break;
        }
            
        case KKPAlertActionStyleDefaultWithSelection: {
//            actionButton.boldFont = YES;
            break;
        }
            
        default: {
            break;
        }
    }
    
    return actionButton;
}

#pragma mark - Notifications 

- (void)didReceiveKeyboardShowNotification:(NSNotification *)notification
{
    

    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (isIOS7Lanscape()) {
        self.containerView.centerY = (screenSize().height - keyboardFrame.size.width) / 2;
    } else {
        self.containerView.centerY = (kScreenHeight - keyboardFrame.size.height) / 2;
    }
   
    [UIView commitAnimations];
}

- (void)didReceiveKeyboardHiddenNotification:(NSNotification *)notification
{

    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.containerView.center = self.view.center;

    [UIView commitAnimations];

}

- (void)didReceiveChangeOrientation:(NSNotification *)notification
{
//    self.alertWindow.frame = [UIScreen mainScreen].bounds;
    //    [self.alertWindow makeKeyAndVisible];
    //    self.view.size = screenSize();
    
    NSLog(@"\n>>>>>>>\nview%@\n>>>>>>>>>>>\n", self.alertWindow);
    //    [self.view layoutIfNeeded];
}


@end

@implementation KKPAlertController (Helpers)

+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width
{
    
    if (text.length == 0) {
        return 0;
    }
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 };
    CGRect expectedLabelRect = [text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return CGRectGetHeight(expectedLabelRect);
    
}

@end