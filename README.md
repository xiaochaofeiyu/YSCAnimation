# YSCAnimation
demo地址：https://github.com/xiaochaofeiyu/YSCAnimation
## ripple animation
1). singlelineripple －－> corresponding class YSCRippleView 
```
[_rippleView showWithRippleType:YSCRippleTypeLine]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/singleLineRipple.gif)

2). ringRipple －－> corresponding class YSCRippleView
```
[_rippleView showWithRippleType:YSCRippleTypeRing]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/ringRipple.gif)

3). cicleRipple －－> corresponding class YSCRippleView
```
[_rippleView showWithRippleType:YSCRippleTypeCircle]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/circleRipple.gif)

4). mixedripple －－> corresponding class YSCRippleView
```
[_rippleView showWithRippleType:YSCRippleTypeMixed]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/mixedRipple.gif)

## wave animation
1). pusle －－> corresponding class YSCWaveView 
```
[_waveView showWaveViewWithType:YSCWaveTypePulse]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/pusle.gif)

2). wave －－> corresponding class YSCWaveView 
```
[_waveView showWaveViewWithType:YSCWaveTypeVoice]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/wave.gif)

3). movedWave －－> corresponding class YSCWaveView 
```
[_waveView showWaveViewWithType:YSCWaveTypeMovedVoice]
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/movedWave.gif)

## mask animation
1). circleLoad －－> corresponding class YSCCircleLoadAnimationView 
```
YSCCircleLoadAnimationView *shapeView = [[YSCCircleLoadAnimationView alloc] initWithFrame:self.view.bounds];
UIImage *image = [UIImage imageNamed:@"tree.jpg"];
shapeView.loadingImage.image = image;
[self.view addSubview:shapeView];
[shapeView startLoading];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/circleLoad.gif)

2). microphone wave －－> corresponding class YSCMicrophoneWaveView 

```
YSCMicrophoneWaveView *microphoneWaveView = [[YSCMicrophoneWaveView alloc] init];
[microphoneWaveView showMicrophoneWaveInParentView:self.view withFrame:self.view.bounds];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/microphoneWave.gif)

3). fanshaped wave －－> corresponding class YSCFanShapedView 

```
- (YSCFanShapedView *)fanshapedView
{
    if (!_fanshapedView) {
        self.fanshapedView = [[YSCFanShapedView alloc] init];
        _fanshapedView.frame = CGRectMake(0, 0, 300, 150);
        _fanshapedView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0 - 100);        
    }
    
    return _fanshapedView;
}

//show
[self.fanshapedView showInParentView:self.view WithType:YSCFanShapedShowTypeExpand];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/fanshaped.gif)

## voice wave
1). voice wave －－> corresponding class YSCVoiceWaveView YSCVoiceLoadingCircleView 

```
//show
self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
[self.voiceWaveView showInParentView:self.voiceWaveParentView];
[self.voiceWaveView startVoiceWave];

//hide
[self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{
            [self.updateVolumeTimer invalidate];
            _updateVolumeTimer = nil;
            [self.loadingView startLoadingInParentView:self.view];
        }];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/voicewave.gif)

## water wave
1). water wave －－> corresponding class YSCWaterWaveView 

```
- (YSCWaterWaveView *)waterWave
{
    if (!_waterWave) {
        self.waterWave = [[YSCWaterWaveView alloc] init];
        _waterWave.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);
        _waterWave.percent = 0.6;
        _waterWave.firstWaveColor = [UIColor colorWithRed:146/255.0 green:148/255.0 blue:216/255.0 alpha:1.0];
        _waterWave.secondWaveColor = [UIColor colorWithRed:84/255.0 green:87/255.0 blue:197/255.0 alpha:1.0];
    }
    
    return _waterWave;
}

//show
[self.view addSubview:self.waterWave];
[self.waterWave startWave];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/waterwave.gif)

## seawater wave
1). seawater wave －－> corresponding class YSCSeaGLView 
tip: it should not run in simulator

