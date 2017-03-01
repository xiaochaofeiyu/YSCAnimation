//
//  YSCTableRefreshLabelView.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UP,
    DOWN,
} PULLINGSTATE;

@interface YSCTableRefreshLabelView : UIView


/**
 *  LabelView的进度 0~1
 */
@property(nonatomic,assign) CGFloat progress;


/**
 *  是否正在刷新
 */
@property(nonatomic,assign) BOOL loading;


/**
 *  上拉还是下拉
 */
@property(nonatomic,assign) PULLINGSTATE state;

- (CGFloat)titleWidth;

@end
