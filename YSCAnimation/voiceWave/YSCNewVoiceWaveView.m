//
//  YSCNewVoiceWaveView.m
//  Waver
//
//  Created by yushichao on 16/8/9.
//  Copyright © 2016年 YSC Inc. All rights reserved.
//

#import "YSCNewVoiceWaveView.h"
#import "YSCVolumeQueue.h"

@interface YSCNewVoiceWaveView ()<CAAnimationDelegate>

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) YSCVolumeQueue *volumeQueue;

@property (nonatomic, strong) UIImageView *selfViewMaskImage;

@property (nonatomic, assign) NSInteger waveNumber;
@end

const static CGFloat voiceWaveDisappearDuration = 0.25;
const static NSInteger defaultWaveNumber = 5;

static NSRunLoop *_voiceWaveRunLoop;

@implementation YSCNewVoiceWaveView {
    CGFloat _idleAmplitude;//最小振幅
    CGFloat _amplitude;//归一化振幅系数，与音量正相关
    CGFloat _density;//x轴粒度
    
    CGFloat _waveHeight;
    CGFloat _waveWidth;
    CGFloat _waveMid;
    CGFloat _maxAmplitude;//最大振幅
    CGFloat _mainWaveWidth;//主波纹线宽，其他波纹是它的一半，也可自定义
    
    CGFloat _phase1;//firstLine相位
    CGFloat _phase2;//secondLine相位
    CGFloat _phaseShift1;
    CGFloat _phaseShift2;
    CGFloat _frequency1;
    CGFloat _frequency2;
    CGPoint _lineCenter1;
    CGPoint _lineCenter2;
    
    CGFloat _currentVolume;
    CGFloat _lastVolume;
    CGFloat _middleVolume;
    
    CGFloat _maxWidth;//波纹显示最大宽度
    CGFloat _beginX;//波纹开始坐标
    
    CGFloat _stopAnimationRatio;//松手后避免音量过大，波纹振幅大，乘以衰减系数
    
    BOOL _isStopAnimating;//正在进行消失动画

    NSMutableArray<UIBezierPath *> *_waveLinePathArray;
    NSLock *_lock;
}

- (void)dealloc
{
    [_displayLink invalidate];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self startVoiceWaveThread];
    }
    return self;
}

- (void)setup
{    
    _frequency1 = 2.0f;
    _frequency2 = 1.6f;
    
    _amplitude = 1.0f;
    _idleAmplitude = 0.05f;
    
    _phase1 = 0.0f;
    _phase2 = 0.0f;
    _phaseShift1 = -0.22f;
    _phaseShift2 = -0.2194f;
    _density = 1.f;
    
    _waveHeight = CGRectGetHeight(self.bounds);
    _waveWidth  = CGRectGetWidth(self.bounds);
    _waveMid    = _waveWidth / 2.0f;
    _maxAmplitude = _waveHeight * 0.5;
    
    NSInteger centerX = _waveWidth / 2;
    _lineCenter1 = CGPointMake(centerX, 0);
    _lineCenter2 = CGPointMake(centerX, 0);
    
    _maxWidth = _waveWidth + _density;
    _beginX = 0.0;
    
    _lastVolume = 0.0;
    _currentVolume = 0.0;
    _middleVolume = 0.05;
    _stopAnimationRatio = 1.0;
    
    [_volumeQueue cleanQueue];
    _mainWaveWidth = 2;
    _waveNumber = _waveNumber > 0 ? _waveNumber : defaultWaveNumber;
    _waveLinePathArray = [NSMutableArray array];
    _lock = [[NSLock alloc] init];
}

- (void)voiceWaveThreadEntryPoint:(id)__unused object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.ysc.VoiceWave"];
        _voiceWaveRunLoop = [NSRunLoop currentRunLoop];
        [_voiceWaveRunLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [_voiceWaveRunLoop run];
    }
}

- (NSThread *)startVoiceWaveThread
{
    static NSThread *_voiceWaveThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _voiceWaveThread =
        [[NSThread alloc] initWithTarget:self
                                selector:@selector(voiceWaveThreadEntryPoint:)
                                  object:nil];
        [_voiceWaveThread start];
    });
    
    return _voiceWaveThread;
}

