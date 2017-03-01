//
//  YSCCarouselTitleView.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2016/12/22.
//  Copyright © 2016年 MMS. All rights reserved.
//

#import "YSCCarouselTitleView.h"
//#import "NSString+MMSAdditions.h"

typedef NS_ENUM(NSInteger, MMSTitleViewType) {
    MMSTitleViewTypeStatic, //静态
    MMSTitleViewTypeCarousel, //轮播
};

@interface YSCCarouselTitleView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *staticTitleLabel;
@property (nonatomic, strong) UILabel *firstCarouselTitleLabel;
@property (nonatomic, strong) UILabel *secondCarouselTitleLabel;
@property (nonatomic, assign) MMSTitleViewType type;

@end

static CGFloat enlargeHitRectGap = 15;
static CGFloat labelOffset = 50;//轮播的两个label的间距
static CGFloat carouselSpeed = 25.0;//轮播速度 25个屏幕点单位/秒

@implementation YSCCarouselTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubviews];
        _type = MMSTitleViewTypeStatic;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpSubviews];
        _type = MMSTitleViewTypeStatic;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setUpSubviews
{
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    
    self.staticTitleLabel = [self getTitleLabel];
    _staticTitleLabel.textAlignment = NSTextAlignmentCenter;
    _staticTitleLabel.hidden = YES;
    [self.contentView addSubview:_staticTitleLabel];
    
    self.firstCarouselTitleLabel = [self getTitleLabel];
    _firstCarouselTitleLabel.textAlignment = NSTextAlignmentLeft;
    _firstCarouselTitleLabel.hidden = YES;
    [self.contentView addSubview:_firstCarouselTitleLabel];
    
    self.secondCarouselTitleLabel = [self getTitleLabel];
    _secondCarouselTitleLabel.textAlignment = NSTextAlignmentLeft;
    _secondCarouselTitleLabel.hidden = YES;
    [self.contentView addSubview:_secondCarouselTitleLabel];
    
    [self addTapGestureRecognizer];
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapped:)];
    [self addGestureRecognizer:tap];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _staticTitleLabel.text = _title;
    _firstCarouselTitleLabel.text = _title;
    _secondCarouselTitleLabel.text = _title;
    [self updateTitleViewType];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    _contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _staticTitleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGFloat titleWidth = [self getTitleWidth];
    _firstCarouselTitleLabel.frame = CGRectMake(0, 0, titleWidth + labelOffset, self.frame.size.height);
    _secondCarouselTitleLabel.frame = CGRectMake(titleWidth + labelOffset, 0, titleWidth + labelOffset, self.frame.size.height);
    
    [self updateTitleViewType];
    [_contentView.layer removeAllAnimations];
    if (MMSTitleViewTypeStatic == _type) {
        _staticTitleLabel.hidden = NO;
        _firstCarouselTitleLabel.hidden = YES;
        _secondCarouselTitleLabel.hidden = YES;
    } else if (MMSTitleViewTypeCarousel == _type) {
        _staticTitleLabel.hidden = YES;
        _firstCarouselTitleLabel.hidden = NO;
        _secondCarouselTitleLabel.hidden = NO;
        [self addCarouselAnimation];
    }
}

- (void)titleTapped:(UITapGestureRecognizer *)gesture
{
    if (_tappedBlock) {
        _tappedBlock();
    }
}

- (void)addCarouselAnimation
{
    CGFloat titleWidth = [self getTitleWidth];
    
    CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    aniamtion.values = @[@0, @0, @(-titleWidth - labelOffset), @(-titleWidth - labelOffset)];
    aniamtion.keyTimes = @[@0, @0.1, @0.9, @1.0];
    aniamtion.duration = (titleWidth + labelOffset) / carouselSpeed;
    aniamtion.repeatCount = INFINITY;
    aniamtion.removedOnCompletion = NO;
    
    [_contentView.layer addAnimation:aniamtion forKey:@"carousel"];
}

- (void)updateTitleViewType
{
    if (!_title || 0 == self.frame.size.width || 0 == self.frame.size.height) {
        return;
    }
    CGFloat titleWidth = [self getTitleWidth];
    if (titleWidth > self.frame.size.width - 2) {
        _type = MMSTitleViewTypeCarousel;
    } else {
        _type = MMSTitleViewTypeStatic;
    }
}

- (CGFloat)getTitleWidth
{
    if (!_title || 0 == self.frame.size.width || 0 == self.frame.size.height) {
        return 0.0;
    }
    NSDictionary<NSString *,id> *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:18]};
    CGFloat width = [YSCGlobleMethod getStringWidth:_title withRect:self.frame attributes:attributes];
    
    return width;
}

- (UILabel *)getTitleLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 1;
    
    return label;
}

//扩大点击区域
- (CGRect)enlargedHitRect
{
    return CGRectMake(self.bounds.origin.x - enlargeHitRectGap,
                      self.bounds.origin.y - enlargeHitRectGap,
                      self.bounds.size.width + 2 * enlargeHitRectGap,
                      self.bounds.size.height + 2 * enlargeHitRectGap);
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*) event
{
    CGRect rect = [self enlargedHitRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? self : nil;
}

@end
