//
//  YSCGifLoadImageView.m
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/10/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCGifLoadImageView.h"

@interface YSCGifLoadImageView ()
{
    int tmp;
}
@property (nonatomic)        NSUInteger      currentFrameIndex;
@property (nonatomic,strong) YSCGifLoadImage *animatedImage;
@property (nonatomic,strong) CADisplayLink   *displayLink;
@property (nonatomic)        NSTimeInterval  accumulator;
@property (nonatomic,strong) UIImage         *currentFrame;

@property (nonatomic,copy)   NSString        *runLoopMode;
@property (nonatomic,assign) NSInteger       gifRepeatCount;
@property (nonatomic,assign) CGFloat         gifRepeatDelayOffset;
@property (nonatomic,copy)   GifAnimatingCompleteCallBack completeCallBack;
@end

@implementation YSCGifLoadImageView {
    int _delayOffsetCount;//每次播放间隔时间所对应的displayLink计数(1/60秒一次计数)
    BOOL _showCompleteOnce;//完整播放一次gif
}

const NSTimeInterval kMaxTimeStep = 1;
@synthesize runLoopMode = _runLoopMode;
@synthesize displayLink = _displayLink;

-(instancetype)init
{
    if (self = [super init]) {
        self.currentFrameIndex = 0;
        self.accumulator = 0;
        self.gifRepeatCount = 1;
        self.gifRepeatDelayOffset = 0.0;
        _showCompleteOnce = NO;
        _gifRepeatCount = 0;
    }
    return self;
}

//停止动画
- (void)stopGifAnimation
{
    [self stopAnimating];
    [self removeFromSuperview];
    [_displayLink invalidate];
    _displayLink = nil;
}

-(void)stopAnimating
{
    //如果不是gif就返回父类方法
    if (!self.animatedImage) {
        [super stopAnimating];
        return;
    }
    self.displayLink.paused = YES;
}

//开始动画
- (void)startGifAnimatingWithGifRepeatCount:(NSInteger)gifRepeatCount gifRepeatDelayOffset:(CGFloat)gifRepeatDelayOffset animatingCompleteCallBack:(GifAnimatingCompleteCallBack)completeCallBack
{
    self.gifRepeatCount = gifRepeatCount;
    self.gifRepeatDelayOffset = gifRepeatDelayOffset;
    _completeCallBack = completeCallBack;
    [self startAnimating];
}

-(void)startAnimating
{
    if (!self.animatedImage) {
        [super startAnimating];
        return;
    }
    if (self.isAnimating) {
        return;
    }
    
    _showCompleteOnce = NO;
    self.currentFrameIndex = 0;
    self.accumulator = 0;
    self.displayLink.paused = NO;
}

//切换动画的关键方法
-(void)changeKeyframe:(CADisplayLink *)displayLink
{
    if (self.currentFrameIndex > self.animatedImage.images.count) {
        return;
    } else if (_showCompleteOnce) {//每次播放间隔delay
        if (_delayOffsetCount > 0) {
            _delayOffsetCount--;
            return;
        } else if (0 == _delayOffsetCount) {
            self.currentFrameIndex = 0;
            _delayOffsetCount = self.gifRepeatDelayOffset * 60;
            _showCompleteOnce = NO;
        }
    }
    //这里就是不停的取图，不停的设置，然后不停的调用displayLayer:方法
    self.accumulator += fmin(displayLink.duration, kMaxTimeStep);
    while (self.accumulator >= self.animatedImage.frameDurations[self.currentFrameIndex]) {
        self.accumulator -= self.animatedImage.frameDurations[self.currentFrameIndex];
        if (++self.currentFrameIndex >= self.animatedImage.images.count) {
            if (--self.gifRepeatCount == 0) {
                [self stopAnimating];
                if (_completeCallBack) {
                    _completeCallBack();
                }
                return;
            }
            _showCompleteOnce = YES;
        }
        self.currentFrameIndex = MIN(self.currentFrameIndex, self.animatedImage.images.count - 1);
        self.currentFrame = [self.animatedImage getFrameWithIndex:self.currentFrameIndex];
        [self.layer setNeedsDisplay];
    }
}

//绘制图片
-(void)displayLayer:(CALayer *)layer
{
    if (!self.animatedImage || [self.animatedImage.images count] == 0) {
        return;
    }
    if(self.currentFrame && ![self.currentFrame isKindOfClass:[NSNull class]]){
        layer.contents = (__bridge id)([self.currentFrame CGImage]);
    }
}

-(void)setHighlighted:(BOOL)highlighted
{
    if (!self.animatedImage) {
        [super setHighlighted:highlighted];
    }
}

-(CGSize)sizeThatFits:(CGSize)size
{
    return self.image.size;
}

#pragma mark - setters

-(void)setRunLoopMode:(NSString *)runLoopMode
{
    //这个地方需要重写，因为CADisplayLink是依赖在runloop中的，所以如果设置了imageview的runloop的话
    //就要停止动画，并重新设置CADisplayLink对应的runloop，最后在根据情况是否开始动画
    if (runLoopMode != _runLoopMode) {
        [self stopAnimating];
        NSRunLoop *runloop = [NSRunLoop mainRunLoop];
        [self.displayLink removeFromRunLoop:runloop forMode:_runLoopMode];
        [self.displayLink addToRunLoop:runloop forMode:runLoopMode];
        
        _runLoopMode = runLoopMode;
    }
}

-(void)setImage:(UIImage *)image
{
    if (image == self.image) {
        return;
    }
    
    [self stopAnimating];
    
    if ([image isKindOfClass:[YSCGifLoadImage class]] && image.images) {
        
        //设置静止态的图片
        if (image.images[0]) {
            [super setImage:image.images[0]];
        }else{
            [super setImage:nil];
        }
        self.animatedImage = (YSCGifLoadImage *)image;
    }else{
        self.animatedImage = nil;
        [super setImage:image];
    }
    [self.layer setNeedsDisplay];
}

//如果知道这个图就是gif，那可以直接调用这个方法
-(void)setAnimatedImage:(YSCGifLoadImage *)animatedImage
{
    _animatedImage = animatedImage;
    if (animatedImage == nil) {
        self.layer.contents = nil;
    }
}

- (NSUInteger)loopCount
{
    if (self.gifRepeatCount > 0) {
        return self.gifRepeatCount;
    } else {
        return self.animatedImage.loopCount ? : 1;
    }
    
    return 0;
}

- (void)setGifRepeatDelayOffset:(CGFloat)gifRepeatDelayOffset
{
    _gifRepeatDelayOffset = gifRepeatDelayOffset;
    _delayOffsetCount = gifRepeatDelayOffset * 60;
}

#pragma mark - getters

-(UIImage *)image
{
    return self.animatedImage ? : [super image];
}

-(CADisplayLink *)displayLink
{
    //如果有superview就是已经创建了，创建时新建一个CADisplayLink，并制定方法，最后加到一个Runloop中，完成创建
    if (self.superview) {
        if (!_displayLink && self.animatedImage) {
            
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeKeyframe:)];
            [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:self.runLoopMode];
            _displayLink.paused = YES;
        }
    }else{
        [_displayLink invalidate];
        _displayLink = nil;
    }
    return _displayLink;
}

-(NSString *)runLoopMode
{
    return _runLoopMode ?: NSRunLoopCommonModes;
}

//判断是否正在进行动画
-(BOOL)isAnimating
{
    return [super isAnimating] || (_displayLink && !_displayLink.isPaused);
}

@end
