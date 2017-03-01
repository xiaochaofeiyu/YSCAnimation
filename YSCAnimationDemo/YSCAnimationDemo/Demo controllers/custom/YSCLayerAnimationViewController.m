//
//  YSCLayerAnimationViewController.m
//  AnimationLearn
//
//  Created by yushichao on 16/8/19.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCLayerAnimationViewController.h"

@interface YSCLayerAnimationViewController ()<CAAnimationDelegate>

@end

@implementation YSCLayerAnimationViewController

- (void)dealloc
{
    NSLog(@"");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addShadowLayer];//add shadow
    
    CALayer *subLayer = [[CALayer alloc] init];
    subLayer.position = CGPointMake(50, 100);
    subLayer.bounds = CGRectMake(0, 0, 30, 30);
//    subLayer.delegate = self;
    subLayer.backgroundColor = [UIColor blueColor].CGColor;
    subLayer.masksToBounds = YES;
    subLayer.cornerRadius = 15;
    
    [self.view.layer addSublayer:subLayer];
    [subLayer setNeedsDisplay];///需要调，不然不走drawLayer: inContext:
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addShadowLayer
{
    CALayer *shadowLayer = [[CALayer alloc] init];
    shadowLayer.position = CGPointMake(50, 100);
    shadowLayer.bounds = CGRectMake(0, 0, 30, 30);
    shadowLayer.cornerRadius = 15;
    shadowLayer.shadowColor = [UIColor yellowColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(3, 3);
    shadowLayer.shadowOpacity = 0.5;
    //layer要有内容才能显出阴影，如本身contents，backgroundColor，border
    shadowLayer.borderColor = [UIColor redColor].CGColor;
    shadowLayer.borderWidth = 2;
    //    shadowLayer.backgroundColor = [UIColor redColor].CGColor;
    //    shadowLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"D.jpg"].CGImage);
    
    [self.view.layer addSublayer:shadowLayer];
}

- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)theContext
{
    CGContextScaleCTM(theContext, 1, -1);
    CGContextTranslateCTM(theContext, 0, - 30);
    CGImageRef imageRef = [UIImage imageNamed:@"tree.jpg"].CGImage;
    CGContextDrawImage(theContext, CGRectMake(0, 0, 100, 100), imageRef);
    
    CGImageRelease(imageRef);
}

- (void)addAnimationToLayerWithMode:(YSCAnimatinType)mode endPoint:(CGPoint)endPoint
{
    NSArray *subLayers = [self.view.layer sublayers];
    CALayer *animationLayer = [subLayers lastObject];
    
    if (YSCAnimatinTypeBasic == mode) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(50, 100)];
        animation.toValue = [NSValue valueWithCGPoint:endPoint];
        animation.duration = 3;
        [animationLayer addAnimation:animation forKey:@"animaton-position"];
    } else if (YSCAnimatinTypeKeyFrame == mode) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(50, 100)], [NSValue valueWithCGPoint:CGPointMake(150, 200)], [NSValue valueWithCGPoint:CGPointMake(50, 300)], [NSValue valueWithCGPoint:endPoint], nil];
        animation.duration = 4;
        animation.calculationMode = kCAAnimationPaced;//kCAAnimationLinear:每个keyValue间匀速  kCAAnimationCubic:平滑移动 kCAAnimationDiscrete:跳动，没有中间的滑动 kCAAnimationPaced:整个动画匀速，动画时间相关参数默认设置好 kCAAnimationCubicPaced:整个动画平滑匀速，动画时间相关参数默认设置好
        animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:0.6], [NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];//kCAAnimationDiscrete 需要多添一个time值，最后一个时间间隔用于动画结束后返回layer的初始状态或新设置的，kCAAnimationPaced和kCAAnimationCubicPaced对time属性不起作用，其他的keyValue数与time数相同，代表value的起始时间
        animation.delegate = self;//得放在addAnimation:之前，否则代理不会调用
        //存储当前位置在动画结束后使用
        [animation setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"AnimationLocation"];
        [animationLayer addAnimation:animation forKey:@"animation-point"];
    } else if (YSCAnimatinTypeKeyFramePath == mode) {
        animationLayer.position = CGPointMake(350, 100);//加在添加动画前，先把layer的状态设为动画的最后状态，可避免动画完成后产生一个从初始位置到最终设置位置的快速隐式动画；若加在添加动画后，会产生一个从初始位置到最终设置位置的快速隐式动画，然后再开始添加的动画；采用代理的方式，在动画结束后，设置layer的最终状态（删除隐式动画），则可能出现一个从初始位置到最终设置位置的快速闪动。
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, 50, 100);
        CGPathAddCurveToPoint(pathRef, NULL, 70, 200, 230, 200, 250, 100);
        CGPathAddCurveToPoint(pathRef, NULL, 270, 200, 330, 200, 350, 100);
        animation.path = pathRef;
        CGPathRelease(pathRef);
        animation.duration = 3;
        //        animation.beginTime = CACurrentMediaTime() + 2;//此beginTime为图层的本地时间
        animation.calculationMode = kCAAnimationLinear;
        animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil];//对于keyValues类型，标识各个value间的起始时间，个数为value数相同（kCAAnimationDiscrete会多一个）；对于path则表示各个线段的起始时间，包括直线或曲线
        animation.delegate = self;//得放在addAnimation:之前，否则代理不会调用
        animation.timeOffset = 0.0;//动画开始播放的位置，但仍是完整的一个动画。只是开始和结束的位置变了
        animation.beginTime = CACurrentMediaTime() + 1;
        //存储当前位置在动画结束后使用
        [animation setValue:[NSValue valueWithCGPoint:CGPointMake(350, 100)] forKey:@"AnimationLocation"];
        [animationLayer addAnimation:animation forKey:@"animation-point"];
    }
}

