//
//  YSCWaterWaveViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/24.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCWaterWaveViewController.h"
#import "YSCWaterWaveView.h"

@interface YSCWaterWaveViewController ()

@property (nonatomic, strong) YSCWaterWaveView *waterWave;
@property (nonatomic, strong) UIButton *waterWaveShowButton;

@end

@implementation YSCWaterWaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.waterWave];
    [self.view addSubview:self.waterWaveShowButton];
    [self.waterWave startWave];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)waterWaveShowButtonTouched:(UIButton *)sender
{
    static NSInteger status = 1;
    status++;
    if (status % 2 == 0) {
        [_waterWaveShowButton setTitle:@"show" forState:UIControlStateNormal];
        [self.waterWave stopWave];
    } else {
        [_waterWaveShowButton setTitle:@"hide" forState:UIControlStateNormal];
        [self.view addSubview:self.waterWave];
        [self.waterWave startWave];
    }
}

- (YSCWaterWaveView *)waterWave
{
    if (!_waterWave) {
        self.waterWave = [[YSCWaterWaveView alloc] init];
        _waterWave.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);
        _waterWave.percent = 0.6;
        _waterWave.firstWaveColor = [UIColor colorWithRed:146/255.0 green:148/255.0 blue:216/255.0 alpha:1.0];
        _waterWave.secondWaveColor = [UIColor colorWithRed:84/255.0 green:87/255.0 blue:197/255.0 alpha:1.0];
    }
    
    return _waterWave;
}

- (UIButton *)waterWaveShowButton
{
    if (!_waterWaveShowButton) {
        self.waterWaveShowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        _waterWaveShowButton.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0 + 200);
        [_waterWaveShowButton setTitle:@"hide" forState:UIControlStateNormal];
        _waterWaveShowButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [_waterWaveShowButton addTarget:self action:@selector(waterWaveShowButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _waterWaveShowButton;
}

@end