- (void)showInParentView:(UIView *)parentView
{
    if (![self.superview isKindOfClass:[parentView class]] || !_isStopAnimating) {
        [parentView addSubview:self];
    } else {
        [self.layer removeAllAnimations];
        return;
    }
    
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, parentView.bounds.size.height * 0.25, parentView.bounds.size.width, parentView.bounds.size.height * 0.5);
    [self setup];
    
    [self updateMeters];
}

- (void)setVoiceWaveNumber:(NSInteger)waveNumber
{
    _waveNumber = waveNumber;
}

- (void)startVoiceWave
{
    if (_isStopAnimating) {
        return;
    }
    [self setup];
    if (_voiceWaveRunLoop) {
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
        [self.displayLink addToRunLoop:_voiceWaveRunLoop forMode:NSRunLoopCommonModes];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_voiceWaveRunLoop) {
                [self.displayLink invalidate];
                self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
                [self.displayLink addToRunLoop:_voiceWaveRunLoop forMode:NSRunLoopCommonModes];
            }
        });
    }
}

- (void)stopVoiceWaveWithShowLoadingViewCallback:(YSCShowLoadingCircleCallback)showLoadingCircleCallback
{
    if (_isStopAnimating) {
        return;
    }
    [self.layer removeAllAnimations];
    _isStopAnimating = YES;
    self.layer.mask = self.selfViewMaskImage.layer;
    [self addVoiceWaveDisappearAnimation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(voiceWaveDisappearDuration * 0.5  * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLoadingCircleCallback();
    });
}

- (void)addVoiceWaveDisappearAnimation
{
    _selfViewMaskImage.layer.transform = CATransform3DMakeScale(0.0, 1.0, 1.0);
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.0, 1.0)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 1.0, 1.0)];
    transformAnimation.duration = voiceWaveDisappearDuration;
    transformAnimation.delegate = self;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.80 :0.20 :1.00 :1.00];

    [_selfViewMaskImage.layer addAnimation:transformAnimation forKey:@"transform"];
}

- (void)changeVolume:(CGFloat)volume
{
    @synchronized (self) {
        _lastVolume = _currentVolume;
        _currentVolume = volume;
        
        NSArray *volumeArray = [self generatePointsOfSize:6 withPowFactor:1 fromStartY:_lastVolume toEndY:_currentVolume];
        [self.volumeQueue pushVolumeWithArray:volumeArray];
    }
}

