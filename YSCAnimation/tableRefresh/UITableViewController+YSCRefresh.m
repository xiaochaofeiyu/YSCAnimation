//
//  MMSCTListViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/5.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import "UITableViewController+YSCRefresh.h"
#import <objc/runtime.h>

static void *hasRefreshHeaderKey = &hasRefreshHeaderKey;
static void *hasRefreshFooterKey = &hasRefreshFooterKey;
static void *refreshHeaderViewKey = &refreshHeaderViewKey;
static void *refreshFooterViewKey = &refreshFooterViewKey;

//@interface UITableViewController (YSCRefresh)

//@property (nonatomic, strong) YSCTableRefreshHeaderView *refreshHeaderView;
//@property (nonatomic, strong) YSCTableRefreshFooterView *refreshFooterView;

//@end

@implementation UITableViewController (YSCRefresh)

#pragma mark - 上/下拉刷新

//- (BOOL)isNavigationBarHidden
//{
//    return YES;
//}

- (void)setHasRefreshHeader:(BOOL)hasRefreshHeader
{
    objc_setAssociatedObject(self, hasRefreshHeaderKey, @(hasRefreshHeader), OBJC_ASSOCIATION_RETAIN);
    
    YSCTableRefreshHeaderView *refreshHeaderView = objc_getAssociatedObject(self, refreshHeaderViewKey);
    if (hasRefreshHeader && !refreshHeaderView) {
        refreshHeaderView = [[YSCTableRefreshHeaderView alloc] initWithAssociatedScrollView:self.tableView withNavigationBar:!self.navigationController.isNavigationBarHidden];
        objc_setAssociatedObject(self, refreshHeaderViewKey, refreshHeaderView, OBJC_ASSOCIATION_RETAIN);
    } else if (!hasRefreshHeader && refreshHeaderView.superview) {
        [self removeRefreshHeaderViewObservers];
        [refreshHeaderView removeFromSuperview];
        refreshHeaderView = nil;
    }
}

- (BOOL)hasRefreshHeader
{
    BOOL hasRefreshHeader = [objc_getAssociatedObject(self, hasRefreshHeaderKey) boolValue];
    return hasRefreshHeader;
}

- (void)setHeederRefreshingBlock:(void (^)(void))heederRefreshingBlock
{
    YSCTableRefreshHeaderView *refreshHeaderView = objc_getAssociatedObject(self, refreshHeaderViewKey);
    [refreshHeaderView addRefreshingBlock:heederRefreshingBlock];
}

- (void)headerRefreshFinished:(MMSCTRefreshStatus)refreshStatus refreshItemsCount:(NSInteger)itemsCount
{
    YSCTableRefreshHeaderView *refreshHeaderView = objc_getAssociatedObject(self, refreshHeaderViewKey);
    [refreshHeaderView refreshFinished:refreshStatus refreshItemsCount:itemsCount];
}

- (void)removeRefreshHeaderViewObservers
{
    YSCTableRefreshHeaderView *refreshHeaderView = objc_getAssociatedObject(self, refreshHeaderViewKey);
    [refreshHeaderView removeObservers];
}

- (void)setHasRefreshFooter:(BOOL)hasRefreshFooter
{
    objc_setAssociatedObject(self, hasRefreshFooterKey, @(hasRefreshFooter), OBJC_ASSOCIATION_RETAIN);
    
    YSCTableRefreshFooterView *refreshFooterView = objc_getAssociatedObject(self, refreshFooterViewKey);
    if (hasRefreshFooter && !refreshFooterView) {
        refreshFooterView = [[YSCTableRefreshFooterView alloc] initWithAssociatedScrollView:self.tableView withNavigationBar:!self.navigationController.isNavigationBarHidden];
        objc_setAssociatedObject(self, refreshFooterViewKey, refreshFooterView, OBJC_ASSOCIATION_RETAIN);
    } else if (!hasRefreshFooter && refreshFooterView.superview) {
        [self removeRefreshFooterViewObservers];
        [refreshFooterView removeFromSuperview];
        refreshFooterView = nil;
    }
}

- (BOOL)hasRefreshFooter
{
    BOOL hasRefreshFooter = [objc_getAssociatedObject(self, hasRefreshFooterKey) boolValue];
    return hasRefreshFooter;
}

- (void)setFooterRefreshingBlock:(void (^)(void))footerRefreshingBlock
{
    YSCTableRefreshFooterView *refreshFooterView = objc_getAssociatedObject(self, refreshFooterViewKey);
    [refreshFooterView addRefreshingBlock:footerRefreshingBlock];
}

- (void)footerRefreshFinished:(MMSCTRefreshStatus)refreshStatus refreshItemsCount:(NSInteger)itemsCount
{
    YSCTableRefreshFooterView *refreshFooterView = objc_getAssociatedObject(self, refreshFooterViewKey);
    [refreshFooterView refreshFinished:refreshStatus refreshItemsCount:itemsCount];
}

- (void)removeRefreshFooterViewObservers
{
    YSCTableRefreshFooterView *refreshFooterView = objc_getAssociatedObject(self, refreshFooterViewKey);
    [refreshFooterView removeObservers];
}

@end
