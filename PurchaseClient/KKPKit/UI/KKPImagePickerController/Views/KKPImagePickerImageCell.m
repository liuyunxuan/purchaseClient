

#import "KKPImagePickerImageCell.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "FrameAccessor.h"
#import "KKPFont.h"
#import "KKPColor.h"
#import "EXTScope.h"
#import "ALAsset+UIImage.h"

static CGFloat const kNumberLabelHeight = 24;

@interface KKPImagePickerImageCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation KKPImagePickerImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _maskView = [[UIView alloc] init];
        _maskView.alpha = 0;
        _maskView.layer.borderWidth = 1.5;
        _maskView.layer.borderColor = kColor.colorOrange.CGColor;
        [self addSubview:_maskView];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.2];
        _numberLabel.font = kFont.f15;
//        _numberLabel.textColor = [UIColor clearColor];
//        _numberLabel.highlightedTextColor = kColor.colorWhite;
        _numberLabel.layer.borderWidth = 1;
        _numberLabel.layer.borderColor = kColor.colorWhite.CGColor;
        _numberLabel.layer.cornerRadius = kNumberLabelHeight/2;
        _numberLabel.clipsToBounds = YES;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
        
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(buttonDidPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.size = (CGSize){self.width, self.height};
    self.maskView.size = (CGSize){self.width, self.height};
    self.numberLabel.size = (CGSize){kNumberLabelHeight, kNumberLabelHeight};
    self.numberLabel.top = 5;
    self.numberLabel.right = self.width - 5;
    self.selectButton.size = (CGSize){self.width/2, self.height/2};
    self.selectButton.right = self.imageView.right;
    self.selectButton.top = self.imageView.top;
}

#pragma mark - Status

- (void)configureSelected:(BOOL)selected animated:(BOOL)animated complete:(void (^)())complete {
    
    self.numberLabel.highlighted = selected;
    
    CGFloat duration1 = 0;
    CGFloat duration2 = 0;
    if (animated) {
        duration1 = 0.1;
        duration2 = 0.2;
    }
    if (selected) {
        self.maskView.alpha = 1.0;
        self.numberLabel.textColor = kColor.colorWhite;
        self.numberLabel.backgroundColor = kColor.colorOrange;
        self.numberLabel.layer.borderColor = kColor.colorOrange.CGColor;
        if (animated) {
            [UIView animateWithDuration:duration1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.numberLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.numberLabel.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    if (complete) {
                        complete();
                    }
                }];
            }];
        }
    } else {
        self.numberLabel.textColor = [UIColor clearColor];
        self.numberLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.2];
        self.numberLabel.layer.borderColor = kColor.colorWhite.CGColor;
        [UIView animateWithDuration:duration1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.maskView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
    
}

#pragma mark - Data

- (void)setAsset:(ALAsset *)asset {
    _asset = asset;

    UIImage *image = asset.galleryThumbmailImage;
    if (image) {
        self.imageView.image = image;
    } else {
        self.imageView.image = [UIImage imageNamed:@"ico_default_256"];
    }

}

- (void)setNumber:(NSInteger)number {
    _number = number;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%zd", number];
    BOOL isSelected = (number > 0);
    [self configureSelected:isSelected animated:NO complete:nil];

}

- (void)setNumber:(NSInteger)number animated:(BOOL)animated {
    self.number = number;
    
    BOOL isSelected = (number > 0);
    [self configureSelected:isSelected animated:animated complete:nil];
    
}

#pragma mark - Action

- (void)buttonDidPressed {
    if (self.didSelectBlock) {
        BOOL willSelect = !(self.number > 0);
        BOOL didChangeStatus = self.didSelectBlock(willSelect);
        if (didChangeStatus) {
            [self configureSelected:willSelect animated:YES complete:nil];
        }
        
    }
}

@end

@interface KKPImagePickerImageOnlyCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation KKPImagePickerImageOnlyCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor greenColor];
        [self addSubview:_imageView];
        
    }
    
    return self;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.size = (CGSize){self.width, self.height};

}

#pragma mark - Data

- (void)setAsset:(ALAsset *)asset {
    _asset = asset;
    
    UIImage *image = asset.galleryThumbmailImage;
    if (image) {
        self.imageView.image = image;
    } else {
        self.imageView.image = [UIImage imageNamed:@"ico_default_256"];
    }
    
}


@end


@implementation KKPImagePickerCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
    
    }
    return self;
}

@end
