//
//  YSCHeartBeatPulseView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2016/11/8.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCHeartBeatPulseView.h"

@interface YSCHeartBeatPulseView ()

@property (nonatomic, strong) CAShapeLayer *pulseShapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation YSCHeartBeatPulseView {
    CGFloat _density;//x轴绘制粒度，也可用其控制速度
    CGFloat _halfWaveLength;//半波长
    CGFloat _waveHeight;
    CGFloat _beginX;
    NSInteger _currentTimeCount;//当前时间计数
    NSInteger _maxTimeCount;//最大时间计数，超过后wave开始移动
    CGFloat _currentWaveWidth;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self setupSubviews];
    }
    return self;
}

- (void)initData
{
    _density = 1.0;
    _halfWaveLength = 40;
    _waveHeight = self.frame.size.height;
    _beginX = 0.0;
    _currentTimeCount = 0;
    _maxTimeCount = (self.frame.size.width - 50) / _density;
    _currentWaveWidth = 0.0;
}

- (void)setupSubviews
{
    [self.layer addSublayer:self.pulseShapeLayer];
}

- (void)startHeartBeat
{
    self.displayLink.paused = NO;
}

- (void)pauseHeartBeat
{
    self.displayLink.paused = YES;
}

- (void)stopHeartBeat
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)setHeartBeatSpeed:(NSInteger)speed
{
    _density = _density * speed;
    _maxTimeCount = (self.frame.size.width - 50) / _density;
}

- (void)invokeDisplayLinkCallback
{
    _currentTimeCount++;
    self.pulseShapeLayer.path = [self generateBezierPathWithTimeCount:_currentTimeCount].CGPath;
    
    //移动wave
    if (_currentTimeCount > _maxTimeCount) {
        self.bounds = CGRectMake(_density * (_currentTimeCount - _maxTimeCount), 0, self.frame.size.width, self.frame.size.height);
    }
}

#pragma mark - getters

- (UIBezierPath *)generateBezierPathWithTimeCount:(NSInteger)timeCount
{
    if (timeCount <= 0) {
        return nil;
    }
    UIBezierPath *pulselinePath = [UIBezierPath bezierPath];

    // sin (2pi * x)

    CGFloat amplitude = 0.0;
    CGFloat x = _beginX;
    for(NSInteger i = 0; i < timeCount; i++) {
        x += _density;
        amplitude = [self getAmplitude:x];
        CGFloat y = amplitude * sinf(2 * M_PI * (0.5 * x / _halfWaveLength)) + (_waveHeight * 0.5);
        y = _waveHeight - y;
        if (0 == i) {
            [pulselinePath moveToPoint:CGPointMake(x, y)];
        }
        else {
            [pulselinePath addLineToPoint:CGPointMake(x, y)];
        }
    }
    
    return pulselinePath;
}

// 获取正弦波振幅，第一个半波振幅最大，第二个比较小，其余的很小，每6个半波数循环一次
- (CGFloat)getAmplitude:(CGFloat)x
{
    CGFloat amplitude = 0.0;
    NSInteger XOffset = (x - _beginX) / _halfWaveLength;
    XOffset = XOffset % 6;
    if (0 == XOffset) {
        amplitude = arc4random() % 50 + _waveHeight * 0.5 - 50;
    } else if (1 == XOffset) {
        amplitude = arc4random() % 10 + 10;
    } else {
        amplitude = arc4random() % 5;
    }
    
    return amplitude;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeDisplayLinkCallback)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    
    return _displayLink;
}

- (CAShapeLayer *)pulseShapeLayer
{
    if (!_pulseShapeLayer) {
        self.pulseShapeLayer = [CAShapeLayer layer];
        _pulseShapeLayer.lineCap = kCALineCapButt;
        _pulseShapeLayer.lineJoin = kCALineJoinRound;
        _pulseShapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _pulseShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _pulseShapeLayer.fillRule = @"even-odd";
        _pulseShapeLayer.lineWidth = 2;
        _pulseShapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        _pulseShapeLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
        _pulseShapeLayer.bounds = self.bounds;
    }
    
    return _pulseShapeLayer;
}

@end
