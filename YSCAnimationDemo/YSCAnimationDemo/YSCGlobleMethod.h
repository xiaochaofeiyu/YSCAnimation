//
//  YSCGlobleMethod.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/2/28.
//  Copyright © 2017年 YSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCGlobleMethod : NSObject

+ (UIColor *)uiColorFromHexString:(NSString *)hexString;
+ (CGFloat)getStringWidth:(NSString *)string withRect:(CGRect)rect attributes:(NSDictionary<NSString *, id> *)attribute;

@end
