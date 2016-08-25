//
//  YSCWaterWaveView.m
//  AnimationLearn
//
//  Created by yushichao on 16/3/2.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCWaterWaveView.h"

@interface YSCWaterWaveView ()

@property (nonatomic, strong) CADisplayLink *waveDisplaylink;

@property (nonatomic, strong) CAShapeLayer  *firstWaveLayer;
@property (nonatomic, strong) CAShapeLayer  *secondWaveLayer;
@end

@implementation YSCWaterWaveView {
    CGFloat waveAmplitude;  // 波纹振幅
    CGFloat waveCycle;      // 波纹周期
    CGFloat waveSpeed;      // 波纹速度
    CGFloat waveGrowth;     // 波纹上升速度
    
    CGFloat waterWaveHeight;
    CGFloat waterWaveWidth;
    CGFloat offsetX;           // 波浪x位移
    CGFloat currentWavePointY; // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    
    float variable;     //可变参数 更加真实 模拟波纹
    BOOL increase;      // 增减变化
    YSCWaterWaveAnimateType _animateType;//展现时先上升，隐藏时先下降
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)removeFromParentView
{
    [self reset];
    [self removeFromSuperview];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds  = YES;
        [self setUp];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds  = YES;
        [self setUp];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
    if (waterWaveWidth > 0) {
        waveCycle =  1.29 * M_PI / waterWaveWidth;
    }
    
    if (currentWavePointY <= 0) {
        currentWavePointY = self.frame.size.height;
    }
}

- (void)setUp
{
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
    _firstWaveColor = [UIColor colorWithRed:223/255.0 green:83/255.0 blue:64/255.0 alpha:1];
    _secondWaveColor = [UIColor colorWithRed:236/255.0f green:90/255.0f blue:66/255.0f alpha:1];
    
    waveGrowth = 0.85;
    waveSpeed = 0.4/M_PI;
    
    [self resetProperty];
}

- (void)resetProperty
{
    currentWavePointY = self.frame.size.height;
    
    variable = 1.6;
    increase = NO;
    
    offsetX = 0;
}

- (void)setFirstWaveColor:(UIColor *)firstWaveColor
{
    _firstWaveColor = firstWaveColor;
    _firstWaveLayer.fillColor = firstWaveColor.CGColor;
}

- (void)setSecondWaveColor:(UIColor *)secondWaveColor
{
    _secondWaveColor = secondWaveColor;
    _secondWaveLayer.fillColor = secondWaveColor.CGColor;
}

- (void)setPercent:(CGFloat)percent
{
    _percent = percent;
    [self resetProperty];
}

-(void)startWave
{
    _animateType = YSCWaterWaveAnimateTypeShow;
    [self resetProperty];
    
    if (_firstWaveLayer == nil) {
        // 创建第一个波浪Layer
        _firstWaveLayer = [CAShapeLayer layer];
        _firstWaveLayer.fillColor = _firstWaveColor.CGColor;
        [self.layer addSublayer:_firstWaveLayer];
    }
    
    if (_secondWaveLayer == nil) {
        // 创建第二个波浪Layer
        _secondWaveLayer = [CAShapeLayer layer];
        _secondWaveLayer.fillColor = _secondWaveColor.CGColor;
        [self.layer addSublayer:_secondWaveLayer];
    }
    
    if (_waveDisplaylink) {
        [self stopWave];
    }
    
    // 启动定时调用
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) stopWave
{
    _animateType = YSCWaterWaveAnimateTypeHide;
    
//    [_waveDisplaylink invalidate];
//    _waveDisplaylink = nil;
}

- (void)reset
{
    [_waveDisplaylink invalidate];
    _waveDisplaylink = nil;
    
    [self resetProperty];
    
    [_firstWaveLayer removeFromSuperlayer];
    _firstWaveLayer = nil;
    [_secondWaveLayer removeFromSuperlayer];
    _secondWaveLayer = nil;
}

-(void)animateWave
{
    if (increase) {
        variable += 0.01;
    }else{
        variable -= 0.01;
    }
    
    if (variable<=1) {
        increase = YES;
    }
    
    if (variable>=1.6) {
        increase = NO;
    }
    
    waveAmplitude = variable*5;
}

-(void)getCurrentWave:(CADisplayLink *)displayLink
{
    [self animateWave];
    
    if (YSCWaterWaveAnimateTypeShow == _animateType && currentWavePointY > 2 * waterWaveHeight *(1-_percent)) {
        // 波浪高度未到指定高度 继续上涨
        currentWavePointY -= waveGrowth;
    } else if (YSCWaterWaveAnimateTypeHide == _animateType && currentWavePointY < 2 * waterWaveHeight) {
        currentWavePointY += waveGrowth;
    } else if (YSCWaterWaveAnimateTypeHide == _animateType && currentWavePointY == 2 * waterWaveHeight) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
        [self removeFromParentView];
    }
     
    // 波浪位移
    offsetX += waveSpeed;
    
    [self setCurrentFirstWaveLayerPath];
    [self setCurrentSecondWaveLayerPath];
}

-(void)setCurrentFirstWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = waveAmplitude * sin(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _firstWaveLayer.path = path;
    CGPathRelease(path);
}

-(void)setCurrentSecondWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 余弦波浪公式
        y = waveAmplitude * cos(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _secondWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)dealloc
{
    [self reset];
}

@end
