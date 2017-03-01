//
//  YSCMicrophoneWaveViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/23.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCMicrophoneWaveViewController.h"
#import "YSCMicrophoneWaveView.h"

@interface YSCMicrophoneWaveViewController ()

@end

@implementation YSCMicrophoneWaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    YSCMicrophoneWaveView *microphoneWaveView = [[YSCMicrophoneWaveView alloc] init];
    [microphoneWaveView showMicrophoneWaveInParentView:self.view withFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
