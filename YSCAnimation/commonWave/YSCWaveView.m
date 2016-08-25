//
//  YSCWaveView.m
//  AnimationLearn
//
//  Created by yushichao on 16/2/19.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCWaveView.h"

@interface WaveObject : NSObject

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAAnimation *waveAnimation;
@property (nonatomic, assign) CGFloat height;

@end

@implementation WaveObject

@end

@interface YSCWaveView ()

@property (nonatomic, strong) NSTimer *waveTimer;
@property (nonatomic, strong) NSMutableArray *waveObjects;
@property (nonatomic, strong) NSTimer *soundTimer;
@property (nonatomic, strong) NSMutableArray *soundWaveObjects;
@property (nonatomic, assign) YSCWaveType type;
@end

static CGFloat straightLineLength = 5;
static CGFloat timeUnit = 0.3;

@implementation YSCWaveView {
    CGFloat _waveWidth;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _waveObjects = [NSMutableArray array];
        _soundWaveObjects = [NSMutableArray array];
        _waveWidth = 55.0;
    }
    
    return self;
}

- (void)removeFromParentView
{
    if (self.superview) {
        [self removeAllSubLayers];
        [self removeFromSuperview];
        [self closeWaveTimer];
        [self closeWaveTimer];
        [self closeSoundTimer];
        [_waveObjects removeAllObjects];
        [_soundWaveObjects removeAllObjects];
        [self.layer removeAllAnimations];
    }
}

- (void)removeAllSubLayers
{
    for (NSInteger i = 0; [self.layer sublayers].count > 0; i++) {
        [[[self.layer sublayers] firstObject] removeFromSuperlayer];
    }
}

- (void)setWaveWidth:(CGFloat)width
{
    _waveWidth = width;
}

- (void)closeWaveTimer
{
    if (_waveTimer) {
        if ([_waveTimer isValid]) {
            [_waveTimer invalidate];
        }
        _waveTimer = nil;
    }
}

- (void)showWaveViewWithType:(YSCWaveType)type
{
    _type = type;
    if (YSCWaveTypePulse == type) {
        straightLineLength = 20;
        timeUnit = 2.0;
        [self closeWaveTimer];
        _waveTimer = [NSTimer timerWithTimeInterval:timeUnit target:self selector:@selector(addWaveLayer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_waveTimer forMode:NSRunLoopCommonModes];
    } else if (YSCWaveTypeMovedVoice == type) {
        straightLineLength = 0;
        timeUnit = 2.0;
        [self closeWaveTimer];
        _waveTimer = [NSTimer timerWithTimeInterval:timeUnit target:self selector:@selector(addWaveLayer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_waveTimer forMode:NSRunLoopCommonModes];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * timeUnit * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setSoundTimerWithTime:0.5];//添加声波幅度改变动画
        });
    } else if (YSCWaveTypeVoice == type) {
        straightLineLength = 0;
        for (NSInteger i = 0; i < 6; i++) {
            WaveObject *aWaveObject = [self gernerateWaveObject];
            aWaveObject.shapeLayer.position = CGPointMake(_waveWidth/2.0 + i * _waveWidth, self.bounds.size.height / 2);
            [self.layer addSublayer:aWaveObject.shapeLayer];
            [_soundWaveObjects addObject:aWaveObject];
        }
        [self setSoundTimerWithTime:0.5];
    }
}

- (void)addWaveLayer:(NSTimer *)timer
{
    WaveObject *aWaveObject = [self gernerateWaveObject];
    aWaveObject.shapeLayer.position = CGPointMake(-_waveWidth/2.0, self.bounds.size.height / 2);
    [self.layer addSublayer:aWaveObject.shapeLayer];
    
    CGFloat height = arc4random() % (NSInteger)(self.bounds.size.height / 2);
    
    [_waveObjects addObject:aWaveObject];
    
    [self addAnimationToLayer:aWaveObject WithHeight:height];
}

- (void)addAnimationToLayer:(WaveObject *)waveObject WithHeight:(CGFloat)height
{
    CAShapeLayer *waveLayer = waveObject.shapeLayer;
    
    CAKeyframeAnimation *pathAnimation = [self pathAnimationWithHeight:height];
    CABasicAnimation *positionAnimation = [self positionAnimation];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    if (YSCWaveTypePulse == _type) {
        group.animations = @[pathAnimation, positionAnimation];
    } else if (YSCWaveTypeMovedVoice == _type) {
        group.animations = @[positionAnimation];
    }
    
    group.duration = 10 * timeUnit;
    
    [waveLayer addAnimation:group forKey:@""];
    
    [self performSelector:@selector(removeWaveLayer:) withObject:waveObject afterDelay:10 * timeUnit];
}

- (void)removeWaveLayer:(WaveObject *)waveObject
{
    [waveObject.shapeLayer removeFromSuperlayer];
    [_waveObjects removeObject:waveObject];
    waveObject = nil;
}

