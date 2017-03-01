//
//  YSCFireViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/25.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCFireViewController.h"

@interface YSCFireViewController () {
    CAEmitterLayer * _fireEmitter;//发射器对象
}
@end

@implementation YSCFireViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    //设置发射器
    _fireEmitter=[[CAEmitterLayer alloc] init];
    _fireEmitter.emitterPosition=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-20);
    _fireEmitter.emitterSize=CGSizeMake(self.view.frame.size.width-100, 20);
    _fireEmitter.renderMode = kCAEmitterLayerAdditive;
    //发射单元
    //火焰
    CAEmitterCell *fire = [CAEmitterCell emitterCell];
    fire.birthRate=800;
    fire.lifetime=2.0;
    fire.lifetimeRange=1.5;
    fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    fire.contents=(id)[[UIImage imageNamed:@"fire"] CGImage];
    [fire setName:@"fire"];
    
    fire.velocity=160;
    fire.velocityRange=80;
    fire.emissionLongitude=M_PI+M_PI_2;
    fire.emissionRange=M_PI_2;
    
    fire.scaleSpeed=0.3;
    fire.spin=0.2;
    fire.alphaSpeed = -0.05;
    
    //烟雾
    CAEmitterCell *smoke = [CAEmitterCell emitterCell];
    smoke.birthRate=400;
    smoke.lifetime=3.0;
    smoke.lifetimeRange=1.5;
    smoke.color=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05] CGColor];
    smoke.contents=(id)[[UIImage imageNamed:@"fire"] CGImage];
    [smoke setName:@"smoke"];
    
    smoke.velocity=250;
    smoke.velocityRange=100;
    smoke.emissionLongitude=M_PI+M_PI_2;
    smoke.emissionRange=M_PI_2;
    smoke.alphaSpeed = -0.05;
    
    _fireEmitter.emitterCells=[NSArray arrayWithObjects:smoke, fire,nil];
    [self.view.layer addSublayer:_fireEmitter];
    
}

@end
