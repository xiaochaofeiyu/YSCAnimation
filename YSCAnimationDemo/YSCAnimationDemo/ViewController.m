//
//  ViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/22.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "ViewController.h"
#import "YSCAnimationDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YSCAnimationDemoViewController *demoMainViewController = [[YSCAnimationDemoViewController alloc] init];
    [self pushViewController:demoMainViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
