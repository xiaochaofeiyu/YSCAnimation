//
//  YSCTableRefreshLabelView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import "YSCTableRefreshLabelView.h"

#define kPullingDownString   @"下拉加载更多"
#define kPullingUpString     @"上拉加载更多"
#define kReleaseString       @"松开加载"
#define kIsLoadingString     @"正在加载"

#define kPullingString   self.state == UP ? kPullingUpString : kPullingDownString


//#define self.state

#define LabelHeight 50

@interface YSCTableRefreshLabelView()


@end

@implementation YSCTableRefreshLabelView {
    UILabel *titleLabel;
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}


-(void)setUp
{
    self.state = DOWN;
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height/2-LabelHeight/2, self.bounds.size.width, LabelHeight)];
    titleLabel.text = kPullingString;
    titleLabel.textColor = [YSCGlobleMethod uiColorFromHexString:@"666666"];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:titleLabel];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    if (loading) {
        titleLabel.text = kIsLoadingString;
    }
}

-(void)setProgress:(CGFloat)progress
{
    titleLabel.alpha = progress;
    
    if (!self.loading) {
        if (progress >= 1.0) {
            titleLabel.text = kReleaseString;
        }else{
            titleLabel.text = kPullingString;
        }
    }else{
        if (progress >= 0.91) {
            titleLabel.text = kReleaseString;
        }else{
            titleLabel.text = kPullingString;
        }
    }
    
}

- (CGFloat)titleWidth
{
    if (!titleLabel.text || 0 == self.frame.size.width || 0 == self.frame.size.height) {
        return 0.0;
    }
    NSDictionary<NSString *,id> *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:12]};
    CGFloat width = [YSCGlobleMethod getStringWidth:titleLabel.text withRect:self.frame attributes:attributes];
    
    return width;
}

@end
