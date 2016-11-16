//
//  YSCHeartBeatPulseViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2016/11/16.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCHeartBeatPulseViewController.h"
#import "YSCHeartBeatPulseView.h"

@interface YSCHeartBeatPulseViewController ()

@property (nonatomic, strong) YSCHeartBeatPulseView *heartBeatPulseView;

@end

@implementation YSCHeartBeatPulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.heartBeatPulseView = [[YSCHeartBeatPulseView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    _heartBeatPulseView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    [self.view addSubview:_heartBeatPulseView];
    
    [_heartBeatPulseView startHeartBeat];
    [_heartBeatPulseView setHeartBeatSpeed:2];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_heartBeatPulseView pauseHeartBeat];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_heartBeatPulseView startHeartBeat];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_heartBeatPulseView stopHeartBeat];
    [_heartBeatPulseView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
