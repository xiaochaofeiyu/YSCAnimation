//
//  YSCTableRefreshHeaderView.h
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MMSCTRefreshStatus 刷新状态
 */
typedef NS_ENUM(NSInteger, MMSCTRefreshStatus) {
    /**
     *  刷新成功
     */
    MMSCTRefreshStatusSuccess,
    /**
     *  刷新失败
     */
    MMSCTRefreshStatusFailed,
    /**
     *  取消刷新
     */
    MMSCTRefreshStatusCancel,
};

@interface YSCTableRefreshHeaderView : UIView

/**
 *  需要滑动多大距离才能松开
 */
@property(nonatomic,assign)CGFloat pullDistance;


/**
 *  初始化方法
 *
 *  @param scrollView 关联的滚动视图
 *
 *  @return self
 */
-(id)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar;

/**
 *  立即触发下拉刷新
 */
-(void)triggerPulling;

/**
 *  停止旋转，并且滚动视图回弹到顶部
 */
-(void)stopRefreshing;


/**
 *  刷新执行的具体操作
 *
 *  @param block 操作
 */

-(void)addRefreshingBlock:(void (^)(void))block;

- (void)refreshFinished:(MMSCTRefreshStatus)refreshStatus refreshItemsCount:(NSInteger)itemsCount;

- (void)removeObservers;
@end

