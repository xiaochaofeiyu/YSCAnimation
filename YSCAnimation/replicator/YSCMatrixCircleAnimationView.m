//
//  YSCMatrixCircleAnimationView.m
//  YSCAnimationDemo
//
//  Created by 工作号 on 16/8/28.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCMatrixCircleAnimationView.h"

@implementation YSCMatrixCircleAnimationView

- (instancetype)initWithFrame:(CGRect)frame xNum:(NSInteger)xNum yNum:(NSInteger)yNum
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLayersWithXNum:xNum yNum:yNum];
    }
    return self;
}

- (void)setUpLayersWithXNum:(NSInteger)xNum yNum:(NSInteger)yNum
{
    CGFloat circleMargin = 5.0;
    CGFloat width = self.bounds.size.width;
    CGFloat circleWidth = (width - (circleMargin * xNum  - 1)) / xNum;
    
    CAShapeLayer *circleShapeLayer = [CAShapeLayer layer];
    circleShapeLayer.bounds = CGRectMake(0, 0, circleWidth, circleWidth);
    circleShapeLayer.position = CGPointMake(circleWidth / 2.0, circleWidth / 2.0);
    circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, circleWidth, circleWidth)].CGPath;
    circleShapeLayer.fillColor = [UIColor redColor].CGColor;
    
    CAReplicatorLayer *xReplicator = [CAReplicatorLayer layer];
    xReplicator.bounds = CGRectMake(0, 0, width, circleWidth);
    xReplicator.position = CGPointMake(width / 2.0, circleWidth / 2.0);
    xReplicator.instanceDelay = 0.3;
    xReplicator.instanceCount = xNum;

    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, circleWidth + circleMargin, 0, 0.0);
    xReplicator.instanceTransform = transform;
    transform = CATransform3DScale(transform, 1, -1, 0);

    CAReplicatorLayer *yReplicator = [CAReplicatorLayer layer];
    yReplicator.bounds = CGRectMake(0, 0, width, width);
    yReplicator.position = CGPointMake(width / 2.0, width / 2.0);
    yReplicator.instanceDelay = 0.3;
    yReplicator.instanceCount = yNum;

    CATransform3D transformY = CATransform3DIdentity;
    transformY = CATransform3DTranslate(transformY, 0, circleWidth + circleMargin, 0.0);
    yReplicator.instanceTransform = transformY;

    [xReplicator addSublayer:circleShapeLayer];
    [yReplicator addSublayer:xReplicator];
    [self.layer addSublayer:yReplicator];
    
    [self addAnimationToLayer:circleShapeLayer];
}

- (void)addAnimationToLayer:(CAShapeLayer *)layer
{
    CABasicAnimation *alphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnim.fromValue = [NSNumber numberWithFloat:1.0];
    alphaAnim.toValue = [NSNumber numberWithFloat:0.3];
    
    CABasicAnimation *scaleAnim =[CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D t = CATransform3DIdentity;
    CATransform3D t2 = CATransform3DScale(t, 1.0, 1.0, 0.0);
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:t2];
    CATransform3D t3 = CATransform3DScale(t, 0.2, 0.2, 0.0);
    scaleAnim.toValue = [NSValue valueWithCATransform3D:t3];
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[alphaAnim, scaleAnim];
    groupAnimation.duration = 1.0;
    groupAnimation.autoreverses = YES;
    groupAnimation.repeatCount = HUGE;
    
    [layer addAnimation:groupAnimation forKey:nil];
}

@end
