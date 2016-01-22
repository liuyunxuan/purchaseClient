

#import "KKPImagePickerCameraView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "FrameAccessor.h"
#import "KKPFont.h"
#import "KKPColor.h"

@interface KKPImagePickerCameraView ()

//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cameraIconImageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

//@property (nonatomic, strong) AVCaptureSession *captureSession;
//@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePerviewLayer;
//@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation KKPImagePickerCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)RGB(0x5f6061, 1.0).CGColor,
                                 (id)RGB(0x8f9091, 1.0).CGColor];
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
        _gradientLayer = gradientLayer;

        _cameraIconImageView = [[UIImageView alloc] init];
        _cameraIconImageView.image = [UIImage imageNamed:@"ico_camera"];
        _cameraIconImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_cameraIconImageView];
    }
    return self;
}

//- (void)dealloc {
//    [_captureSession stopRunning];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gradientLayer.frame = self.bounds;
//    self.capturePerviewLayer.frame = self.bounds;
    self.cameraIconImageView.frame = self.bounds;
    
}

- (void)updateCamera {
    
//    if (self.captureSession) {
//        [self.captureSession stopRunning];
//    }
//    
//    if (self.capturePerviewLayer) {
//        [self.capturePerviewLayer removeFromSuperlayer];
//    }
//    
//    if (self.cameraIconImageView) {
//        [self.cameraIconImageView removeFromSuperview];
//    }
//    
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    
//    if (AVAuthorizationStatusAuthorized == authStatus) {
//        [self showCemera];
//    }
//    
//    self.cameraIconImageView = [[UIImageView alloc] init];
//    self.cameraIconImageView.image = [UIImage imageNamed:@"ico_camera"];
//    self.cameraIconImageView.contentMode = UIViewContentModeCenter;
//    [self addSubview:self.cameraIconImageView];

}


- (void)showCemera {
//    self.captureSession = [[AVCaptureSession alloc] init];
//    self.capturePerviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
//    self.capturePerviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.layer addSublayer:self.capturePerviewLayer];
//    
//    // configure camera
//    NSArray *devices = [AVCaptureDevice devices];
//    AVCaptureDevice *backCamera;
//    AVCaptureDevice *frontCamera;
//    for (AVCaptureDevice *device in devices) {
//        if ([device hasMediaType:AVMediaTypeVideo]) {
//            if ([device position] == AVCaptureDevicePositionFront) {
//                frontCamera = device;
//            }
//            if ([device position] == AVCaptureDevicePositionBack) {
//                backCamera = device;
//            }
//        }
//    }
//    
//    NSError *error = nil;
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera ?:frontCamera error:&error];
//    if (input) {
//        [self.captureSession addInput:input];
//        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
//        NSDictionary *outputSettings = @{
//                                         AVVideoCodecKey: AVVideoCodecJPEG,
//                                         };
//        self.stillImageOutput.outputSettings = outputSettings;
//        [self.captureSession addOutput:self.stillImageOutput];
//        
//        [self.captureSession startRunning];
//    }
}

@end
