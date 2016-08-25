//
//  YSCWaveView.h
//  AnimationLearn
//
//  Created by yushichao on 16/2/19.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSCWaveType) {
    YSCWaveTypePulse,
    YSCWaveTypeMovedVoice,
    YSCWaveTypeVoice,
};

@interface YSCWaveView : UIView

- (void)removeFromParentView;

- (void)showWaveViewWithType:(YSCWaveType)type;

- (void)setWaveWidth:(CGFloat)width;

@end
