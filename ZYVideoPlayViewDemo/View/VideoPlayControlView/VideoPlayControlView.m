//
//  VideoPlayControlView.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import "UIView+Extension.h"
#import "VideoPlayControlView.h"

@interface VideoPlayControlView ()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) UILabel *currentPlayTime;
@property (nonatomic, strong) UISlider *seekSlider;
@property (nonatomic, strong) UILabel *videoDuretion;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, assign) CGPoint beginLocation;
@property (nonatomic, assign) CGFloat moveMargin;
@property (nonatomic, assign) CGFloat beginSliderValue;
@property (nonatomic, assign) BOOL isfirstTimePlay;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) CAGradientLayer *topGradientLayer;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;

@end

@implementation VideoPlayControlView

#pragma mark - override

- (instancetype)init
{
    if (self = [super init]) {
        [self setupBackgroundGradientLayer];
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playButton.frame = CGRectMake(0, 0, 50, 50);
    self.playButton.center = self.center;
    self.bottomContentView.frame = CGRectMake(10, CGRectGetHeight(self.bounds) - 30, CGRectGetWidth(self.bounds) - 20, 30);
    
    CGFloat layer_h = 60;
    self.topGradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), layer_h);
    self.bottomGradientLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - layer_h, CGRectGetWidth(self.bounds), layer_h);
    
    if (self.bottomContentView) {
        CGSize timeTextSize = [self.currentPlayTime.text sizeWithAttributes:@{NSFontAttributeName : self.currentPlayTime.font}];
        CGFloat currentPlayTime_w = timeTextSize.width + 5;
        self.currentPlayTime.frame = CGRectMake(0, 0, currentPlayTime_w, CGRectGetHeight(self.bottomContentView.bounds));
        self.videoDuretion.frame = CGRectMake(CGRectGetWidth(self.bottomContentView.bounds) - currentPlayTime_w, 0, currentPlayTime_w, CGRectGetHeight(self.bottomContentView.bounds));
        CGFloat seekSlider_x = CGRectGetMaxX(self.currentPlayTime.frame) + 5;
        CGFloat seekSlider_w = CGRectGetWidth(self.bottomContentView.bounds) - 2 * currentPlayTime_w - 10;
        self.seekSlider.frame = CGRectMake(seekSlider_x, 0, seekSlider_w, CGRectGetHeight(self.bottomContentView.bounds));
    }
    
    self.progressView.frame = CGRectMake(0, self.height - 2, self.width, 2);
}

#pragma mark - setter/getter

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    [self setupBottomContentView];
    self.currentPlayTime.text = (int)duration / (60 * 60) > 0 ? @"00:00:00" : @"00:00";
    self.seekSlider.maximumValue = duration;
    self.videoDuretion.text = [self formattedStringWithDuration:duration];
    self.bottomContentView.hidden = self.playButton.hidden;
    
    [self setNeedsLayout];
}

#pragma mark - action

- (void)onPlayButtonClicked:(UIButton *)playButton
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenSubViews) object:nil];
    
    self.isPlaying = !self.isPlaying;
    
    [playButton setImage:[self playButtonImageWithPlaying:self.isPlaying]
                forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(videoPlayControlViewDidPlayVideo:)]) {
        [self.delegate videoPlayControlViewDidPlayVideo:self.isPlaying];
    }
    
    if (self.isPlaying) {
        [self performSelector:@selector(hiddenSubViews) withObject:nil afterDelay:3];
    }

    if (!self.isfirstTimePlay) {
        [self hiddenSubViews];
        self.isfirstTimePlay = YES;
        return;
    }
}

- (void)onseekSliderPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.beginSliderValue = self.seekSlider.value;
            self.beginLocation = [panGestureRecognizer locationInView:self];
            _isSeeking = YES;
            if ([self.delegate respondsToSelector:@selector(videoPlayControlViewWillBeginSeeking:)]) {
                [self.delegate videoPlayControlViewWillBeginSeeking:self];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            
            self.moveMargin = ([panGestureRecognizer locationInView:self].x - self.beginLocation.x);
            CGFloat realValue = self.beginSliderValue + (self.duration * self.moveMargin / CGRectGetWidth(self.seekSlider.frame));
            
            realValue = (int)MIN(self.duration, MAX(realValue, 0));
            [self.seekSlider setValue:realValue animated:YES];
            
            self.currentPlayTime.text = [self formattedStringWithDuration:realValue];
            if ([self.delegate respondsToSelector:@selector(videoPlayControlViewDidSeeking:)]) {
                [self.delegate videoPlayControlViewDidSeeking:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            _isSeeking = NO;
            if ([self.delegate respondsToSelector:@selector(videoPlayControlViewDidEndSeeking:seekTime:)]) {
                [self.delegate videoPlayControlViewDidEndSeeking:self seekTime:self.seekSlider.value];
            }
            [self hiddenSubViews];
        }
            break;
            
        default:{
            _isSeeking = NO;
        }
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenSubViews) object:nil];
    
    if (!self.isfirstTimePlay) {
        [self onPlayButtonClicked:self.playButton];
        return;
    }
    
    if (self.playButton.hidden) {
        [self showSubViews];
    } else {
        [self hiddenSubViews];
    }
    
    if (self.isPlaying) {
        [self performSelector:@selector(hiddenSubViews) withObject:nil afterDelay:3];
    }
}

