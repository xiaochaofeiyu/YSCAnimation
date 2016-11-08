//
//  YSCVoiceLoadingCircleView.m
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/8/15.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#define voiceCircleLayerWidth (3 * _voiceCircleRadius)
#define voiceCircleRadiusZoomOutRatio 0.33
#define voiceCircleRadiusZoomInRatio 1.15
#define voiceCircleCustomDuration 1.0
#define voiceCircleScaleDuration 0.3

#import "YSCVoiceLoadingCircleView.h"

@interface YSCVoiceLoadingCircleView ()

@property (nonatomic, strong) UIImageView *firstCircle;
@property (nonatomic, strong) UIImageView *secondCircle;
@property (nonatomic, strong) CAShapeLayer *firstCircleShapeLayer;
@property (nonatomic, strong) CAShapeLayer *secondCircleShapeLayer;
@property (nonatomic, strong) CAShapeLayer *whiteBackgroundLayer;

@end

@implementation YSCVoiceLoadingCircleView {
    CGFloat _voiceCircleRadius;
    CGFloat _voiceCircleDistanceOffset;
    CGFloat _whiteBackgroundLayerRadius;
    CGPoint _center;
}

- (instancetype)initWithCircleRadius:(CGFloat)radius center:(CGPoint)center
{
    self = [super init];
    if (self) {
        _voiceCircleRadius = radius;
        _center = center;
        _voiceCircleDistanceOffset = radius / 25;
        _whiteBackgroundLayerRadius = _voiceCircleRadius + 3 * _voiceCircleDistanceOffset;
    }
    return self;
}

- (void)startLoadingInParentView:(UIView *)parentView
{
    if (![self.superview isKindOfClass:[parentView class]]) {
        [parentView addSubview:self];
    } else {
        return;
    }
//    self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    self.bounds = CGRectMake(0, 0, 4 * _voiceCircleRadius, 4 * _voiceCircleRadius);
    self.center = _center;
    
//    self.frame = CGRectMake(0, 0, parentView.bounds.size.width, parentView.bounds.size.height);
    
    [self.layer insertSublayer:self.whiteBackgroundLayer atIndex:0];
    _whiteBackgroundLayer.path = [self generateBezierPathWithCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0) radius:_whiteBackgroundLayerRadius].CGPath;
    
    [self addSubview:self.firstCircle];
    _firstCircle.frame = CGRectMake(0, 0, voiceCircleLayerWidth, voiceCircleLayerWidth);
    _firstCircle.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 - _voiceCircleDistanceOffset);
    CGFloat firsCircleWidth = 2;
    self.firstCircleShapeLayer = [self generateShapeLayerWithLineWidth:firsCircleWidth];
    _firstCircleShapeLayer.path = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius].CGPath;
    _firstCircle.layer.mask = _firstCircleShapeLayer;
    //    _firstCircle.alpha = 0.0;
    
    [self addSubview:self.secondCircle];
    _secondCircle.frame = CGRectMake(0, 0, voiceCircleLayerWidth, voiceCircleLayerWidth);
    _secondCircle.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 + _voiceCircleDistanceOffset);
    CGFloat secondCircleWidth = 2;
    self.secondCircleShapeLayer = [self generateShapeLayerWithLineWidth:secondCircleWidth];
    _secondCircleShapeLayer.path = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius].CGPath;
    _secondCircle.layer.mask = _secondCircleShapeLayer;
    //    _secondCircle.alpha = 0.0;
    
    [self addAnimationToFirsrCircle];
    [self addAnimationToSecondCircle];
    [self addAnimationToSelfLayer];
    [self addAnimationToWhiteBackground];
}

- (void)stopLoading
{
    [_firstCircleShapeLayer removeAllAnimations];
    [_secondCircleShapeLayer removeAllAnimations];
    [self.layer removeAllAnimations];
    [_firstCircle removeFromSuperview];
    [_secondCircle removeFromSuperview];
    [_whiteBackgroundLayer removeFromSuperlayer];
    _firstCircle = nil;
    _secondCircle = nil;
    _whiteBackgroundLayer = nil;
    [self removeFromSuperview];
}

