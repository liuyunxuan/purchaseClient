
#import "KKPImagePickerNoAccessVC.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIViewController+SCNavigation.h"
#import "FrameAccessor.h"
#import "KKPColor.h"

#import "KKPButton.h"
#import "KKPButton+Private.h"


@interface KKPImagePickerNoAccessVC ()

@property (nonatomic, strong) KKPButton *noAccessButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation KKPImagePickerNoAccessVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    

    return self;

}

- (void)loadView {
    [super loadView];
    
    self.noAccessButton = [KKPButton buttonWithType:KKPButtonType2];
    self.noAccessButton.showBorder = NO;
    self.noAccessButton.font = [UIFont boldSystemFontOfSize:16];
    self.noAccessButton.title = @"允许访问";
    self.noAccessButton.backgroundColorHighlighted = [UIColor clearColor];
    self.noAccessButton.borderColorHighlighted = [UIColor clearColor];
    [self.noAccessButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.noAccessButton];
    
    [self titleLabel];
    [self descriptionLabel];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Views

- (UILabel *)titleLabel {
    if (nil == _titleLabel) {
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        [self.view addSubview:label];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes1 = @{
                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                      NSParagraphStyleAttributeName: style,
                                      NSForegroundColorAttributeName: kColor.colorBlack,
                                      };
        NSDictionary *attributes2 = @{
                                      NSFontAttributeName: [UIFont systemFontOfSize:16],
                                      NSParagraphStyleAttributeName: style,
                                      NSForegroundColorAttributeName: kColor.colorGray,
                                      };
        
        NSMutableAttributedString *attr = [NSMutableAttributedString new];
        
        NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:@"请允许九游访问您的照片或相机\n"
                                                                    attributes:attributes1];
        NSAttributedString *attr2 = [[NSAttributedString alloc] initWithString:@"⌜留住并分享最美一刻⌟"
                                                                    attributes:attributes2];
        
        [attr appendAttributedString:attr1];
        [attr appendAttributedString:attr2];
        
        
        label.attributedText = attr;
        label.frame = [attr boundingRectWithSize:(CGSize){self.view.width - 30, self.view.height}
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
        
        _titleLabel = label;
    }
    
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    if (nil == _descriptionLabel) {
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        [self.view addSubview:label];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:12],
                                     NSParagraphStyleAttributeName: style,
                                     NSForegroundColorAttributeName: kColor.colorGray,
                                     };
        
        NSString *des = @"若无法跳转，请在 iPhone 的：设置 > 隐私 > 相机或照片选项中，允许九游访问您的相机或照片";
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:des attributes:attributes];
        label.attributedText = attr;
        label.frame = [attr boundingRectWithSize:(CGSize){self.view.width - 30, self.view.height}
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
        
        _descriptionLabel = label;
    }
    
    return _descriptionLabel;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.noAccessButton.frame = (CGRect){0, 0, 200, 44};
    self.noAccessButton.center = (CGPoint){self.view.centerX, self.view.centerY + 32};
    
    self.titleLabel.centerX = self.view.width/2;
    self.titleLabel.centerY = (self.noAccessButton.top - 64)/2 + 64 - 7;
    self.descriptionLabel.centerX = self.view.width/2;
    self.descriptionLabel.bottom = self.view.height - 17;
    
}

#pragma mark - Action

- (void)openSettings
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
