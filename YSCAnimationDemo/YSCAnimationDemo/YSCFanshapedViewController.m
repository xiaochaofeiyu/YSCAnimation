//
//  YSCFanshapedViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/24.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCFanshapedViewController.h"
#import "YSCFanShapedView.h"

@interface YSCFanshapedViewController ()

@property (nonatomic, strong) YSCFanShapedView *fanshapedView;
@property (nonatomic, strong) UIButton *fanShapedbutton;
@end

@implementation YSCFanshapedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.fanShapedbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    _fanShapedbutton.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0 + 100);
    [_fanShapedbutton setTitle:@"fanshaped expand" forState:UIControlStateNormal];
    _fanShapedbutton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [_fanShapedbutton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fanShapedbutton];
    
    [self.fanshapedView showInParentView:self.view WithType:YSCFanShapedShowTypeExpand];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonTouched:(UIButton *)sender
{
    static NSInteger type = 0;
    type++;
    if (type % 2 == 0) {
        [_fanShapedbutton setTitle:@"fanshaped Shrink" forState:UIControlStateNormal];
    } else {
        [_fanShapedbutton setTitle:@"fanshaped expand" forState:UIControlStateNormal];
    }
    [self.fanshapedView setShowType:type % 2];
}

- (YSCFanShapedView *)fanshapedView
{
    if (!_fanshapedView) {
        self.fanshapedView = [[YSCFanShapedView alloc] init];
        _fanshapedView.frame = CGRectMake(0, 0, 300, 150);
        _fanshapedView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0 - 100);        
    }
    
    return _fanshapedView;
}

@end
