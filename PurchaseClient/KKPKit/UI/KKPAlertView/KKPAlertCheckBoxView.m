
#import "KKPAlertCheckBoxView.h"
#import "KKPColor.h"
#import "FrameAccessor.h"



@interface KKPAlertCheckBoxView ()

@property (nonatomic, strong) UIButton *checkBoxButton;
@property (nonatomic, strong) UILabel *checkMessageLabel;
@property (nonatomic, strong) UIButton *checkActionButton;

@end

@implementation KKPAlertCheckBoxView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        UIButton *checkActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkActionButton addTarget:self action:@selector(checkBoxAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkActionButton];
        _checkActionButton = checkActionButton;

        UILabel *checkMessageLabel = [[UILabel alloc] initWithFrame:self.bounds];
        checkMessageLabel.font = [UIFont systemFontOfSize:13];
        checkMessageLabel.textColor = kColor.colorBlack;
        checkMessageLabel.userInteractionEnabled = NO;
        [self addSubview:checkMessageLabel];
        _checkMessageLabel = checkMessageLabel;
        
        UIButton *checkBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBoxButton setImage:[UIImage imageNamed:@"checkbox_dialog"] forState:UIControlStateNormal];
        [checkBoxButton setImage:[UIImage imageNamed:@"checkbox_check_Dialog"] forState:UIControlStateSelected];
        [checkBoxButton setImage:[UIImage imageNamed:@"checkbox_check_Dialog"] forState:UIControlStateHighlighted];
        [checkBoxButton sizeToFit];
        [checkBoxButton addTarget:self action:@selector(checkBoxAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkBoxButton];
        _checkBoxButton = checkBoxButton;
        
    }
    return self;
}

#pragma mark - Setters

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    
    self.checkBoxButton.selected = checked;
}

- (void)setCheckMessage:(NSString *)checkMessage {
    _checkMessage = checkMessage;
    
    self.checkMessageLabel.text = checkMessage;
    [self.checkMessageLabel sizeToFit];
    
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.width = self.checkMessageLabel.width + self.checkBoxButton.width + 6;
    self.centerX = self.superview.width/2;
    self.checkBoxButton.left = 0;
    self.checkMessageLabel.left = self.checkBoxButton.right + 6;
    self.checkBoxButton.centerY = self.height/2;
    self.checkMessageLabel.centerY = self.height/2;
    self.checkActionButton.frame = self.bounds;
    
}

#pragma mark - Action

- (void)checkBoxAction {
    
    if (self.chekStatusChangeBlock) {
        self.checked = !self.checked;
        self.chekStatusChangeBlock(self.checked);
    }
}

@end
