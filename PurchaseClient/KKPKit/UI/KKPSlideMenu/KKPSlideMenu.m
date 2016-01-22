//
//  KKPSlideMenu.m
//  Hotspot
//
//  Created by wayne on 15/8/7.
//  Copyright (c) 2015年 NineGame. All rights reserved.
//

#import "KKPSlideMenu.h"
#import "FrameAccessor.h"
#import "KKPColor.h"
float const kKKPSlideMenuHeight = 40;
static float const kKKPSlideBlockHeight = 2;
static int const kMaxSingleScreenItems = 5;

void highlineUILabel(UILabel *label) {
    label.textColor = [KKPColor sharedColor].colorOrange;
//    label.layer.affineTransform = CGAffineTransformIdentity;
//    label.layer.affineTransform = CGAffineTransformMakeScale(1.1, 1.1);
}

void unHighlineUILabel(UILabel *label) {
    label.textColor = [KKPColor sharedColor].colorDarkGray;
//    label.layer.affineTransform = CGAffineTransformIdentity;
}


@interface KKPSlideMenu () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scollView;
@property (nonatomic, strong) UIView *slide;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, readwrite) NSArray *menus;
@property (nonatomic, assign) NSUInteger highlineIndex;
@property (nonatomic, assign) BOOL isAnimating;
@end



@implementation KKPSlideMenu
- (instancetype)initWithMenus:(NSArray *)menus contentView:(UIScrollView *)scrollView
{
    self = [self initWithMenus:menus];
    if (!self) {
        return nil;
    }
    
    self.contentView = scrollView;
    
    return self;
}

- (instancetype)initWithMenus:(NSArray *)menus {
    
    if (self = [super initWithFrame:(CGRect){0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kKKPSlideMenuHeight}]) {
        _menus = menus ? [menus copy] : [NSArray new];
        _titles = [NSMutableArray new];
        _toolbar = [[UIView alloc] init];
        _scollView = [[UIScrollView alloc] init];
        _slide = [[UIView alloc] init];
        _highlineIndex = 0;
        [self setupViews];
    }
    return self;
    
}

- (void)dealloc
{
     [self.contentView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)setupViews {
    
    _toolbar.frame = (CGRect){0,0,self.width,self.height};
    _toolbar.backgroundColor = [UIColor colorWithWhite:1. alpha:.95];

    [self addSubview:_toolbar];
    
    _scollView.frame = (CGRect){0,0,self.width,self.height};
    _scollView.showsHorizontalScrollIndicator = NO;
    [_toolbar addSubview:_scollView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapMenu:)];
    [_scollView addGestureRecognizer:tapGesture];
    
    __block CGFloat x = 15;
    [_menus enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UILabel *titleLabel = [self creatMenuButtonByTitle:title];
        titleLabel.userInteractionEnabled = NO;
        titleLabel.x = x;
        [_scollView addSubview:titleLabel];
        [_titles addObject:titleLabel];
        x += (titleLabel.width + 20);
    }];
    
    if (x < self.width) {
        [self layoutTitles:_titles];
    }
    
    _scollView.contentSize = (CGSize){x , kKKPSlideMenuHeight};
    
    //defualt highline
    UILabel *firstLabel = (UILabel *)_titles[0];
    highlineUILabel(firstLabel);
    
    _slide.frame = (CGRect){0, self.height-kKKPSlideBlockHeight, firstLabel.width, kKKPSlideBlockHeight};
    _slide.centerX = firstLabel.centerX;
    _slide.backgroundColor = [KKPColor sharedColor].colorOrange;
    [_scollView addSubview:_slide];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - .5, self.width, .5)];
    line.backgroundColor = [KKPColor sharedColor].colorLightGray;
    [self addSubview:line];
}

- (void)layoutTitles:(NSArray *)titles
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (titles.count <= kMaxSingleScreenItems) {
        __block CGFloat itemWidth = 15;
        [titles enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            itemWidth += label.width;
        }];
        itemWidth += 15;
        CGFloat gap = (width - itemWidth) / (titles.count - 1);
        itemWidth = 15;
        [titles enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.x = itemWidth;
            itemWidth += (gap + label.width);
        }];
    }
    
    if (titles.count <= 3) {
        [titles enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            label.centerX = width / ( titles.count * 2 ) * ( 2 * idx + 1 );
        }];
    }
}

