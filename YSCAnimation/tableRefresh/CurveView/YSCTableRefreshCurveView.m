//
//  YSCTableRefreshCurveView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import "YSCTableRefreshCurveView.h"
#import "YSCTableRefreshCurveLayer.h"

@interface YSCTableRefreshCurveView()

@property (nonatomic,strong)YSCTableRefreshCurveLayer *curveLayer;

@end

@implementation YSCTableRefreshCurveView


+ (Class)layerClass
{
    return [YSCTableRefreshCurveLayer class];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)resetData
{
    [self.curveLayer resetData];
}

-(void)setProgress:(CGFloat)progress
{
    self.curveLayer.progress = progress;
    [self.curveLayer setNeedsDisplay];
}

- (void)showInRotateLinePath
{
    [self.curveLayer showInRotateLinePath];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    self.curveLayer = [YSCTableRefreshCurveLayer layer];
    self.curveLayer.frame = self.bounds;
    self.curveLayer.contentsScale = [UIScreen mainScreen].scale;
    self.curveLayer.progress = 0.0f;
    [self.curveLayer setNeedsDisplay];
    [self.layer addSublayer:self.curveLayer];
    
}


@end