- (void)addAnimationToFirsrCircle
{
    _firstCircle.layer.opacity = 1.0;
    
    //透明度
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = [NSNumber numberWithFloat:0.0];
    opacity.toValue = [NSNumber numberWithFloat:1.0];
    opacity.duration = voiceCircleScaleDuration;
    opacity.delegate = self;
    opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//
//    opacity.beginTime = CACurrentMediaTime() ;
    
    //上下抖动
    CGPoint beginPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 - _voiceCircleDistanceOffset);
    CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 - 2 * _voiceCircleDistanceOffset);
    
    CAKeyframeAnimation *positionLine = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionLine.values = @[[NSValue valueWithCGPoint:beginPoint], [NSValue valueWithCGPoint:endPoint], [NSValue valueWithCGPoint:beginPoint]];
    positionLine.duration = voiceCircleCustomDuration;
    positionLine.repeatCount = INFINITY;
    positionLine.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//
//    positionLine.beginTime = CACurrentMediaTime();
    
    //放大缩小
    UIBezierPath *beginPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius * voiceCircleRadiusZoomOutRatio];
    UIBezierPath *midPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius * voiceCircleRadiusZoomInRatio];
    UIBezierPath *endPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius];
    
    CAKeyframeAnimation *scaleAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    scaleAniamtion.values = @[(__bridge id _Nullable)beginPath.CGPath, (__bridge id _Nullable)midPath.CGPath, (__bridge id _Nullable)endPath.CGPath];
    scaleAniamtion.duration = voiceCircleScaleDuration;
    scaleAniamtion.keyTimes = @[@0, @0.375, @1.0];//
//    scaleAniamtion.beginTime = CACurrentMediaTime();
//    scaleAniamtion.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :0.80 :1.00 :1.00];
    
    //转圈
    CAKeyframeAnimation *transformAngle = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    transformAngle.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.5*M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.5*M_PI, 0, 0, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(2*M_PI, 0, 0, 1)]];
    transformAngle.duration = voiceCircleCustomDuration;
    transformAngle.repeatCount = INFINITY;
    transformAngle.calculationMode = kCAAnimationLinear;
//    transformAngle.beginTime = CACurrentMediaTime();
    
    [_firstCircle.layer addAnimation:opacity forKey:nil];
    [_firstCircle.layer addAnimation:positionLine forKey:nil];
    [_firstCircleShapeLayer addAnimation:scaleAniamtion forKey:nil];
    [_firstCircle.layer addAnimation:transformAngle forKey:nil];
}

- (void)addAnimationToSecondCircle
{
    _secondCircle.layer.opacity = 0.25;
    
    //透明度
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = [NSNumber numberWithFloat:0.0];
    opacity.toValue = [NSNumber numberWithFloat:0.25];
    opacity.duration = voiceCircleScaleDuration;
    opacity.delegate = self;
    opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//
//    opacity.beginTime = CACurrentMediaTime() ;
    
    //上下抖动
    CGPoint beginPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 + _voiceCircleDistanceOffset);
    CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0 + 2 * _voiceCircleDistanceOffset);
    
    CAKeyframeAnimation *positionLine = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionLine.values = @[[NSValue valueWithCGPoint:beginPoint], [NSValue valueWithCGPoint:endPoint], [NSValue valueWithCGPoint:beginPoint]];
    positionLine.duration = voiceCircleCustomDuration;
    positionLine.repeatCount = INFINITY;
    positionLine.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//
//    positionLine.beginTime = CACurrentMediaTime();
    
    //放大缩小
    UIBezierPath *beginPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius * voiceCircleRadiusZoomOutRatio];
    UIBezierPath *midPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius * voiceCircleRadiusZoomInRatio];
    UIBezierPath *endPath = [self generateBezierPathWithCenter:CGPointMake(voiceCircleLayerWidth/2.0, voiceCircleLayerWidth/2.0) radius:_voiceCircleRadius];
    
    CAKeyframeAnimation *scaleAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    scaleAniamtion.values = @[(__bridge id _Nullable)beginPath.CGPath, (__bridge id _Nullable)midPath.CGPath, (__bridge id _Nullable)endPath.CGPath];
    scaleAniamtion.duration = voiceCircleScaleDuration;
    scaleAniamtion.keyTimes = @[@0, @0.375, @1.0];//
