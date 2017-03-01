//
//  YSCTableRefreshHeaderView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/1/18.
//  Copyright © 2017年 MMS. All rights reserved.
//

#import "YSCTableRefreshHeaderView.h"
#import "YSCTableRefreshLabelView.h"
#import "YSCTableRefreshCurveView.h"

@interface  YSCTableRefreshHeaderView()

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) UIScrollView *associatedScrollView;
@property (nonatomic, copy) void(^refreshingBlock)(void);
@property (nonatomic, assign) MMSCTRefreshStatus refreshStatus;

@end

@implementation YSCTableRefreshHeaderView {
    YSCTableRefreshLabelView *labelView;
    YSCTableRefreshCurveView *curveView;
    
    CGFloat originOffset;
    BOOL willEnd;
    BOOL notTracking;
    BOOL loading;
    
    BOOL downDragEnable;
    BOOL hasAddObserver;
    CGFloat originContentInsetBottom;//记住刚进入下拉时，初始ContentInset的bottom值，下拉结束后置回
}

#pragma mark -- Public Method

-(id)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar{
    
    self = [super initWithFrame:CGRectMake(scrollView.bounds.size.width/2-200/2, -53, 200, 53)];
    if (self) {
        if (navBar) {
            originOffset = 64.0f;
        }else{
            originOffset = 0.0f;
        }
        self.associatedScrollView = scrollView;
        [self setUp];
        [self.associatedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.associatedScrollView insertSubview:self atIndex:0];
        
        [labelView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
        [labelView addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
        
        originContentInsetBottom = 0.0;
        downDragEnable = YES;
        hasAddObserver = YES;
    }
    
    return self;
    
}


-(void)setProgress:(CGFloat)progress{
    
    if (!downDragEnable) {
        labelView.hidden = YES;
        curveView.hidden = YES;
        return;
    } else {
        labelView.hidden = NO;
        curveView.hidden = NO;
    }
    
    if (!self.associatedScrollView.tracking) {
        labelView.loading = YES;
    }
    
    if (!willEnd && !loading ) {
        NSLog(@"progress:%f",progress);
        curveView.progress = labelView.progress = progress;
    }
    
    CGFloat diff = fabs(self.associatedScrollView.contentOffset.y+originOffset) - self.pullDistance + 10;
        NSLog(@"diff:%f",diff);
    
    if (diff > 0) {
        
        if (!self.associatedScrollView.tracking) {
            if (!notTracking) {
                notTracking = YES;
                loading = YES;
//                labelView.loading = YES;
                
                NSLog(@"旋转");
                
                //旋转...
                [curveView showInRotateLinePath];
                [self startLoading:curveView];
                
                originContentInsetBottom = self.associatedScrollView.contentInset.bottom;
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.associatedScrollView.contentInset = UIEdgeInsetsMake(self.pullDistance + originOffset, 0, originContentInsetBottom, 0);
                    
                } completion:^(BOOL finished) {
                    
                    if (_refreshingBlock) {
                        _refreshingBlock();
                    }
                    
                }];
            }
        }
        
        //        if (!loading) {
        //
        //            curveView.transform = CGAffineTransformMakeRotation(M_PI * (diff*2/180));
        //        }
        
    }else{
        
        labelView.loading = NO;
        curveView.transform = CGAffineTransformIdentity;
        
    }
    
}


-(void)addRefreshingBlock:(void (^)(void))block
{
    self.refreshingBlock = block;
}

- (void)refreshFinished:(MMSCTRefreshStatus)refreshStatus refreshItemsCount:(NSInteger)itemsCount
{
    if (!loading) {
        return;
    }
    _refreshStatus = refreshStatus;
    
    if (MMSCTRefreshStatusSuccess == refreshStatus && itemsCount == 0) {
        downDragEnable = NO;
    } else {
        downDragEnable = YES;
    }
    [self stopRefreshing];
}

-(void)triggerPulling
{
    [self.associatedScrollView setContentOffset:CGPointMake(0, -self.pullDistance-originOffset) animated:YES];
}

-(void)stopRefreshing{
    
    willEnd = YES;
    
    self.progress = 1.0;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0f;
        self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset+0.1, 0, originContentInsetBottom, 0);
    } completion:^(BOOL finished) {
        self.alpha = 1.0f;
        willEnd = NO;
        notTracking = NO;
        loading = NO;
        labelView.loading = NO;
        [self stopLoading:curveView];
        [curveView resetData];
    }];
    
    
}

#pragma mark -- Helper Method

-(void)setUp{
    
    //一些默认参数
    self.pullDistance = 53;
    
    curveView = [[YSCTableRefreshCurveView alloc] initWithFrame:CGRectMake(20, 0, 30, self.bounds.size.height)];
    [self insertSubview:curveView atIndex:0];
    
    
    labelView = [[YSCTableRefreshLabelView alloc] initWithFrame:CGRectMake(curveView.frame.origin.x + curveView.frame.size.width + 10, curveView.frame.origin.y, 150, curveView.frame.size.height)];
    [self insertSubview:labelView aboveSubview:curveView];
}

- (void)layoutSubviews
{
    CGFloat titleWidth = [labelView titleWidth];
    CGFloat curveViewX = (200 - 30 - titleWidth - 2) / 2.0;
    
    curveView.frame = CGRectMake(curveViewX, 0, 30, self.bounds.size.height);
    labelView.frame = CGRectMake(curveView.frame.origin.x + curveView.frame.size.width + 2, curveView.frame.origin.y, titleWidth + 2, curveView.frame.size.height);
}

- (void)startLoading:(UIView *)rotateView
{
    rotateView.transform = CGAffineTransformIdentity;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 0.5f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [rotateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}

- (void)stopLoading:(UIView *)rotateView{
    
    [rotateView.layer removeAllAnimations];
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        if (contentOffset.y + originOffset <= 0) {
            
            self.progress = MAX(0.0, MIN(fabs(contentOffset.y+originOffset)/self.pullDistance, 1.0));
            
        }
    }
    
    if ([keyPath isEqualToString:@"loading"] || [keyPath isEqualToString:@"progress"]) {
        [self layoutIfNeeded];
    }
}

- (void)removeObservers
{
    if (hasAddObserver) {
        [self.associatedScrollView removeObserver:self forKeyPath:@"contentOffset"];
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
