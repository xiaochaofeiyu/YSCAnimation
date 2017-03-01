//
//  YSCTableRefreshCurveLayer.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface YSCTableRefreshCurveLayer : CAShapeLayer

/**
 *  CurveLayer的进度 0~1
 */
@property(nonatomic,assign)CGFloat progress;

- (void)showInRotateLinePath;
- (void)resetData;
@end