//    scaleAniamtion.beginTime = CACurrentMediaTime();
//    scaleAniamtion.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :0.80 :1.00 :1.00];
    
    //转圈
    CAKeyframeAnimation *transformAngle = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    transformAngle.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.5*M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.5*M_PI, 0, 0, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(2*M_PI, 0, 0, 1)]];
    transformAngle.duration = voiceCircleCustomDuration;
    transformAngle.repeatCount = INFINITY;
    transformAngle.calculationMode = kCAAnimationLinear;
//    transformAngle.beginTime = CACurrentMediaTime();
    
    [_secondCircle.layer addAnimation:opacity forKey:nil];
    [_secondCircle.layer addAnimation:positionLine forKey:nil];
    [_secondCircleShapeLayer addAnimation:scaleAniamtion forKey:nil];
    [_secondCircle.layer addAnimation:transformAngle forKey:nil];
}

- (void)addAnimationToSelfLayer
{
    CAKeyframeAnimation *backgroundTransform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    backgroundTransform.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.5*M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1)], [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.5*M_PI, 0, 0, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(2*M_PI, 0, 0, 1)]];
    backgroundTransform.duration = voiceCircleCustomDuration;
    backgroundTransform.repeatCount = INFINITY;
    backgroundTransform.calculationMode = kCAAnimationLinear;
//    backgroundTransform.beginTime = CACurrentMediaTime();
    
    [self.layer addAnimation:backgroundTransform forKey:nil];
}

- (void)addAnimationToWhiteBackground
{
    UIBezierPath *beginPath = [self generateBezierPathWithCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0) radius:_whiteBackgroundLayerRadius * voiceCircleRadiusZoomOutRatio];
    UIBezierPath *midPath = [self generateBezierPathWithCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0) radius:_whiteBackgroundLayerRadius * voiceCircleRadiusZoomInRatio];
    UIBezierPath *endPath = [self generateBezierPathWithCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0) radius:_whiteBackgroundLayerRadius];
    
    CAKeyframeAnimation *scaleAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    scaleAniamtion.values = @[(__bridge id _Nullable)beginPath.CGPath, (__bridge id _Nullable)midPath.CGPath, (__bridge id _Nullable)endPath.CGPath];
    scaleAniamtion.duration = voiceCircleScaleDuration;
    scaleAniamtion.keyTimes = @[@0, @0.375, @1.0];//
//    scaleAniamtion.beginTime = CACurrentMediaTime();
    [_whiteBackgroundLayer addAnimation:scaleAniamtion forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    NSString *identifier = [anim valueForKey:animationType];
//    if ([identifier isEqualToString:@"xxx"]) {
//        
//    }
}

#pragma mark - generate

- (CAShapeLayer *)generateShapeLayerWithLineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *waveline = [CAShapeLayer layer];
    waveline.lineCap = kCALineCapButt;
    waveline.lineJoin = kCALineJoinRound;
    waveline.strokeColor = [UIColor redColor].CGColor;
    waveline.fillColor = [[UIColor clearColor] CGColor];
    waveline.lineWidth = lineWidth;
    waveline.backgroundColor = [UIColor clearColor].CGColor;
    //    waveline.position = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
    //    waveline.bounds = self.bounds;
    
    return waveline;
}

- (UIBezierPath *)generateBezierPathWithCenter:(CGPoint)center radius:(CGFloat)radius
{
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO];
    
    return circlePath;
}

#pragma mark - getters

- (UIImageView *)firstCircle
{
    if (!_firstCircle) {
        self.firstCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circleBackground"]];
        _firstCircle.layer.masksToBounds = YES;
        _firstCircle.alpha = 1.0;
    }
    
    return _firstCircle;
}

- (UIImageView *)secondCircle
{
    if (!_secondCircle) {
        self.secondCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circleBackground"]];
        _secondCircle.layer.masksToBounds = YES;
        _secondCircle.alpha = 0.25;
    }
    
    return _secondCircle;
}

- (CAShapeLayer *)whiteBackgroundLayer
{
    if (!_whiteBackgroundLayer) {
        self.whiteBackgroundLayer = [CAShapeLayer layer];
        _whiteBackgroundLayer.strokeColor = [UIColor whiteColor].CGColor;
        _whiteBackgroundLayer.fillColor = [[UIColor whiteColor] CGColor];
        _whiteBackgroundLayer.lineWidth = 2;
        _whiteBackgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        _whiteBackgroundLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
        _whiteBackgroundLayer.bounds = self.bounds;
    }
    
    return _whiteBackgroundLayer;
}

@end