- (UILabel *)creatMenuButtonByTitle:(NSString *)title {
    UILabel *menuButton = [[UILabel alloc] init];
    
    menuButton.text = title;
    menuButton.font = [UIFont systemFontOfSize:14.];
    menuButton.textColor = [KKPColor sharedColor].colorDarkGray;
    menuButton.textAlignment = NSTextAlignmentCenter;
    [menuButton sizeToFit];
    menuButton.size = (CGSize){menuButton.width, kKKPSlideMenuHeight};
    
    return menuButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)tapMenu:(UITapGestureRecognizer *)gesture {

    CGPoint pt = [gesture locationInView:self.scollView];
    __block NSInteger index = -1;
    [self.titles enumerateObjectsUsingBlock:^(UILabel *title, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(title.frame, pt)) {
            index = idx;
        }
    }];
    if (index>=0) {
        [self setCurrentIndex:index animated:YES];
    }
}

- (void)setCurrentIndex:(NSUInteger)index animated:(BOOL)animated {
    
    if (self.highlineIndex == index) {
        return;
    }
    
    if (self.willSlideToIndexBlock) {
        self.willSlideToIndexBlock(index);
    }
    
    if (animated) {
        self.isAnimating = YES;
        [UIView animateWithDuration:.3 animations:^{
            [self setCurrentIndex:index];
            [self centerizeMenuAtIndex:index];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            if (finished && self.didSlideToIndexBlock) {
                self.didSlideToIndexBlock(index);
            }
        }];
    } else {
        [self setCurrentIndex:index];
        [self centerizeMenuAtIndex:index];
        if (self.didSlideToIndexBlock) {
            self.didSlideToIndexBlock(index);
        }
    }
    
    
}

- (void)setCurrentIndex:(NSUInteger)index {
    
    UILabel *title = self.titles[index];
    UILabel *currentHighLineTitle = self.titles[self.highlineIndex];
    self.slide.frame = CGRectMake(title.x, self.slide.y, title.width, self.slide.height);

    unHighlineUILabel(currentHighLineTitle);
    highlineUILabel(title);

    self.highlineIndex = index;
    
    [self.contentView setContentOffset:CGPointMake(self.width * index,0) animated:YES];
}

- (void)centerizeMenuAtIndex:(NSUInteger)index {
    UILabel *menu = self.titles[index];
    CGFloat targetX = self.width/2 - menu.width/2;
    CGFloat offset = menu.x - targetX;
    if (offset<0) {
        offset = 0;
    } else if ( offset + self.width > self.scollView.contentSizeWidth) {
        if (self.width < self.scollView.contentSizeWidth) {
            offset = self.scollView.contentSizeWidth - self.width;
        } else {
            return;
        }
    }
    self.scollView.contentOffsetX = offset;

}


- (void)scrollWithPercentage:(CGFloat)percentage {
    
    UILabel *nextLabel, *preLabel;
    CGFloat scale = 0.;
    if (percentage >= 0) {
        //-->
        int changeIndex = (int)floor(percentage) + 1;
        if (self.titles.count-1 >= self.highlineIndex+changeIndex) {
            preLabel = (UILabel *)self.titles[self.highlineIndex+changeIndex-1];
            nextLabel = self.titles[self.highlineIndex+changeIndex];
            self.slide.x = preLabel.x + (nextLabel.x - preLabel.x) * (percentage - floor(percentage));
            self.slide.width = preLabel.width + (nextLabel.width - preLabel.width) * (percentage - floor(percentage));
            scale = percentage;
        }
    } else {
        //<--
        int changeIndex = (int)floor(percentage);
        if ( ((NSInteger)self.highlineIndex+changeIndex) >=0) {
            nextLabel = self.titles[self.highlineIndex+changeIndex];
            preLabel = (UILabel *)self.titles[self.highlineIndex+changeIndex+1];
            CGFloat percentageBase = 1 - percentage + floor(percentage) ;
            self.slide.x = preLabel.x + (nextLabel.x - preLabel.x) * percentageBase;
            self.slide.width = preLabel.width + (nextLabel.width - preLabel.width) * percentageBase;
            scale = -percentage;
        }
    }


}

- (void)setContentView:(UIScrollView *)contentView {
    
    if (_contentView && _contentView != contentView) {
        [_contentView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    _contentView = contentView;
    if (_contentView) {
        [_contentView addObserver:self
                       forKeyPath:@"contentOffset"
                          options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        _contentView.pagingEnabled = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.contentView && [keyPath isEqualToString:@"contentOffset"] && !self.isAnimating) {
        CGFloat currentOffset = self.contentView.width * self.highlineIndex;
        CGFloat newOffset = self.contentView.contentOffsetX - currentOffset;
        CGFloat targetOffset;
        if (newOffset>0) {
            targetOffset = self.contentView.width * (self.highlineIndex + 1);
        } else {
            targetOffset = self.contentView.width * (self.highlineIndex - 1);
        }
        CGFloat percentage = newOffset / ABS(targetOffset - currentOffset);

        [self scrollWithPercentage:percentage];
    }
}

@end
