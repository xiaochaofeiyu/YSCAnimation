//
//  YSCCircleReplicatorAnimationViewController.m
//  YSCAnimationDemo
//
//  Created by 工作号 on 16/8/28.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCCircleReplicatorAnimationViewController.h"
#import "YSCMatrixCircleAnimationView.h"

@interface YSCCircleReplicatorAnimationViewController ()

@property (nonatomic, strong) YSCMatrixCircleAnimationView *matrixCircleView;

@end

@implementation YSCCircleReplicatorAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.matrixCircleView = [[YSCMatrixCircleAnimationView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) xNum:8 yNum:8];
    _matrixCircleView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    
    [self.view addSubview:_matrixCircleView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
