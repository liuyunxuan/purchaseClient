//
//  SCNavigationController.m
//
//
//  Created by Singro on 2/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCNavigationController.h"

#import "SCShared.h"

#import "SCNavigationPopAnimation.h"
#import "SCNavigationPushAnimation.h"

#import "SCNavigationBar.h"
#import "UIViewController+SCNavigation.h"

#import "EXTScope.h"

BOOL enableInnerInactiveGesture = NO;

@interface SCNavigationController ()  <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@property (nonatomic, assign) UIViewController *lastViewController;

@property (nonatomic, assign) BOOL isTransiting;

@end

@implementation SCNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {

        self.enableInnerInactiveGesture = enableInnerInactiveGesture;

    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {

        self.enableInnerInactiveGesture = enableInnerInactiveGesture;

    }
    return self;
}

- (void)loadView {
    [super loadView];

}

- (void)awakeFromNib {
    self.enableInnerInactiveGesture = enableInnerInactiveGesture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isTransiting = NO;

    self.navigationBarHidden = YES;

    self.interactivePopGestureRecognizer.delegate = self;
    super.delegate = self;

//    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
   return UIStatusBarStyleLightContent;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    return YES;
}

- (void)resetDelegate {
    self.interactivePopGestureRecognizer.delegate = self;
    super.delegate = self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UINavigationDelegate

// forbid User VC to be NavigationController's delegate
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
}

#pragma mark - Push & Pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        UIImage *originalImage = [UIImage imageNamed:@"NineGameSDK.bundle/nav_icon_back"];
        viewController.sc_backButtonImage =[originalImage stretchableImageWithLeftCapWidth:originalImage.size.width/2 topCapHeight:originalImage.size.height/2]; 
    }
//    if (!self.isTransiting) {
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
    
    if (self.isTransiting) {
        return;
    }

    self.isTransiting = YES;
    self.interactivePopGestureRecognizer.enabled = NO;

    [[self class] configureNavigationBarForViewController:viewController];

    [super pushViewController:viewController animated:animated];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {

    if (self.isTransiting) {
        self.isTransiting = NO;
        return nil;
    }
    
    if (self.viewControllers.count <= 1) {
        self.interactivePopGestureRecognizer.delegate = self;
        return nil;
    }

    return [super popViewControllerAnimated:animated];

}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    
    self.isTransiting = NO;
    
    if (self.viewControllers.count > 1) {
        self.interactivePopGestureRecognizer.enabled = YES;
    } else {
        self.interactivePopGestureRecognizer.enabled = NO;
    }


}


//#pragma mark UINavigationControllerDelegate
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//
////    self.isTransiting = YES;
//
//}
//
//- (void)navigationController:(UINavigationController *)navigationController
//       didShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animate
//{
//
////    self.isTransiting = NO;
//
//    [viewController.view bringSubviewToFront:viewController.sc_navigationBar];
//    
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        if (navigationController.viewControllers.count == 1) {
//            self.interactivePopGestureRecognizer.delegate = nil;
//            self.delegate = nil;
//            self.interactivePopGestureRecognizer.enabled = NO;
//        } else {
//            self.interactivePopGestureRecognizer.enabled = YES;
//        }
//    }
//
//    if (self.enableInnerInactiveGesture) {
//        BOOL hasPanGesture = NO;
//        for (UIGestureRecognizer *recognizer in [viewController.view gestureRecognizers]) {
//            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//                if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
//                } else {
//                    hasPanGesture = YES;
//                }
//            }
//        }
//        if (!hasPanGesture && (navigationController.viewControllers.count > 1)) {
//            [viewController.view addGestureRecognizer:self.panRecognizer];
//            id <UIGestureRecognizerDelegate> vc = (id)viewController;
//            self.panRecognizer.delegate = vc;
//        }
//    }
//
//    viewController.navigationController.delegate = self;
//
//}
//
//
//// Animation
//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController *)fromVC
//                                                 toViewController:(UIViewController *)toVC {
//
//    if (operation == UINavigationControllerOperationPop && navigationController.viewControllers.count >= 1 && self.enableInnerInactiveGesture) {
//        return [[SCNavigationPopAnimation alloc] init];
//    } else if (operation == UINavigationControllerOperationPush) {
//        SCNavigationPushAnimation *animation = [[SCNavigationPushAnimation alloc] init];
//        return animation;
//    } else {
//        return nil;
//    }
//}
//
//- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
//    if ([animationController isKindOfClass:[SCNavigationPopAnimation class]] && self.enableInnerInactiveGesture) {
//        return self.interactivePopTransition;
//    }
//    else {
//        return nil;
//    }
//}
//
//
//- (void)handlePanRecognizer:(UIPanGestureRecognizer*)recognizer {
//
//
//    static CGFloat startLocationX = 0;
//
//    CGPoint location = [recognizer locationInView:self.view];
//
//    CGFloat progress = (location.x - startLocationX) / [UIScreen mainScreen].bounds.size.width;
//    progress = MIN(1.0, MAX(0.0, progress));
//
////    NSLog(@"progress:   %.2f", progress);
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        startLocationX = location.x;
//        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
//        [self popViewControllerAnimated:YES];
//    }
//    else if (recognizer.state == UIGestureRecognizerStateChanged) {
//
//
//        [self.interactivePopTransition updateInteractiveTransition:progress];
//    }
//    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
//        CGFloat velocityX = [recognizer velocityInView:self.view].x;
//        if (progress > 0.3 || velocityX > 300) {
//            self.interactivePopTransition.completionSpeed = 0.4;
//            [self.interactivePopTransition finishInteractiveTransition];
//        }
//        else {
//            self.interactivePopTransition.completionSpeed = 0.3;
//            [self.interactivePopTransition cancelInteractiveTransition];
//        }
//
//        self.interactivePopTransition = nil;
//    }
//}

#pragma mark - Private Helper

+ (UIView *)configureNavigationBarForViewController:(UIViewController *)viewController {
    
    if (!viewController.sc_navigationItem) {
        SCNavigationItem *navigationItem = [[SCNavigationItem alloc] init];
        [navigationItem setValue:viewController forKey:@"_sc_viewController"];
        viewController.sc_navigationItem = navigationItem;
    }
    if (!viewController.sc_navigationBar) {
        viewController.sc_navigationBar = [[SCNavigationBar alloc] init];
        [viewController.view addSubview:viewController.sc_navigationBar];
        
        if (!viewController.sc_navigationItem.leftBarButtonItem) {
            @weakify(viewController);
            
            if (viewController.sc_backButtonImage!= nil) {
                viewController.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc]initWithImage:viewController.sc_backButtonImage style:0 handler:^(id sender) {
                    @strongify(viewController);
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                viewController.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navi_back"] style:0 handler:^(id sender) {
                    @strongify(viewController);
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            
            }
            
            viewController.sc_navigationItem.leftBarButtonItem.view.accessibilityLabel = @"Back";
        } else {
            viewController.sc_navigationItem.leftBarButtonItem = viewController.sc_navigationItem.leftBarButtonItem;
        }
        if (viewController.sc_isNavigationBarHidden) {
            viewController.sc_navigationItem.leftBarButtonItem.view.alpha = 0;
        }
    }
    return viewController.sc_navigationBar;
}

@end