#pragma mark - help

- (NSString *)formattedStringWithDuration:(int)duration
{
    int hour = duration/(60*60);
    int minutes = (duration%(60*60))/60;
    int seconds = (duration%60);
    
    NSString *hourString = hour > 0 ? [NSString stringWithFormat:@"%02d:", hour] : @"";
    NSString *minutesString = [NSString stringWithFormat:@"%02d:", minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%02d", seconds];
    
    return [NSString stringWithFormat:@"%@%@%@", hourString, minutesString, secondsString];
}

- (int)secondsFromDurationString:(NSString *)durationString
{
    NSArray *components = [durationString componentsSeparatedByString:@":"];
    NSEnumerator *revert = [components reverseObjectEnumerator];
    int seconds = 0;
    int i = 0;
    for (NSString *string in revert) {
        seconds += [string intValue] * pow(60, i);
        i++;
    }
    
    return seconds;
}

#pragma mark - private

- (UIImage *)playButtonImageWithPlaying:(BOOL)isPlaying
{
    NSString *imageName = isPlaying ? @"video_pause_button" : @"video_play_button";
    return [UIImage imageNamed:imageName];
}

- (void)setupBackgroundGradientLayer
{
    CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
    topGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.2 alpha:0.7].CGColor,
                                                        (id)[UIColor colorWithWhite:0.2 alpha:0.5].CGColor,
                                                        (id)[UIColor clearColor].CGColor, nil];
    [self.layer addSublayer:topGradientLayer];
    self.topGradientLayer = topGradientLayer;
    
    CAGradientLayer *bottomGradientLayer = [CAGradientLayer layer];
    bottomGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,
                                                           (id)[UIColor colorWithWhite:0.2 alpha:0.5],
                                                           (id)[UIColor colorWithWhite:0.2 alpha:0.7].CGColor, nil];
    [self.layer addSublayer:bottomGradientLayer];
    self.bottomGradientLayer = bottomGradientLayer;
}

- (void)setupSubviews
{
    self.videoTitleLabel = [[UILabel alloc] init];
    self.videoTitleLabel.numberOfLines = 2;
    self.videoTitleLabel.textColor = [UIColor whiteColor];
    self.videoTitleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.videoTitleLabel];
    self.videoTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.videoTitleLabel
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:10];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.videoTitleLabel
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:-10];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.videoTitleLabel
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:10];
    [self addConstraints:@[topConstraint,leftConstraint,rightConstraint]];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.selected = NO;
    [self.playButton addTarget:self action:@selector(onPlayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setImage:[UIImage imageNamed:@"video_play_button"] forState:UIControlStateNormal];
    [self addSubview:self.playButton];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progress = 0;
    self.progressView.progressTintColor = [UIColor orangeColor];
    [self addSubview:self.progressView];
}

- (void)setupBottomContentView
{
    if (!self.bottomContentView) {
        
        self.bottomContentView = [[UIView alloc] init];
        [self addSubview:self.bottomContentView];
        
        self.currentPlayTime = [[UILabel alloc] init];
        self.currentPlayTime.textColor = [UIColor whiteColor];
        self.currentPlayTime.font = [UIFont systemFontOfSize:12];
        self.currentPlayTime.textAlignment = NSTextAlignmentCenter;
        [self.bottomContentView addSubview:self.currentPlayTime];
        
        self.seekSlider = [[UISlider alloc] init];
        self.seekSlider.value = 0;
        [self.seekSlider setTintColor:[UIColor orangeColor]];
        [self.seekSlider setThumbImage:[UIImage imageNamed:@"blank"] forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
        [self.bottomContentView addSubview:self.seekSlider];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onseekSliderPan:)];
        pan.maximumNumberOfTouches = 1;
        [self.seekSlider addGestureRecognizer:pan];
        
        self.videoDuretion = [[UILabel alloc] init];
        self.videoDuretion.textAlignment = NSTextAlignmentCenter;
        self.videoDuretion.textColor = [UIColor whiteColor];
        self.videoDuretion.font = [UIFont systemFontOfSize:12];
        [self.bottomContentView addSubview:self.videoDuretion];
    }
}

- (void)hiddenSubViews
{
    self.playButton.hidden = YES;
    self.bottomContentView.hidden = YES;
    self.videoTitleLabel.hidden = YES;
    self.progressView.hidden = NO;
}

- (void)showSubViews
{
    self.playButton.hidden = NO;
    self.bottomContentView.hidden = NO;
    self.videoTitleLabel.hidden = NO;
    self.progressView.hidden = YES;
}

#pragma mark - public

- (void)updateVideoCurrentPlayTime:(NSTimeInterval)currentTime
{
    if (!self.isSeeking) {
        self.currentPlayTime.text = [self formattedStringWithDuration:currentTime];
        [self.seekSlider setValue:currentTime animated:YES];
        if (!self.progressView.hidden) {
            self.progressView.progress = currentTime/self.duration;
        }
    }
    
    if (!self.isPlaying) {
        self.isPlaying = YES;
    }
}

- (void)updateVideoPlayState:(BOOL)isPlay
{
    [self.playButton setImage:[self playButtonImageWithPlaying:isPlay] forState:UIControlStateNormal];
}

@end
