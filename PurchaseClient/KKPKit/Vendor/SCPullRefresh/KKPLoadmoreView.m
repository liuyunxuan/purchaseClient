
#import "KKPLoadmoreView.h"

#import "CAAnimation+Blocks.h"
#import "FrameAccessor.h"
#import "KKPColor.h"

static NSString *const kRotationAnimation = @"RotateAnimaton";

static CGFloat const kRefreshHeight = 68.0f;
static CGFloat const kItemHeight = 28;

@interface KKPLoadmoreView ()

@property (nonatomic, strong) CALayer *standLayer;
@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) UIView *noMoreView;
@property (nonatomic, strong) UILabel *noMoreLabel;

@property (nonatomic, copy) void (^endAnimationBlock)();
@property (nonatomic, assign) BOOL willEndAnimation;

@end

@implementation KKPLoadmoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.willEndAnimation = NO;
        
        // animation layer
        self.animationLayer = [[CALayer alloc] init];
        self.animationLayer.frame = (CGRect){self.width/2 - kItemHeight/2, (kRefreshHeight - kItemHeight) / 2, kItemHeight, kItemHeight};
        self.animationLayer.contents = (id)[UIImage imageNamed:@"refresh_loading"].CGImage;
        [self.layer addSublayer:self.animationLayer];
        
        
        // stand layer
        self.standLayer = [[CALayer alloc] init];
        self.standLayer.frame = (CGRect){self.width/2 - kItemHeight/2, (kRefreshHeight - kItemHeight) / 2, kItemHeight, kItemHeight};
        self.standLayer.contents = (id)[UIImage imageNamed:@"refresh_loading"].CGImage;
        [self.layer addSublayer:self.standLayer];
        
        self.animationLayer.hidden = YES;
    }
    return self;
}

#pragma mark - Public Methods

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    self.standLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(2 * M_PI * timeOffset));
    
}

- (void)beginRefreshing {
    
    [self beginAnimation];
    
}

- (void)endRefreshingCompletion:(void (^)())complete {
    
    if (complete) {
        complete();
    }
    [self endAnimation];
    
    //    if (complete) {
    //        self.endAnimationBlock = complete;
    //        self.willEndAnimation = YES;
    //    } else {
    //        [self endAnimation];
    //    }
    //
    //    if (self.endAnimationBlock) {
    //        self.endAnimationBlock();
    //    }
    
    
}

- (void)endRefreshingWithMessage:(NSString *)message completion:(void (^)())completion
{
    
    if (completion) {
        completion();
    }
    
    [self endAnimation];
    
    if (nil == self.noMoreView) {
        self.noMoreView = [self createNoMoreView];
        [self addSubview:self.noMoreView];
    }
    self.noMoreView.hidden = NO;
    self.noMoreLabel.text = message;
    self.standLayer.hidden = YES;
    self.animationLayer.hidden = YES;

}

- (void)hideNoMoreView
{
    self.noMoreView.hidden = YES;
}


#pragma mark - Private Methods

- (void)beginAnimation {
    
    self.standLayer.hidden = YES;
    self.animationLayer.hidden = NO;
    [self.animationLayer addAnimation:[self createRotationAnimationWithOffset:self.timeOffset] forKey:kRotationAnimation];
    
}

- (void)endAnimation {
    
    self.standLayer.hidden = NO;
    self.animationLayer.hidden = YES;
    [self.animationLayer removeAllAnimations];
    
}

- (CAAnimation *)createRotationAnimationWithOffset:(CGFloat)offset {
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    rotationAnimation.duration = 0.8f;
    rotationAnimation.repeatCount = NSUIntegerMax;
    rotationAnimation.speed = 1.0f;
    rotationAnimation.removedOnCompletion = YES;
    
    return rotationAnimation;
}

- (UIView *)createNoMoreView
{
    
    UIView *noMoreView = [[UIView alloc] initWithFrame:self.bounds];
    
    UIImageView *noMoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_nothing_more_pagebottom"]];
    [noMoreImageView sizeToFit];
    [noMoreView addSubview:noMoreImageView];
    noMoreImageView.top = 4;
    noMoreImageView.centerX = self.width / 2;
    
    UILabel *noMoreLabel = [[UILabel alloc] initWithFrame:self.bounds];
    noMoreLabel.font = [UIFont systemFontOfSize:12];
    noMoreLabel.textColor = kColor.colorGray;
    noMoreLabel.textAlignment = NSTextAlignmentCenter;
    [noMoreView addSubview:noMoreLabel];
    self.noMoreLabel = noMoreLabel;
    noMoreLabel.height = 14;
    noMoreLabel.top = noMoreImageView.bottom + 5;
    
    return noMoreView;
}

@end
