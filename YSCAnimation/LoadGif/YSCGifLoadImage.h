//
//  YSCGifLoadImage.h
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/10/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCGifLoadImage : UIImage

@property (nonatomic,readonly) NSTimeInterval *frameDurations;
@property (nonatomic,readonly) NSUInteger     loopCount;
@property (nonatomic,readonly) NSTimeInterval totalDuratoin;

-(UIImage *)getFrameWithIndex:(NSUInteger)idx;

@end
