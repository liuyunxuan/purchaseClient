

#import "KKPRefreshView.h"


#import "CAAnimation+Blocks.h"
#import "FrameAccessor.h"

static NSString *const kInitAnimation = @"InitAnimation";
static NSString *const kGroupAnimation = @"GroupAnimation";

static NSUInteger const kFrameCount = 8;
static CGFloat const kRefreshHeight = 65.0f;

@interface KKPRefreshView ()

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) CALayer *refresLayer;
@property (nonatomic, strong) CALayer *fadeLayer;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void (^endAnimationBlock)();
@property (nonatomic, assign) BOOL willEndAnimation;
@property (nonatomic, assign) NSInteger imageIndex;

@end

@implementation KKPRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.willEndAnimation = NO;
        self.imageIndex = 0;
        
        // layers
        self.imageArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < kFrameCount; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"refresh_%zd", i+1];
            id contents = (id)[UIImage imageNamed:imageName].CGImage;
            [self.imageArray addObject:contents];
        }
        
        // refresh layer
        self.refresLayer = [[CALayer alloc] init];
        self.refresLayer.frame = (CGRect){self.width/2 - 15, 15, 30, 35};
        self.refresLayer.contents = (id)[UIImage imageNamed:@"refresh_1"].CGImage;
        [self.layer addSublayer:self.refresLayer];
        
        // fade layer
        self.fadeLayer = [[CALayer alloc] init];
        self.fadeLayer.frame = (CGRect){self.width/2 - 15, 15, 30, 35};
        self.fadeLayer.contents = (id)[UIImage imageNamed:@"refresh_fade"].CGImage;
        [self.layer addSublayer:self.fadeLayer];
        
    }
    return self;
}

#pragma mark - Public Methods

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    if (!self.timer.isValid) {
        CGFloat offset = kRefreshHeight * timeOffset - 15;
        if (offset <= 0) {
            self.fadeLayer.opacity = 0;
        } else {
            NSInteger offset8 = (10 - (NSInteger)offset%(10*2));
            CGFloat opacity = offset8 > 0 ? offset8/10. : -offset8/10.;
            self.fadeLayer.opacity = opacity > 0.7 ? 1 : opacity/0.7;
        }
    }
    
}

- (void)beginRefreshing {
    
    [self beginAnimation];
    
}

- (void)endRefreshingCompletion:(void (^)())complete {
    
    if (complete) {
        self.endAnimationBlock = complete;
        self.willEndAnimation = YES;
    } else {
        [self endAnimation];
    }
    
}

#pragma mark - Private Methods

- (void)beginAnimation {
    
    self.imageIndex = 0;
    self.fadeLayer.hidden = YES;
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animateLoop) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)endAnimation {
    
    [self.timer invalidate];
    self.refresLayer.contents = self.imageArray[0];
    self.fadeLayer.hidden = NO;
    
}

- (void)animateLoop {
    
    self.imageIndex ++;
    if (self.imageIndex == kFrameCount) {
        self.imageIndex = 0;
        if (self.endAnimationBlock && self.willEndAnimation) {
            [self.timer invalidate];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self endAnimation];
                self.endAnimationBlock();
                self.willEndAnimation = NO;
            });
        }
    }
    self.refresLayer.contents = self.imageArray[self.imageIndex];
    
}

@end
