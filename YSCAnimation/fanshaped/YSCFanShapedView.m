//
//  YSCFanShapedView.m
//  AnimationLearn
//
//  Created by yushichao on 16/2/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCFanShapedView.h"

@interface YSCFanShapedView ()

@property (nonatomic, strong) CALayer *fanShapeLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *buttonMaskLayer;

@end

@implementation YSCFanShapedView

- (void)removeFromParentView
{
    if (self.superview) {
        [self removeAllSubLayers];
        [self removeFromSuperview];
        [self.layer removeAllAnimations];
    }
}

- (void)removeAllSubLayers
{
    for (NSInteger i = 0; [self.layer sublayers].count > 0; i++) {
        [[[self.layer sublayers] firstObject] removeFromSuperlayer];
    }
}

- (void)showInParentView:(UIView *)parentView WithType:(YSCFanShapedShowType)type
{
    if (![self.superview isKindOfClass:[parentView class]]) {
        [parentView addSubview:self];
    } else {
        return;
    }
    
    _fanShapeLayer = [CALayer layer];
    _fanShapeLayer.position = CGPointMake(150, 75);
    _fanShapeLayer.bounds = CGRectMake(0, 0, 300, 150);
    _fanShapeLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fanshaped.jpg"].CGImage);
    [self.layer addSublayer:_fanShapeLayer];
    
    //addMask
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.position = CGPointMake(150, 150);
    _maskLayer.bounds = CGRectMake(0, 0, 300, 150);
    _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    _maskLayer.fillColor = [UIColor greenColor].CGColor;
    _maskLayer.strokeColor = [UIColor redColor].CGColor;
    _maskLayer.lineWidth = 2;
    _maskLayer.anchorPoint = CGPointMake(0.5, 1.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(150, 150) radius:160 startAngle:M_PI endAngle:2 * M_PI clockwise:YES];
    [path closePath];
    _maskLayer.path = path.CGPath;
    
    _fanShapeLayer.mask = _maskLayer;
    
    [self setShowType:type];
}

- (void)setShowType:(YSCFanShapedShowType)type
{
    CATransform3D beginTransform = CATransform3DIdentity;
    CATransform3D endTransform = CATransform3DIdentity;
    if (YSCFanShapedShowTypeExpand == type) {//打开扇形
        beginTransform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        endTransform = CATransform3DMakeRotation(0, 0, 0, 1);
    } else if (YSCFanShapedShowTypeShrink == type) {//关闭扇形
        beginTransform = CATransform3DMakeRotation(0, 0, 0, 1);
        endTransform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    }
 
    _maskLayer.transform = endTransform;
    
    CABasicAnimation *aniamtion = [CABasicAnimation animationWithKeyPath:@"transform"];
    aniamtion.fromValue = [NSValue valueWithCATransform3D:beginTransform];
    aniamtion.toValue = [NSValue valueWithCATransform3D:endTransform];
    aniamtion.duration = 3.0;
    
    [_maskLayer addAnimation:aniamtion forKey:@"fanShape"];
}

@end
