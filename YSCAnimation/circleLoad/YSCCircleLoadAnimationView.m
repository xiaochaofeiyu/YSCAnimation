//
//  YSCCircleLoadAnimationView.m
//  AnimationDemo
//
//  Created by yushichao on 16/2/15.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCCircleLoadAnimationView.h"

@interface YSCCircleLoadAnimationView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *pathAnimationLayer;

@end

@implementation YSCCircleLoadAnimationView

- (void)removeFromParentView
{
    if (self.superview) {
        [_circleLayer removeFromSuperlayer];
        [_pathAnimationLayer removeFromSuperlayer];
        [self removeFromSuperview];
        [self.layer removeAllAnimations];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _circleRadius = 0;
        self.layer.backgroundColor = [UIColor grayColor].CGColor;
        [self addShapeLayer];
    }
    return self;
}

- (void)addShapeLayer
{
    self.layer.masksToBounds = YES;
    [self insertSubview:self.loadingImage atIndex:0];
    [self.layer addSublayer:self.pathAnimationLayer];
    [self.layer addSublayer:self.circleLayer];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_circleLayer removeFromSuperlayer];
    _loadingImage.layer.mask = _pathAnimationLayer;
    
    [self addMaskAnimation];
}

- (void)startLoading
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.duration = 2.0;
    animation.delegate = self;
    [_circleLayer addAnimation:animation forKey:@"end"];
}

- (void)addMaskAnimation
{
    CGFloat radius = 0 != _circleRadius ? _circleRadius : 50;
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    CGFloat maxRadius = fmax(self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:maxRadius/2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    _pathAnimationLayer.path = endPath.CGPath;
    _pathAnimationLayer.lineWidth = maxRadius;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    pathAnimation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    pathAnimation.duration = 2.0;
    
    CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    widthAnimation.fromValue = [NSNumber numberWithFloat:0];
    widthAnimation.toValue = [NSNumber numberWithFloat:maxRadius];
    widthAnimation.duration = 2.0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[pathAnimation, widthAnimation];
    group.duration = 2.0;
    
    [_pathAnimationLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
    [_pathAnimationLayer addAnimation:widthAnimation forKey:@"widthAnimation"];
    
}

- (CAShapeLayer *)circleLayer
{
    if (!_circleLayer) {
        self.circleLayer = [[CAShapeLayer alloc] init];
        _circleLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        _circleLayer.bounds = self.bounds;
        _circleLayer.backgroundColor = [UIColor grayColor].CGColor;
        CGFloat radius = 0 != _circleRadius ? _circleRadius : 50;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        _circleLayer.path = circlePath.CGPath;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor greenColor].CGColor;
        _circleLayer.lineWidth = 3.0;
        _circleLayer.strokeStart = 0.0;//
        _circleLayer.strokeEnd = 1.0;
    }
    
    return _circleLayer;
}

- (CAShapeLayer *)pathAnimationLayer
{
    if (!_pathAnimationLayer) {
        self.pathAnimationLayer = [[CAShapeLayer alloc] init];
        _pathAnimationLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        _pathAnimationLayer.bounds = self.bounds;
        _pathAnimationLayer.backgroundColor = [UIColor clearColor].CGColor;
        CGFloat radius = 0 != _circleRadius ? _circleRadius : 50;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
        _pathAnimationLayer.path = circlePath.CGPath;
        _pathAnimationLayer.fillColor = [UIColor clearColor].CGColor;
        _pathAnimationLayer.strokeColor = [UIColor greenColor].CGColor;
        _pathAnimationLayer.lineWidth = 3.0;
    }
    
    return _pathAnimationLayer;
}

- (UIImageView *)loadingImage
{
    if (!_loadingImage) {
        self.loadingImage = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    
    return _loadingImage;
}

@end