#pragma mark - CAAnimationDelegate

-(void)animationDidStart:(CAAnimation *)anim
{
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSArray *subLayers = [self.view.layer sublayers];
    CALayer *animationLayer = [subLayers lastObject];
    
    //animationLayer.position = [[anim valueForKey:@"AnimationLocation"] CGPointValue];//直接设置最终位置，会产生一个从初始位置到最终设置位置的快速隐式动画，解决这个问题有两种办法：关闭图层隐式动画、设置动画图层为根图层
    
    //关闭图层隐式动画
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
    animationLayer.position=[[anim valueForKey:@"AnimationLocation"] CGPointValue];//设置最终位置，否则，layer会回到初始位置，动画并没有改变layer。
    //提交事务
    [CATransaction commit];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    NSArray *subLayers = [self.view.layer sublayers];
    CALayer *animationLayer = [subLayers lastObject];
    CAAnimation *animation = [animationLayer animationForKey:@"animation-point"];
    
    CFTimeInterval timeInterval = [animationLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    NSLog(@"CurrentMediaTime:%f",timeInterval);
    
    if (animation) {
        if (0 == animationLayer.speed) {
            [self resumeAnimation];
        } else {
            [self pauseAnimation];
        }
    } else {
        NSInteger mode = YSCAnimatinTypeKeyFramePath;
        [self addAnimationToLayerWithMode:mode endPoint:point];
        animationLayer.beginTime = -1;
    }
}

- (void)pauseAnimation
{
    NSArray *subLayers = [self.view.layer sublayers];
    CALayer *animationLayer = [subLayers lastObject];
    CFTimeInterval timeInterval = [animationLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    animationLayer.timeOffset = timeInterval;
    animationLayer.speed = 0;
    
    NSLog(@"%f, %f", timeInterval, CACurrentMediaTime());
}

- (void)resumeAnimation
{
    NSArray *subLayers = [self.view.layer sublayers];
    CALayer *animationLayer = [subLayers lastObject];
    animationLayer.beginTime = CACurrentMediaTime() - animationLayer.timeOffset;//beginTime为本图层相对于父图层的时间，为相对时间；动画时间为当前图层时间 + beginTime，即为当前绝对时间；如在此基础上加1，则动画会往前倒1秒开始显示(此时本图层的开始时间已经超出父图层时间，即绝对时间，相当于动画暂停处的前面一秒)，减一的话就是往后1秒开始显示
    animationLayer.timeOffset = 0;//在当前动画timeOffset后的动画开始显示
    animationLayer.speed = 1;
    
    NSLog(@"%f, %f", animationLayer.beginTime, CACurrentMediaTime());
}

@end
