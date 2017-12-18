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

@property (nonatomic ,weak) CALayer *dotLayer;

@end

@implementation ZYLoadingView

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kLoadingViewWidth, kLoadingViewWidth);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.layer.cornerRadius = 8.0;
        [self setupAnimatedLayers];
    }
    return self;
}

+ (Class)layerClass
{
    return [CAReplicatorLayer class];
}

- (void)setupAnimatedLayers
{
    CALayer *dotLayer = [CALayer layer];
    dotLayer.bounds = CGRectMake(0, 0, 8, 8);
    dotLayer.position = CGPointMake(15, kLoadingViewWidth * 0.5);
    dotLayer.cornerRadius = 4.0;
    dotLayer.transform = CATransform3DMakeScale(0, 0, 0);
    dotLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    
    [self.layer addSublayer:dotLayer];
    [(CAReplicatorLayer *)self.layer setInstanceCount:10];
    [(CAReplicatorLayer *)self.layer setInstanceDelay:0.1];
    [(CAReplicatorLayer *)self.layer setInstanceTransform:CATransform3DMakeRotation(2 * M_PI / 10, 0, 0, 1)];
    
    self.dotLayer = dotLayer;
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
    return [[self alloc] init];
}

#pragma mark - public

- (void)showInView:(UIView *)parentView
{
    [self setCenter:parentView.center];
    [parentView addSubview:self];
    [self zy_addAnimation];
}

- (void)dismiss
{
    if ([self superview]) {
        [self removeFromSuperview];
        [self zy_removeAnimation];
    }
}

@end