- (void)removeFromParent
{
    [_displayLink invalidate];
    [_selfViewMaskImage.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (CGPoint)getVoiceLoadingCircleCenter
{
    CGPoint centerPoint = _lineCenter1.y > _lineCenter2.y ? _lineCenter1 : _lineCenter2;
    CGPoint centerPointInParent = [self convertPoint:centerPoint toView:self.superview];
    return centerPointInParent;
}

- (void)invokeWaveCallback
{
    [self updateMeters];
}

- (void)updateMeters
{
    CGFloat volume = [self.volumeQueue popVolume];
    if (volume > 0) {
        _middleVolume = volume;
    }
    _phase1 += _phaseShift1; // Move the wave
    _phase2 += _phaseShift2;
    _amplitude = fmax(_middleVolume, _idleAmplitude);
    if (_isStopAnimating) {
        _stopAnimationRatio = _stopAnimationRatio - 0.05;
        _stopAnimationRatio = fmax(_stopAnimationRatio, 0.01);
    }
    
    [_lock lock];
    [_waveLinePathArray removeAllObjects];
    CGFloat waveWidth = _mainWaveWidth;
    CGFloat progress = 1.0f;
    CGFloat amplitudeFactor = 1.0f;
    for (NSInteger i = 0; i < _waveNumber; i++) {
        waveWidth = i==0 ? _mainWaveWidth : _mainWaveWidth / 2.0;
        progress = 1.0f - (CGFloat)i / _waveNumber;
        amplitudeFactor = 1.5f * progress - 0.5f;
        UIBezierPath *linePath = [self generateGradientPathWithFrequency:_frequency1 maxAmplitude:_maxAmplitude * amplitudeFactor phase:_phase1 lineCenter:&_lineCenter1 yOffset:waveWidth / 2.0];
        [_waveLinePathArray addObject:linePath];
    }
    [_lock unlock];
    [self performSelectorOnMainThread:@selector(updateShapeLayerPath:) withObject:nil waitUntilDone:NO];
}

- (void)updateShapeLayerPath:(NSDictionary *)dic
{
    [self setNeedsDisplay];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.displayLink invalidate];
    [self removeFromSuperview];
    
    _phase1 = 0;
    _phase2 = 0;
    _amplitude = 1.0f;
    
    _maxWidth = _waveWidth + _density;
    _beginX = 0.0;
    _isStopAnimating = NO;
    _stopAnimationRatio = 1.0;
    
    self.layer.mask = nil;
    _lastVolume = 0.0;
    _currentVolume = 0.0;
    _middleVolume = 0.05;
    [_volumeQueue cleanQueue];
    
    _selfViewMaskImage = nil;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    static NSInteger offset = 0;
    CGFloat colorOffset = sin(M_PI * fmod(offset++, 255.0) / 255.0);
    UIColor *startColor = [UIColor colorWithRed:colorOffset green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    UIColor *endColor = [UIColor colorWithRed:0.0/255.0 green:1 - colorOffset blue:0.0/255.0 alpha:1.0];
    //绘制渐变
    [_lock lock];
    CGFloat progress = 1.0f;
    if (_waveLinePathArray.count == _waveNumber && _waveNumber > 0) {
        for (NSInteger i = 0; i < _waveNumber; i++) {
            progress = 1.0f - (CGFloat)i / _waveNumber;
            CGFloat multiplier = MIN(1.0, (progress / 3.0f * 2.0f) + (1.0f / 3.0f));
            CGFloat colorFactor = i == 0 ? 1.0 : 1.0 * multiplier * 0.4;
            startColor = [UIColor colorWithRed:colorOffset green:0.0/255.0 blue:0.0/255.0 alpha:colorFactor];
            endColor = [UIColor colorWithRed:0.0/255.0 green:1 - colorOffset blue:0.0/255.0 alpha:colorFactor];
            [self drawLinearGradient:context path:_waveLinePathArray[i].CGPath startColor:startColor.CGColor endColor:endColor.CGColor];
        }
    }
    [_lock unlock];
}

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawRadialGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));
    CGFloat radius = MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextEOClip(context);
    
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
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

- (UIBezierPath *)generateBezierPathWithFrequency:(CGFloat)frequency maxAmplitude:(CGFloat)maxAmplitude phase:(CGFloat)phase lineCenter:(CGPoint *)lineCenter
{
    UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
    
    // (-(2x-1)^2+1)sin (2pi*f*x)
    // (-(2x-1)^2+1)sin (2pi*f*x + 3.0)
    
    CGFloat normedAmplitude = fmin(_amplitude, 1.0);
    if (_maxWidth < _density || _waveMid <= 0) {
        return nil;
    }
    for(CGFloat x = _beginX; x<_maxWidth; x += _density) {
        CGFloat scaling = -pow(x / _waveMid  - 1, 2) + 1; // make center bigger
        
        CGFloat y = scaling * maxAmplitude * normedAmplitude * _stopAnimationRatio * sinf(2 * M_PI *(x / _waveWidth) * frequency + phase) + (_waveHeight * 0.5);
        
        if (_beginX == x) {
            [wavelinePath moveToPoint:CGPointMake(x, y)];
        }
        else {
            [wavelinePath addLineToPoint:CGPointMake(x, y)];
        }
        if (fabs(lineCenter->x - x) < 0.01) {
            lineCenter->y = y;
        }
    }
    
    return wavelinePath;
}

