

#import "KKPTableViewCell.h"

@class KKPButton;
@interface KKPTableViewCell (Private)

@property (nonatomic, readonly) UIImageView *avatarImageView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *subtitleLabel;
@property (nonatomic, readonly) UILabel *rightLabel;
@property (nonatomic, readonly) UIImageView *rightArrowImageView;
@property (nonatomic, readonly) KKPButton *rightButton;

@end
