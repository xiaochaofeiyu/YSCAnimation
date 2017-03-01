//
//  YSCGlobleMethod.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/2/28.
//  Copyright © 2017年 YSC. All rights reserved.
//

#import "YSCGlobleMethod.h"

@implementation YSCGlobleMethod

/**
 * @desc 从十六进制字符串，生成uicolor
 * @param hexString 格式：#ffffff or 0xffffff or 0Xffffff or ffffff
 */
+ (UIColor *)uiColorFromHexString:(NSString *)hexString
{
    if (!(hexString.length > 0)) {
        return nil;
    }
    NSString *rgbString = nil;
    if (hexString.length < 6) {
        return nil;
    } else if (hexString.length == 6) { //ffffff
        rgbString = hexString;
    } else if (hexString.length == 7 && [hexString hasPrefix:@"#"]) { //#ffffff
        rgbString = [hexString substringFromIndex:1];
    } else if (hexString.length == 8 && ([hexString hasPrefix:@"0x"] || [hexString hasPrefix:@"0X"])) {//0xffffff 0Xffffff
        rgbString = [hexString substringFromIndex:2];
    } else {
        return nil;
    }
    //
    unsigned int rValue = 0;
    unsigned int gValue = 0;
    unsigned int bValue = 0;
    NSRange range;
    range.length = 2;
    //r
    range.location = 0;
    NSScanner *rScanner = [NSScanner scannerWithString:[rgbString substringWithRange:range]];
    [rScanner scanHexInt:&rValue];
    //g
    range.location = 2;
    NSScanner *gScanner = [NSScanner scannerWithString:[rgbString substringWithRange:range]];
    [gScanner scanHexInt:&gValue];
    //b
    range.location = 4;
    NSScanner *bScanner = [NSScanner scannerWithString:[rgbString substringWithRange:range]];
    [bScanner scanHexInt:&bValue];
    
    UIColor *color = [UIColor colorWithRed:rValue/255.0 green:gValue/255.0 blue:bValue/255.0 alpha:1];
    return color;
}

+ (CGFloat)getStringWidth:(NSString *)string withRect:(CGRect)rect attributes:(NSDictionary<NSString *, id> *)attribute
{
    if (!(string.length > 0)) {
        return 0.0;
    }
    CGSize textSize = CGSizeZero;
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX , rect.size.height)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attribute
                                        context:nil].size;
    } else {
        textSize = [string sizeWithFont:attribute[NSFontAttributeName]
                      constrainedToSize:CGSizeMake(CGFLOAT_MAX, rect.size.height)
                          lineBreakMode:NSLineBreakByWordWrapping];
    }
    return textSize.width;
}


@end
