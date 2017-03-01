//
//  YSCCarouselTitleViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/2/28.
//  Copyright © 2017年 YSC. All rights reserved.
//

#import "YSCCarouselTitleViewController.h"
#import "YSCCarouselTitleView.h"

@interface YSCCarouselTitleViewController ()

@property (nonatomic, strong) YSCCarouselTitleView *shortTitleView;
@property (nonatomic, strong) YSCCarouselTitleView *longTitleView;

@end

@implementation YSCCarouselTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.shortTitleView = [[YSCCarouselTitleView alloc] initWithFrame:CGRectMake(100, 100, self.view.bounds.size.width - 100 * 2, 40)];
    _shortTitleView.title = @"静态--标题比较短";
    [self.view addSubview:_shortTitleView];
    
    self.longTitleView = [[YSCCarouselTitleView alloc] initWithFrame:CGRectMake(100, 200, self.view.bounds.size.width - 100 * 2, 40)];
    _longTitleView.title = @"轮播--标题要长长长长长长长长长长长长长长长长长长长长长";
    [self.view addSubview:_longTitleView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
