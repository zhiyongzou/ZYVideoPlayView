//
//  ZYLoadingView.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/10/11.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import "ZYLoadingView.h"

static const CGFloat kLoadingViewWidth = 80.0;

@interface ZYLoadingView ()

@property (nonatomic ,weak) CAReplicatorLayer *replicatorLayer;
@property (nonatomic ,weak) CALayer *dotLayer;

@end

@implementation ZYLoadingView

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kLoadingViewWidth, kLoadingViewWidth);
        self.backgroundColor = [UIColor clearColor];
        [self setupAnimatedLayers];
    }
    return self;
}

- (void)setupAnimatedLayers
{
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.bounds = CGRectMake(0, 0, kLoadingViewWidth, kLoadingViewWidth);
    replicatorLayer.cornerRadius = 8.0;
    replicatorLayer.position = self.center;
    replicatorLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
    [self.layer addSublayer:replicatorLayer];
    
    CALayer *dotLayer = [CALayer layer];
    dotLayer.bounds = CGRectMake(0, 0, 8, 8);
    dotLayer.position = CGPointMake(15, kLoadingViewWidth * 0.5);
    dotLayer.cornerRadius = 4.0;
    dotLayer.transform = CATransform3DMakeScale(0, 0, 0);
    dotLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    
    [replicatorLayer addSublayer:dotLayer];
    replicatorLayer.instanceCount = 10;
    replicatorLayer.instanceDelay = 0.1;
    replicatorLayer.instanceTransform = CATransform3DMakeRotation(2 * M_PI / 10, 0, 0, 1);
    
    self.dotLayer = dotLayer;
    self.replicatorLayer = replicatorLayer;
}

- (void)zy_addAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 1.0;
    animation.fromValue = @(1.0);
    animation.toValue = @(0);
    animation.repeatCount = HUGE;
    [self.dotLayer addAnimation:animation forKey:@"kDotLayerAnimation"];
}

- (void)zy_removeAnimation
{
    [self.dotLayer removeAnimationForKey:@"kDotLayerAnimation"];
}

+ (ZYLoadingView *)loadingView
{
    static ZYLoadingView *loadingView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadingView = [[ZYLoadingView alloc] init];
    });
    return loadingView;
}

#pragma mark - public

+ (void)showInView:(UIView *)parentView
{
    [[self loadingView] setCenter:parentView.center];
    [parentView addSubview:[self loadingView]];
    [[self loadingView] zy_addAnimation];
}

+ (void)dismiss
{
    if ([[self loadingView] superview]) {
        [[self loadingView] removeFromSuperview];
        [[self loadingView] zy_removeAnimation];
    }
}

@end
