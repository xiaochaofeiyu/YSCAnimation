//
//  YSCTableRefreshFooterView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import "YSCTableRefreshFooterView.h"
#import "YSCTableRefreshLabelView.h"
#import "YSCTableRefreshCurveView.h"

@interface  YSCTableRefreshFooterView()

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) UIScrollView *associatedScrollView;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, copy) void(^refreshingBlock)(void);
@property (nonatomic, assign) MMSCTRefreshStatus refreshStatus;

@end

static CGFloat footerHeight = 53.0;

@implementation YSCTableRefreshFooterView {
    YSCTableRefreshLabelView *labelView;
    YSCTableRefreshCurveView *curveView;
    
    CGSize contentSize;
    CGFloat originOffset;
    BOOL notTracking;
    BOOL loading;
    
    BOOL upDragEnable;
    BOOL hasAddObserver;
    
    CGFloat lastContentInsetBottom;//记住刚进入下拉时，初始ContentInset的bottom值，下拉结束后置回
}

#pragma mark -- Public Method

-(id)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar{
    
    self = [super initWithFrame:CGRectMake(scrollView.bounds.size.width/2-200/2, scrollView.contentSize.height, 200, footerHeight)];
    if (self) {
        if (navBar) {
            originOffset = 64.0f;
        }else{
            originOffset = 0.0f;
        }
        
        self.associatedScrollView = scrollView;
        [self setUp];
        [self.associatedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.associatedScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [labelView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
        [labelView addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
        
        self.hidden = NO;
        [self.associatedScrollView insertSubview:self atIndex:0];
        
        upDragEnable = YES;
        hasAddObserver = YES;
    }
    
    return self;
}

-(void)setProgress:(CGFloat)progress
{
    if (!upDragEnable) {
        return;
    }
    if (!self.associatedScrollView.tracking) {
        labelView.loading = YES;
    }

    CGFloat diff = 0.0;
    if (self.associatedScrollView.contentSize.height > self.associatedScrollView.bounds.size.height) {
        diff = self.associatedScrollView.contentOffset.y - (self.associatedScrollView.contentSize.height - self.associatedScrollView.bounds.size.height) - self.pullDistance;
    } else {
        diff = self.associatedScrollView.contentOffset.y - 5.0;
    }
    
    if (!self.associatedScrollView.tracking && !self.hidden) {
        if (!notTracking) {
            notTracking = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, footerHeight, 0);
            }];
        }
    }
    
    if (loading) {
        return;
    }
    
    if (diff > 0 && !self.hidden) {
        _refreshButton.hidden = YES;
        curveView.hidden = NO;
        labelView.hidden = NO;
        
        loading = YES;
        upDragEnable = NO;
        //旋转...
        [curveView showInRotateLinePath];
        [self startLoading:curveView];
        self.refreshingBlock();
    }else{
        labelView.loading = NO;
        curveView.transform = CGAffineTransformIdentity;
    }
}

- (void)refreshButtonTouched:(UIButton *)sender
{
    _refreshButton.hidden = YES;
    curveView.hidden = NO;
    labelView.hidden = NO;
    
//    BOOL isNetworkReachable = [MMSNetworkStatusUtil isNetworkReachable];
//    if (!isNetworkReachable) {
//        [YSCGlobleMethod showHUDWithString:@"网络不给力，请稍后重试"];
//        return;
//    }
    
    loading = YES;
    //旋转...
    [curveView showInRotateLinePath];
    [self startLoading:curveView];

    self.refreshingBlock();
}

-(void)addRefreshingBlock:(void (^)(void))block {
    
    self.refreshingBlock = block;
}

- (void)refreshFinished:(MMSCTRefreshStatus)refreshStatus refreshItemsCount:(NSInteger)itemsCount
{
    if (!loading) {
        return;
    }
    _refreshStatus = refreshStatus;
    if (MMSCTRefreshStatusSuccess == refreshStatus && itemsCount > 0) {
        [self stopRefreshing];
    } else if (MMSCTRefreshStatusCancel == refreshStatus) {
        [self stopRefreshing];
    } else if (MMSCTRefreshStatusFailed == refreshStatus) {
        [self refreshFailed];
    }
    _refreshButton.enabled = YES;
    
    if (itemsCount <= 0 && MMSCTRefreshStatusSuccess == refreshStatus) {
        [_refreshButton setTitle:@"无更多数据" forState:UIControlStateNormal];
        _refreshButton.enabled = NO;
        upDragEnable = NO;
        
        self.alpha = 1.0f;
        notTracking = NO;
        loading = NO;
        labelView.loading = NO;
        [self stopLoading:curveView];
        
        _refreshButton.hidden = NO;
        curveView.hidden = YES;
        labelView.hidden = YES;
        
        self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, footerHeight, 0);//防止最后 “无更多数据” 弹回
    }
}