- (void)addAnimationToSoundeWaveLayer:(NSTimer *)timer
{
    NSMutableArray *temWaveObjects = [NSMutableArray array];
    @synchronized(_waveObjects) {
        if (YSCWaveTypeMovedVoice == _type) {
            temWaveObjects = _waveObjects;
        } else if (YSCWaveTypeVoice == _type) {
            temWaveObjects = _soundWaveObjects;
        }
    }

    NSInteger count = temWaveObjects.count;
    if (0 == count) {
        return;
    }
    
    for (NSInteger i = 0; i < count; i++) {
        WaveObject *soundWaveObject = temWaveObjects[i];
        CAShapeLayer *soundeWaveLayer = soundWaveObject.shapeLayer;
        CGFloat newHeight = arc4random() % (NSInteger)(self.bounds.size.height / 2);
        CGFloat oldHeight = soundWaveObject.height;
        
        UIBezierPath *beginPath = [UIBezierPath bezierPath];
        [beginPath moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [beginPath addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
        [beginPath addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - oldHeight) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + oldHeight)];
        [beginPath addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
        
        UIBezierPath *middlePath1 = [UIBezierPath bezierPath];
        [middlePath1 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [middlePath1 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
        [middlePath1 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - (oldHeight + (newHeight - oldHeight) / 10)) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + (oldHeight + (newHeight - oldHeight) / 10))];
        [middlePath1 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
        
        UIBezierPath *middlePath2 = [UIBezierPath bezierPath];
        [middlePath2 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [middlePath2 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
        [middlePath2 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - (oldHeight + (newHeight - oldHeight) / 4)) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + (oldHeight + (newHeight - oldHeight) / 4))];
        [middlePath2 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
        
        UIBezierPath *middlePath3 = [UIBezierPath bezierPath];
        [middlePath3 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [middlePath3 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
        [middlePath3 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - (oldHeight + (newHeight - oldHeight) / 2)) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + (oldHeight + (newHeight - oldHeight) / 2))];
        [middlePath3 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
        
        UIBezierPath *endPath = [UIBezierPath bezierPath];
        [endPath moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
        [endPath addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
        [endPath addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - newHeight) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + newHeight)];
        [endPath addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
        
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        pathAnimation.values = @[(__bridge id _Nullable)(beginPath.CGPath), (__bridge id _Nullable)(middlePath1.CGPath), (__bridge id _Nullable)(middlePath2.CGPath), (__bridge id _Nullable)(middlePath3.CGPath),  (__bridge id _Nullable)(endPath.CGPath)];
        pathAnimation.duration = 0.5;
        pathAnimation.calculationMode = kCAAnimationCubic;
        
        soundeWaveLayer.path = endPath.CGPath;
        soundWaveObject.height = newHeight;
        
        [soundeWaveLayer addAnimation:pathAnimation forKey:@""];
    }
}

- (void)setSoundTimerWithTime:(CGFloat)time
{
    [self closeSoundTimer];
    _soundTimer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(addAnimationToSoundeWaveLayer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_soundTimer forMode:NSRunLoopCommonModes];
}

- (void)closeSoundTimer
{
    if (_soundTimer) {
        if ([_soundTimer isValid]) {
            [_soundTimer invalidate];
        }
        _soundTimer = nil;
    }
}

#pragma mark - generater

- (WaveObject *)gernerateWaveObject
{
    CAShapeLayer *waveLayer = [CAShapeLayer layer];
    waveLayer.bounds = CGRectMake(0, 0, _waveWidth, self.bounds.size.height);
    waveLayer.backgroundColor = [UIColor clearColor].CGColor;
    waveLayer.strokeColor = [UIColor blackColor].CGColor;
    waveLayer.lineWidth = 1.0;
    waveLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [path addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [path addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2)];
    [path addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    waveLayer.path = path.CGPath;
    
    WaveObject *waveObject = [[WaveObject alloc] init];
    waveObject.shapeLayer = waveLayer;
    waveObject.height = 0.0;
    
    return waveObject;
}

- (CAKeyframeAnimation *)pathAnimationWithHeight:(CGFloat)height
{
    UIBezierPath *beginPath = [UIBezierPath bezierPath];
    [beginPath moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [beginPath addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [beginPath addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2)];
    [beginPath addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    
    UIBezierPath *middlePath1 = [UIBezierPath bezierPath];
    [middlePath1 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [middlePath1 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [middlePath1 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - height / 10) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + height / 10)];
    [middlePath1 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    
    UIBezierPath *middlePath2 = [UIBezierPath bezierPath];
    [middlePath2 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [middlePath2 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [middlePath2 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - height / 4) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + height / 4)];
    [middlePath2 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    
    UIBezierPath *middlePath3 = [UIBezierPath bezierPath];
    [middlePath3 moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [middlePath3 addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [middlePath3 addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - height / 2) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + height / 2)];
    [middlePath3 addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    
    UIBezierPath *endPath = [UIBezierPath bezierPath];
    [endPath moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [endPath addLineToPoint:CGPointMake(straightLineLength, self.bounds.size.height / 2)];
    [endPath addCurveToPoint:CGPointMake(_waveWidth - straightLineLength, self.bounds.size.height / 2) controlPoint1:CGPointMake(straightLineLength + (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 - height) controlPoint2:CGPointMake(straightLineLength + 3 * (_waveWidth - 2 * straightLineLength) / 4, self.bounds.size.height / 2 + height)];
    [endPath addLineToPoint:CGPointMake(_waveWidth, self.bounds.size.height / 2)];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    pathAnimation.values = @[(__bridge id _Nullable)(beginPath.CGPath), (__bridge id _Nullable)(middlePath1.CGPath), (__bridge id _Nullable)(middlePath2.CGPath), (__bridge id _Nullable)(middlePath3.CGPath), (__bridge id _Nullable)(endPath.CGPath)];
    pathAnimation.duration = 0.2;
    pathAnimation.beginTime = timeUnit;
    //pathAnimation.calculationMode = kCAAnimationCubic;
    pathAnimation.fillMode = kCAFillModeBoth;
    pathAnimation.removedOnCompletion = NO;

    return pathAnimation;
}

- (CABasicAnimation *)positionAnimation
{
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(-_waveWidth/2.0, self.bounds.size.height / 2)];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_waveWidth * 10 - _waveWidth/2.0, self.bounds.size.height / 2)];
    positionAnimation.duration = 10 * timeUnit;
    positionAnimation.beginTime = 0.0;
    positionAnimation.fillMode = kCAFillModeBoth;
    positionAnimation.removedOnCompletion = NO;
    
    return positionAnimation;
}

@end
