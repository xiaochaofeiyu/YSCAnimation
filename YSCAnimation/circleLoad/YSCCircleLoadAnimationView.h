//
//  YSCCircleLoadAnimationView.h
//  AnimationDemo
//
//  Created by yushichao on 16/2/15.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCCircleLoadAnimationView : UIView

- (void)startLoading;

@property (nonatomic, strong) UIImageView *loadingImage;
@property (nonatomic, assign) CGFloat circleRadius;

@end
