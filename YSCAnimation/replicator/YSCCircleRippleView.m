//
//  YSCCircleRippleView.m
//  YSCAnimationDemo
//
//  Created by 工作号 on 16/8/28.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCCircleRippleView.h"

@interface YSCCircleRippleView ()

@property (nonatomic, strong) CAShapeLayer *circleShapeLayer;

@end

@implementation YSCCircleRippleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLayers];
    }
    return self;
}

- (void)setUpLayers
{
    CGFloat width = self.bounds.size.width;
    
    self.circleShapeLayer = [CAShapeLayer layer];
    _circleShapeLayer.bounds = CGRectMake(0, 0, width, width);
    _circleShapeLayer.position = CGPointMake(width / 2.0, width / 2.0);
    _circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, width, width)].CGPath;
    _circleShapeLayer.fillColor = [UIColor redColor].CGColor;
    _circleShapeLayer.opacity = 0.0;
    
    CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
    replicator.bounds = CGRectMake(0, 0, width, width);
    replicator.position = CGPointMake(width / 2.0, width / 2.0);
    replicator.instanceDelay = 0.5;
    replicator.instanceCount = 8;
    
    [replicator addSublayer:_circleShapeLayer];
    [self.layer addSublayer:replicator];
}

- (void)startAnimation
{
    CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnim.fromValue = [NSNumber numberWithFloat:0.6];
    alphaAnim.toValue = [NSNumber numberWithFloat:0.0];
    
    CABasicAnimation *scaleAnim =[CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D t = CATransform3DIdentity;
    CATransform3D t2 = CATransform3DScale(t, 0.0, 0.0, 0.0);
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:t2];
    CATransform3D t3 = CATransform3DScale(t, 1.0, 1.0, 0.0);
    scaleAnim.toValue = [NSValue valueWithCATransform3D:t3];
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[alphaAnim, scaleAnim];
    groupAnimation.duration = 4.0;
    groupAnimation.autoreverses = NO;
    groupAnimation.repeatCount = HUGE;
    
    [_circleShapeLayer addAnimation:groupAnimation forKey:nil];
}

- (void)stopAnimation
{
    [_circleShapeLayer removeAllAnimations];
}

@end
