//
//  YSCRippleView.h
//  AnimationLearn
//
//  Created by yushichao on 16/2/17.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSCRippleType) {
    YSCRippleTypeLine,
    YSCRippleTypeRing,
    YSCRippleTypeCircle,
    YSCRippleTypeMixed,
};

@interface YSCRippleView : UIView

/**
 *  show ripple view
 *
 *  @param type ripple type
 */
- (void)showWithRippleType:(YSCRippleType)type;

/**
 *  remove ripple view
 */
- (void)removeFromParentView;

@end
