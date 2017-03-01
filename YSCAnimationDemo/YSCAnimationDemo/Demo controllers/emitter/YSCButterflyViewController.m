//
//  YSCButterflyViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/25.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCButterflyViewController.h"

@interface YSCButterflyViewController () {
    CAEmitterLayer * _butterflyEmitter;//
}
@end

@implementation YSCButterflyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    //emitter
    _butterflyEmitter=[[CAEmitterLayer alloc] init];
    _butterflyEmitter.emitterPosition=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-20);
    _butterflyEmitter.emitterSize=CGSizeMake(self.view.frame.size.width-100, 20);
    _butterflyEmitter.renderMode = kCAEmitterLayerUnordered;
    _butterflyEmitter.emitterShape = kCAEmitterLayerCuboid;
    
    _butterflyEmitter.emitterDepth = 10;
    _butterflyEmitter.preservesDepth = YES;
    
    //cells
    //blue butterfly
    CAEmitterCell *blueButterfly = [CAEmitterCell emitterCell];
    blueButterfly.birthRate=8;
    blueButterfly.lifetime=5.0;
    blueButterfly.lifetimeRange=1.5;
    blueButterfly.color=[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
    blueButterfly.contents=(id)[[UIImage imageNamed:@"butterfly1"] CGImage];
    [blueButterfly setName:@"blueButterfly"];
    
    blueButterfly.velocity=160;
    blueButterfly.velocityRange=80;
    blueButterfly.emissionLongitude=M_PI+M_PI_2;
    blueButterfly.emissionLatitude = M_PI+M_PI_2;
    blueButterfly.emissionRange=M_PI_2;
    
    blueButterfly.scaleSpeed=0.3;
    blueButterfly.spin=0.2;
    blueButterfly.alphaSpeed = 0.2;
    
    //yellow butterfly
    CAEmitterCell *yellowButterfly = [CAEmitterCell emitterCell];
    yellowButterfly.birthRate=4;
    yellowButterfly.lifetime=5.0;
    yellowButterfly.lifetimeRange=1.5;
    yellowButterfly.color=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05] CGColor];
    yellowButterfly.contents=(id)[[UIImage imageNamed:@"butterfly2"] CGImage];
    [yellowButterfly setName:@"yellowButterfly"];
    
    yellowButterfly.velocity=250;
    yellowButterfly.velocityRange=100;
    yellowButterfly.emissionLongitude=M_PI+M_PI_2;
    yellowButterfly.emissionLatitude = M_PI+M_PI_2;
    yellowButterfly.emissionRange=M_PI_2;
    yellowButterfly.alphaSpeed = 0.2;
    yellowButterfly.scaleSpeed=0.3;
    yellowButterfly.spin=0.2;
    _butterflyEmitter.emitterCells=[NSArray arrayWithObjects:yellowButterfly, blueButterfly,nil];
    [self.view.layer addSublayer:_butterflyEmitter];
    
}

@end
