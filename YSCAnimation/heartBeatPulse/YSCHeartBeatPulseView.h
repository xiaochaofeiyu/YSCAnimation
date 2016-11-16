//
//  YSCHeartBeatPulseView.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2016/11/8.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCHeartBeatPulseView : UIView

- (void)startHeartBeat;

- (void)pauseHeartBeat;

- (void)stopHeartBeat;

- (void)setHeartBeatSpeed:(NSInteger)speed;

@end