-(void)refreshFailed
{
    self.alpha = 1.0f;
//    upDragEnable = NO;
    notTracking = NO;
    loading = NO;
    labelView.loading = NO;
    [self stopLoading:curveView];
    
    _refreshButton.hidden = NO;
    curveView.hidden = YES;
    labelView.hidden = YES;
    
    [_refreshButton setTitle:@"加载失败，点击重新加载" forState:UIControlStateNormal];
    self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, footerHeight, 0);//防止最后 “无更多数据” 弹回
}

-(void)stopRefreshing
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        upDragEnable = YES;
    });
    
    self.progress = 1.0;
//    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.alpha = 0.0f;
//        self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, 0, 0);
//    } completion:^(BOOL finished) {
        self.alpha = 1.0f;
        notTracking = NO;
        loading = NO;
        labelView.loading = NO;
        [self stopLoading:curveView];
        
        _refreshButton.hidden = NO;
        [_refreshButton setTitle:@"上滑加载更多" forState:UIControlStateNormal];
        curveView.hidden = YES;
        labelView.hidden = YES;
//    }];
}

#pragma mark -- Helper Method

-(void)setUp
{
    //一些默认参数
    self.pullDistance = footerHeight;
    
    _refreshButton = [[UIButton alloc] initWithFrame:self.bounds];
    [_refreshButton setTitle:@"上滑加载更多" forState:UIControlStateNormal];
    [_refreshButton setTitleColor:[YSCGlobleMethod uiColorFromHexString:@"666666"] forState:UIControlStateNormal];
    _refreshButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_refreshButton addTarget:self action:@selector(refreshButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _refreshButton.hidden = NO;
    [self addSubview:_refreshButton];
    
    curveView = [[YSCTableRefreshCurveView alloc] initWithFrame:CGRectMake(20, 0, 30, self.bounds.size.height)];
    [self insertSubview:curveView atIndex:0];
    curveView.hidden = YES;
    curveView.progress = 1.0;
    
    labelView = [[YSCTableRefreshLabelView alloc] initWithFrame:CGRectMake(curveView.frame.origin.x + curveView.frame.size.width + 10, curveView.frame.origin.y, 150, curveView.frame.size.height)];
    labelView.state = UP;
    [self insertSubview:labelView aboveSubview:curveView];
    labelView.hidden = YES;
}

- (void)layoutSubviews
{
    CGFloat titleWidth = [labelView titleWidth];
    CGFloat curveViewX = (200 - 30 - titleWidth - 2) / 2.0;
    
    curveView.frame = CGRectMake(curveViewX, 0, 30, self.bounds.size.height);
    labelView.frame = CGRectMake(curveView.frame.origin.x + curveView.frame.size.width + 2, curveView.frame.origin.y, titleWidth + 2, curveView.frame.size.height);
}

- (void)startLoading:(UIView *)rotateView {
    
    rotateView.transform = CGAffineTransformIdentity;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 0.5f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [rotateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)stopLoading:(UIView *)rotateView
{
    [rotateView.layer removeAllAnimations];
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        contentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        if (contentSize.height > 0.0) {
            self.hidden = NO;
        }
        self.frame = CGRectMake(self.associatedScrollView.bounds.size.width/2-200/2, contentSize.height, 200, footerHeight);
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (contentOffset.y >= (contentSize.height - self.associatedScrollView.bounds.size.height)) {
            
            //            self.center = CGPointMake(self.center.x, contentSize.height + (contentOffset.y - (contentSize.height - self.associatedScrollView.height))/2);
            
            self.progress = MAX(0.0, MIN((contentOffset.y - (contentSize.height - self.associatedScrollView.bounds.size.height)) / self.pullDistance, 1.0));
        }
    }
    
    if ([keyPath isEqualToString:@"loading"] || [keyPath isEqualToString:@"progress"]) {
        [self layoutIfNeeded];
    }
    if ([_refreshButton.titleLabel.text isEqualToString:@"无更多数据"] || [_refreshButton.titleLabel.text isEqualToString:@"加载失败，点击重新加载"]) {
        self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, footerHeight, 0);
    }
}

- (void)removeObservers
{
    if (hasAddObserver) {
        [self.associatedScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.associatedScrollView removeObserver:self forKeyPath:@"contentSize"];
        [labelView removeObserver:self forKeyPath:@"loading"];
        [labelView removeObserver:self forKeyPath:@"progress"];
        hasAddObserver = NO;
    }
}

#pragma dealloc

-(void)dealloc
{
    NSLog(@"");
}

@end
