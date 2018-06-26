//
//  ZYVideoPlayView.h
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/6/2.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZYPlayerActionAtItemEnd) {
    ZYPlayerActionAtItemEndPause	= 1,
    ZYPlayerActionAtItemEndNone		= 2,
};

@class AVPlayer;
@protocol ZYVideoPlayViewDelegate;

@interface ZYVideoPlayView : UIView

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) ZYPlayerActionAtItemEnd actionAtItemEnd;
@property (nonatomic, weak) id<ZYVideoPlayViewDelegate> delegate;

/** Default is 0.5s */
@property (nonatomic, assign) NSTimeInterval currentTimeUpdateDuration;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval cacheDuration;

@property (nonatomic, assign, readonly) CGSize videoSize;
@property (nonatomic, assign, readonly) BOOL isPlaying;

- (void)play;
- (void)pause;
- (void)replay;

- (void)releaseVideoPlayer;

- (void)seekToTime:(NSTimeInterval)time completion:(void (^)(BOOL success))completion;

+ (instancetype)videoPlayViewWithUrlString:(NSString *)urlStr;

@end

#pragma mark - ZYVideoPlayViewDelegate

@protocol ZYVideoPlayViewDelegate <NSObject>

@optional

- (void)zy_videoPlayViewReadyToPlay:(ZYVideoPlayView *)videoPlayView;
- (void)zy_videoPlayViewFailedToPlay:(ZYVideoPlayView *)videoPlayView;
- (void)zy_videoPlayViewDidFinishPlay:(ZYVideoPlayView *)videoPlayView;

//video playing buffer state
- (void)zy_videoPlayViewPlaybackBufferEmpty:(ZYVideoPlayView *)videoPlayView;
- (void)zy_videoPlayViewPlaybackLikelyToKeepUp:(ZYVideoPlayView *)videoPlayView;

/**
 @abstract delegate call this method every (currentTimeUpdateDuration) second
 
 @param currenttime : current paly time
 */
- (void)zy_videoPlayView:(ZYVideoPlayView *)videoPlayView didUpdateCurrentTime:(NSTimeInterval)currenttime;

/**
 @abstract delegate call this method when the cache duration changed
 */
- (void)zy_videoPlayView:(ZYVideoPlayView *)videoPlayView didUpdateCacheDuration:(NSTimeInterval)cacheDuration;

- (void)zy_videoPlayViewCurrentPlaybackRate:(float)rate;

@end
