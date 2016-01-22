//
//  NWTestWindow.m
//  NewWorld
//
//  Created by  liuyunxuan on 16/1/10.
//  Copyright © 2016年  liuyunxuan. All rights reserved.
//

#import "NWTestWindow.h"


#ifdef NWTest

#define NWLog(x) NSLog(x)

#else

#define NWLog(x)

#endif
@interface NWTestWindowButton : UIButton

@end

@implementation NWTestWindowButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NWLog(@"B - touchesBeagan..");
    // 把事件传递下去给父View或包含他的ViewController
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NWLog(@"B - touchesCancelled..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesCancelled:touches withEvent:event];
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NWLog(@"B - touchesEnded..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NWLog(@"B - touchesMoved..");
    // 把事件传递下去给父View或包含他的ViewController
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
    
}
@end

@interface NWTestWindow()

@property (nonatomic, strong) UIButton *buttonA;
@property (nonatomic, strong) UIButton *buttonB;

@end

@implementation NWTestWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self)
    {
        [self addSubview:self.buttonA];
        [self.buttonA addTarget:self action:@selector(aButtonDidSelected) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.buttonB];
        [self.buttonB addTarget:self action:@selector(bButtonDidSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:[UIApplication sharedApplication].windows.firstObject];
    self.center = currentLocation;
}

- (UIButton *)buttonA
{
    if (!_buttonA)
    {
        _buttonA = [NWTestWindowButton buttonWithType:UIButtonTypeCustom];
//        [_buttonA addTarget:self action:@selector(aButtonDidSelected) forControlEvents:UIControlEventTouchUpInside];
        _buttonA.backgroundColor = [UIColor redColor];
        [_buttonA setTitle:@"A" forState:UIControlStateNormal];
        _buttonA.frame = CGRectMake(0, 0, 50, 100);
    }
    return _buttonA;
}

- (UIButton *)buttonB
{
    if (!_buttonB)
    {
        _buttonB = [NWTestWindowButton buttonWithType:UIButtonTypeCustom];
        _buttonB.backgroundColor = [UIColor blueColor];
        [_buttonB setTitle:@"B" forState:UIControlStateNormal];
        _buttonB.frame = CGRectMake(50, 0, 50, 100);
    }
    return _buttonB;
}

- (void)aButtonDidSelected
{
    if(self.actionA)
    {
        self.actionA();
    }
}

- (void)bButtonDidSelected
{
    if (self.actionB)
    {
        self.actionB();
    }
}

+ (Action)action:(Action)action
{
    return action;
}
@end
