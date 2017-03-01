//
//  YSCTableRefreshCurveLayer.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#define Radius  10
#define Space    1
#define LineLength 30
#define CenterY  self.frame.size.height/2

#define Degree M_PI/3

#import "YSCTableRefreshCurveLayer.h"

@interface YSCTableRefreshCurveLayer ()

@property (nonatomic, strong) UIBezierPath *linePath;
@property (nonatomic, strong) UIBezierPath *rotateLintPath;

@end

@implementation YSCTableRefreshCurveLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.strokeColor = [YSCGlobleMethod uiColorFromHexString:@"3c76ff"].CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
    }
    return self;
}

- (void)resetData
{
    self.strokeStart = 0.0;
    self.strokeEnd = 0.0;
}

- (void)setProgress:(CGFloat)progress
{
    self.path = self.linePath.CGPath;
    self.strokeStart = 0.0;
    self.strokeEnd = progress <= 1.0 ? progress : 1.0;
}

- (void)showInRotateLinePath
{
    self.path = self.rotateLintPath.CGPath;
    self.strokeStart = 0.0;
    self.strokeEnd = 1.0;
}

- (UIBezierPath *)linePath
{
    if (!_linePath) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:9 startAngle:0.32*M_PI endAngle:2.18 * M_PI clockwise:YES];
        CGPoint endPoint = CGPointMake(path.currentPoint.x + 4, path.currentPoint.y + 4);
        [path addLineToPoint:endPoint];
        _linePath = path;
    }
    
    return _linePath;
}

- (UIBezierPath *)rotateLintPath
{
    if (!_rotateLintPath) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0) radius:9 startAngle:0.32*M_PI endAngle:2.18 * M_PI clockwise:YES];
        [path addLineToPoint:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)];
        _rotateLintPath = path;
    }
    
    return _rotateLintPath;
}

@end
