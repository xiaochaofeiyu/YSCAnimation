//
//  YSCRippleAnimationViewController.m
//  AnimationLearn
//
//  Created by yushichao on 16/8/19.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCRippleAnimationViewController.h"
#import "YSCRippleView.h"

@interface YSCRippleAnimationViewController ()

@property (nonatomic, strong) YSCRippleView *rippleView;

@end

@implementation YSCRippleAnimationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *lineRippleButton = [[UIButton alloc] initWithFrame:CGRectMake(20 , 320, 150, 50)];
    [lineRippleButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [lineRippleButton setTitle:@"singleLineRipple" forState:UIControlStateNormal];
    [lineRippleButton addTarget:self action:@selector(lineRippleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lineRippleButton];
    
    UIButton *ringRippleButton = [[UIButton alloc] initWithFrame:CGRectMake(200 , 320, 150, 50)];
    [ringRippleButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [ringRippleButton setTitle:@"ringRipple" forState:UIControlStateNormal];
    [ringRippleButton addTarget:self action:@selector(ringRippleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ringRippleButton];
    
    UIButton *circleRippleButton = [[UIButton alloc] initWithFrame:CGRectMake(20 , 400, 150, 50)];
    [circleRippleButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [circleRippleButton setTitle:@"circleRipple" forState:UIControlStateNormal];
    [circleRippleButton addTarget:self action:@selector(circleRippleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:circleRippleButton];
    
    UIButton *mixedRippleButton = [[UIButton alloc] initWithFrame:CGRectMake(200 , 400, 150, 50)];
    [mixedRippleButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [mixedRippleButton setTitle:@"mixedRipple" forState:UIControlStateNormal];
    [mixedRippleButton addTarget:self action:@selector(mixedRippleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mixedRippleButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lineRippleButtonTouched:(id)sender
{
    [self removeSubViews];
    [self.view addSubview:self.rippleView];
    [_rippleView showWithRippleType:YSCRippleTypeLine];
}
- (void)ringRippleButtonTouched:(id)sender
{
    [self removeSubViews];
    [self.view addSubview:self.rippleView];
    [_rippleView showWithRippleType:YSCRippleTypeRing];
}
- (void)circleRippleButtonTouched:(id)sender
{
    [self removeSubViews];
    [self.view addSubview:self.rippleView];
    [_rippleView showWithRippleType:YSCRippleTypeCircle];
}
- (void)mixedRippleButtonTouched:(id)sender
{
    [self removeSubViews];
    [self.view addSubview:self.rippleView];
    [_rippleView showWithRippleType:YSCRippleTypeMixed];
}

- (void)removeSubViews
{
    if (_rippleView.superview == self.view) {
        [_rippleView removeFromParentView];
    }
}

- (YSCRippleView *)rippleView
{
    if (!_rippleView) {
        self.rippleView = [[YSCRippleView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    }
    
    return _rippleView;
}

@end
