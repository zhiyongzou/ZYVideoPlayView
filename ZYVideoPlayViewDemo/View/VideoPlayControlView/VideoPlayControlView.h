//
//  VideoPlayControlView.h
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoPlayControlViewDelegate;

@interface VideoPlayControlView : UIView

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) UILabel *videoTitleLabel;
@property (nonatomic, weak) id<VideoPlayControlViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isSeeking;

- (void)updateVideoCurrentPlayTime:(NSTimeInterval)currentTime;
- (void)updateVideoPlayState:(BOOL)isPlay;

@end

#pragma mark - VideoPlayControlViewDelegate

@protocol VideoPlayControlViewDelegate <NSObject>

@optional

- (void)videoPlayControlViewWillBeginSeeking:(VideoPlayControlView *)aView;
- (void)videoPlayControlViewDidSeeking:(VideoPlayControlView *)aView;
- (void)videoPlayControlViewDidEndSeeking:(VideoPlayControlView *)aView seekTime:(NSTimeInterval)seekTime;

- (void)videoPlayControlViewDidPlayVideo:(BOOL)isPlay;

@optional

@end
