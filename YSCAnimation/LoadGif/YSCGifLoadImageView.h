//
//  YSCGifLoadImageView.h
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/10/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSCGifLoadImage.h"

typedef void(^GifAnimatingCompleteCallBack)(void);

@interface YSCGifLoadImageView : UIImageView

/**
 *  开始播放
 *
 *  @param gifRepeatCount                 播放次数
 *  @param gifRepeatDelayOffset           每次播放时间间隔
 *  @param completeCallBack               gif播放完后的回掉
 */
- (void)startGifAnimatingWithGifRepeatCount:(NSInteger)gifRepeatCount gifRepeatDelayOffset:(CGFloat)gifRepeatDelayOffset animatingCompleteCallBack:(GifAnimatingCompleteCallBack)completeCallBack;

- (void)stopGifAnimation;

@end
