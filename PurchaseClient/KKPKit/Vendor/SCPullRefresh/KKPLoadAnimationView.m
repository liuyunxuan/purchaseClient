
#import "KKPLoadAnimationView.h"


#import "CAAnimation+Blocks.h"
#import "FrameAccessor.h"

#import "KKPColor.h"

//static NSString *const kInitAnimation = @"InitAnimation";
//static NSString *const kGroupAnimation = @"GroupAnimation";

static CGFloat const kImageWidth = 65.0f;
static CGFloat const kImageHeight = 175.0;
static NSUInteger kImageCount = 0;

@interface KKPLoadAnimationView ()

@property (nonatomic, strong) NSArray *imageArray; // An array CGImageRef

@property (nonatomic, strong) CALayer *refresLayer;
@property (nonatomic, strong) UILabel *loadingLabel;

@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void (^endAnimationBlock)();
@property (nonatomic, assign) BOOL willEndAnimation;

@end

@implementation KKPLoadAnimationView

+ (NSArray *)imageArray
{
    static NSArray *imageArray = nil;
    if (nil == imageArray) {
        NSMutableArray *images = [NSMutableArray new];
        UIImage *aminationsImage = [UIImage imageNamed:@"loadingAnimations"];
        kImageCount = floor(aminationsImage.size.width/kImageWidth);
        for (NSUInteger i = 0; i < kImageCount; i ++) {
            CGImageRef subImageRef = CGImageCreateWithImageInRect(aminationsImage.CGImage, CGRectMake(kImageWidth * i * 2, 0, kImageWidth *2, kImageHeight * 2));
            [images addObject:(__bridge id)subImageRef];
            CGImageRelease(subImageRef);
        }
        imageArray = images;
    }
    
    return imageArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _willEndAnimation = NO;
        _imageIndex = 0;
        
        // layers
        _imageArray = [[self class] imageArray];
        
        // refresh layer
        CALayer *refresLayer = [[CALayer alloc] init];
        refresLayer.frame = (CGRect){(self.width - kImageWidth)/2 , (self.height - kImageHeight)/2, kImageWidth, kImageHeight};
        refresLayer.contents = _imageArray[_imageIndex];
        refresLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:refresLayer];
        _refresLayer = refresLayer;
        
        UILabel *loadingLabel = [[UILabel alloc] init];
        loadingLabel.frame = refresLayer.frame;
        loadingLabel.height = 16;
        loadingLabel.y = refresLayer.frame.origin.y + refresLayer.frame.size.height + 10;
        loadingLabel.font = [UIFont systemFontOfSize:14];
        loadingLabel.textColor = kColor.colorGray;
        loadingLabel.text = @"正在加载";
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:loadingLabel];
        _loadingLabel = loadingLabel;
        
    }
    return self;
}

- (void)dealloc {
    //    NSLog(@"dealloc loading animation");
}

#pragma mark - Public Methods

- (void)beginAnimation {
    
    if (self.timer) {
        return;
    }
    
    self.refresLayer.contents = self.imageArray.firstObject;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(animateLoop) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)endAnimationCompletion:(void (^)())complete {
    
    if (complete) {
        self.endAnimationBlock = complete;
        self.willEndAnimation = YES;
    } else {
        self.endAnimationBlock = nil;
        [self endAnimation];
    }
    
}

#pragma mark - Private Methods

- (void)endAnimation {
    
    [self.timer invalidate];
    self.timer = nil;
    self.willEndAnimation = NO;
    self.imageIndex = 0;
    
    if (self.endAnimationBlock) {
        self.endAnimationBlock();
    }
}

- (void)animateLoop {
    
    self.imageIndex ++;
    if (self.imageIndex == kImageCount) {
        self.imageIndex = 0;
        if (self.endAnimationBlock && self.willEndAnimation) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self endAnimation];
            });
        }
    }
    self.refresLayer.contents = self.imageArray[self.imageIndex];
}

@end
