//
//  YSCFanShapedView.h
//  AnimationLearn
//
//  Created by yushichao on 16/2/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSCFanShapedShowType) {
    YSCFanShapedShowTypeExpand,
    YSCFanShapedShowTypeShrink,
};

@interface YSCFanShapedView : UIView

- (void)showInParentView:(UIView *)parentView WithType:(YSCFanShapedShowType)type;
- (void)setShowType:(YSCFanShapedShowType)type;

- (void)removeFromParentView;

@end
