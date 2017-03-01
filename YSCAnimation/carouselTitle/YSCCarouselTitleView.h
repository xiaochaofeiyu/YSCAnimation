//
//  YSCCarouselTitleView.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2016/12/22.
//  Copyright © 2016年 MMS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YSCCarouselTitleViewTappedBlock)(void);

@interface YSCCarouselTitleView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) YSCCarouselTitleViewTappedBlock tappedBlock;

@end