```
self.seaGLView = [[YSCSeaGLView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
[self.view addSubview:_seaGLView];

//hide
- (void)viewDidDisappear:(BOOL)animated
{
    [_seaGLView removeFromParent];
    _seaGLView = nil;
}
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/seawater.gif)

## emitter animation
1). fire －－> corresponding class YSCFireViewController 

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    //设置发射器
    _fireEmitter=[[CAEmitterLayer alloc] init];
    _fireEmitter.emitterPosition=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-20);
    _fireEmitter.emitterSize=CGSizeMake(self.view.frame.size.width-100, 20);
    _fireEmitter.renderMode = kCAEmitterLayerAdditive;
    //发射单元
    //火焰
    CAEmitterCell *fire = [CAEmitterCell emitterCell];
    fire.birthRate=800;
    fire.lifetime=2.0;
    fire.lifetimeRange=1.5;
    fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    fire.contents=(id)[[UIImage imageNamed:@"fire"] CGImage];
    [fire setName:@"fire"];
    
    fire.velocity=160;
    fire.velocityRange=80;
    fire.emissionLongitude=M_PI+M_PI_2;
    fire.emissionRange=M_PI_2;
    
    fire.scaleSpeed=0.3;
    fire.spin=0.2;
    fire.alphaSpeed = -0.05;
    
    //烟雾
    CAEmitterCell *smoke = [CAEmitterCell emitterCell];
    smoke.birthRate=400;
    smoke.lifetime=3.0;
    smoke.lifetimeRange=1.5;
    smoke.color=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05] CGColor];
    smoke.contents=(id)[[UIImage imageNamed:@"fire"] CGImage];
    [smoke setName:@"smoke"];
    
    smoke.velocity=250;
    smoke.velocityRange=100;
    smoke.emissionLongitude=M_PI+M_PI_2;
    smoke.emissionRange=M_PI_2;
    smoke.alphaSpeed = -0.05;
    
    _fireEmitter.emitterCells=[NSArray arrayWithObjects:smoke, fire,nil];
    [self.view.layer addSublayer:_fireEmitter];
    
}
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/fire.gif)

2). butterfly －－> corresponding class YSCButterflyViewController 

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    //emitter
    _butterflyEmitter=[[CAEmitterLayer alloc] init];
    _butterflyEmitter.emitterPosition=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-20);
    _butterflyEmitter.emitterSize=CGSizeMake(self.view.frame.size.width-100, 20);
    _butterflyEmitter.renderMode = kCAEmitterLayerUnordered;
    _butterflyEmitter.emitterShape = kCAEmitterLayerCuboid;
    
    _butterflyEmitter.emitterDepth = 10;
    _butterflyEmitter.preservesDepth = YES;
    
    //cells
    //blue butterfly
    CAEmitterCell *blueButterfly = [CAEmitterCell emitterCell];
    blueButterfly.birthRate=8;
    blueButterfly.lifetime=5.0;
    blueButterfly.lifetimeRange=1.5;
    blueButterfly.color=[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
    blueButterfly.contents=(id)[[UIImage imageNamed:@"butterfly1"] CGImage];
    [blueButterfly setName:@"blueButterfly"];
    
    blueButterfly.velocity=160;
    blueButterfly.velocityRange=80;
    blueButterfly.emissionLongitude=M_PI+M_PI_2;
    blueButterfly.emissionLatitude = M_PI+M_PI_2;
    blueButterfly.emissionRange=M_PI_2;
    
    blueButterfly.scaleSpeed=0.3;
    blueButterfly.spin=0.2;
    blueButterfly.alphaSpeed = 0.2;
    
    //yellow butterfly
    CAEmitterCell *yellowButterfly = [CAEmitterCell emitterCell];
    yellowButterfly.birthRate=4;
    yellowButterfly.lifetime=5.0;
    yellowButterfly.lifetimeRange=1.5;
    yellowButterfly.color=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05] CGColor];
    yellowButterfly.contents=(id)[[UIImage imageNamed:@"butterfly2"] CGImage];
    [yellowButterfly setName:@"yellowButterfly"];
    
    yellowButterfly.velocity=250;
    yellowButterfly.velocityRange=100;
    yellowButterfly.emissionLongitude=M_PI+M_PI_2;
    yellowButterfly.emissionLatitude = M_PI+M_PI_2;
    yellowButterfly.emissionRange=M_PI_2;
    yellowButterfly.alphaSpeed = 0.2;
    yellowButterfly.scaleSpeed=0.3;
    yellowButterfly.spin=0.2;
    _butterflyEmitter.emitterCells=[NSArray arrayWithObjects:yellowButterfly, blueButterfly,nil];
    [self.view.layer addSublayer:_butterflyEmitter];
    
}
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/butterfly.gif)

## repicator animation
1). matrixCircle －－> corresponding class YSCMatrixCircleAnimationView 

```
self.matrixCircleView = [[YSCMatrixCircleAnimationView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) xNum:8 yNum:8];
    _matrixCircleView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    
[self.view addSubview:_matrixCircleView];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/matrix%20animation.gif)

2). circle ripple －－> corresponding class YSCCircleRippleView 

```
self.rippleView = [[YSCCircleRippleView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
_rippleView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
[self.view addSubview:_rippleView];
_rippleView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
[_rippleView startAnimation];
```

![](http://7xq6q5.com1.z0.glb.clouddn.com/ripple%20replicator.gif)