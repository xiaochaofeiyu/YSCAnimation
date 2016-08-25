//
//  YSCWaterWaveView.h
//  AnimationLearn
//
//  Created by yushichao on 16/3/2.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSCWaterWaveAnimateType) {
    YSCWaterWaveAnimateTypeShow,
    YSCWaterWaveAnimateTypeHide,
};

@interface YSCWaterWaveView : UIView

@property (nonatomic, strong) UIColor *firstWaveColor;    // 第一个波浪颜色
@property (nonatomic, strong) UIColor *secondWaveColor;   // 第二个波浪颜色
@property (nonatomic, assign) CGFloat percent;            // 上升高度最大百分比

-(void) startWave;
-(void) stopWave;
-(void) reset;
- (void)removeFromParentView;

@end