- (UIBezierPath *)generateGradientPathWithFrequency:(CGFloat)frequency maxAmplitude:(CGFloat)maxAmplitude phase:(CGFloat)phase lineCenter:(CGPoint *)lineCenter yOffset:(CGFloat)yOffset
{
    UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
    
    // (-(2x-1)^2+1)sin (2pi*f*x)
    // (-(2x-1)^2+1)sin (2pi*f*x + 3.0)
    
    CGFloat normedAmplitude = fmin(_amplitude, 1.0);
    if (_maxWidth < _density || _waveMid <= 0) {
        return nil;
    }
    CGFloat x = _beginX;
    CGFloat y = 0;
    for(; x<_maxWidth; x += _density) {
        CGFloat scaling = -pow(x / _waveMid  - 1, 2) + 1; // make center bigger
        
        y = scaling * maxAmplitude * normedAmplitude * _stopAnimationRatio * sinf(2 * M_PI *(x / _waveWidth) * frequency + phase) + (_waveHeight * 0.5 - yOffset);
        
        if (_beginX == x) {
            [wavelinePath moveToPoint:CGPointMake(x, y)];
        }
        else {
            [wavelinePath addLineToPoint:CGPointMake(x, y)];
        }
        if (fabs(lineCenter->x - x) < 0.01) {
            lineCenter->y = y;
        }
    }
    x = x - _density;
    [wavelinePath addLineToPoint:CGPointMake(x, y + 2 * yOffset)];
    
    for(; x>=_beginX; x -= _density) {
        CGFloat scaling = -pow(x / _waveMid  - 1, 2) + 1; // make center bigger
        
        y = scaling * maxAmplitude * normedAmplitude * _stopAnimationRatio * sinf(2 * M_PI *(x / _waveWidth) * frequency + phase) + (_waveHeight * 0.5 + yOffset);
        
        [wavelinePath addLineToPoint:CGPointMake(x, y)];
    }
    x = x + _density;
    [wavelinePath addLineToPoint:CGPointMake(x, y - 2 * yOffset)];
    
    return wavelinePath;
}

/**
 *  音量插值
 *
 *  @param size   插值返回音量个数(包含起始点、不包含末尾节点)
 *  @param factor 插值系数，(0~1 : 变化率从大到小  1~2 : 变化率从小到大)
 参考
 http://zh.numberempire.com/graphingcalculator.php
 pow(x,0.2),pow(x,0.3),pow(x,0.4),pow(x,0.5),pow(x,0.6),pow(x,0.7),pow(x,0.8),pow(x,0.9)
 *  @param y1     起始插值音量，取值范围0~1
 *  @param y2     终止插值音量，取值范围0~1
 *
 *  @return 插值后音量数组
 */
- (NSArray *)generatePointsOfSize:(NSInteger)size
                    withPowFactor:(CGFloat)factor
                       fromStartY:(CGFloat)y1
                           toEndY:(CGFloat)y2
{
    BOOL factorValid = factor < 2 && factor > 0 && factor != 0;
    BOOL y1Valid = 0 <= y1 && y1 <= 1;
    BOOL y2Valid = 0 <= y2 && y2 <= 1;
    if (!(factorValid && y1Valid && y2Valid)) {
        return nil;
    }
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:size];
    
    CGFloat x1,x2;
    x1 = pow(y1,1/factor);
    x2 = pow(y2,1/factor);
    
    CGFloat pieceOfX = (x2 - x1) / size;
    CGFloat x,y;
    
    [mArray addObject:[NSNumber numberWithFloat:y1]];
    
    for (int i = 1; i < size; ++i) {
        x = x1 + pieceOfX * i;
        y = pow(x, factor);
        
        [mArray addObject:[NSNumber numberWithFloat:y]];
    }
    
    return [mArray copy];
}

#pragma mark - getters

- (UIImageView *)selfViewMaskImage
{
    if (!_selfViewMaskImage) {
        self.selfViewMaskImage = [[UIImageView alloc] init];
        _selfViewMaskImage.image = [UIImage imageNamed:@"maskImage"];
        _selfViewMaskImage.frame = self.bounds;
    }
    
    return _selfViewMaskImage;
}

- (YSCVolumeQueue *)volumeQueue
{
    if (!_volumeQueue) {
        self.volumeQueue = [[YSCVolumeQueue alloc] init];
    }
    
    return _volumeQueue;
}

@end
