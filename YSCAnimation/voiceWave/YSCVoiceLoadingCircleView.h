//
//  YSCVoiceLoadingCircleView.h
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/8/15.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCVoiceLoadingCircleView : UIView

/**
 *  初始化
 *
 *  @param radius 圆圈半径
 *
 *  @param center 本视图中心坐标
 *
 *  @return 实例对象
 */
- (instancetype)initWithCircleRadius:(CGFloat)radius center:(CGPoint)center;

/**
 *  开始并添加语音搜索loading动画
 */
- (void)startLoadingInParentView:(UIView *)parentView;

/**
 *  停止语音搜搜loading动画
 */
- (void)stopLoading;
@end
