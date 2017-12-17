//
//  ZYVideoPlayView.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/6/2.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import "ZYVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const ZYPlayerItemStatusKey = @"status";
static NSString * const ZYPlayerItemLoadedTimeRangesKey = @"loadedTimeRanges";
static NSString * const ZYPlayerItemPlaybackBufferEmptyKey = @"playbackBufferEmpty";
static NSString * const ZYPlayerItemPlaybackLikelyToKeepUpKey = @"playbackLikelyToKeepUp";
static NSString * const ZYPlayerRateKey = @"rate";

@interface ZYVideoPlayView ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) CMTime chaseTime;
@property (nonatomic, assign) BOOL isSeekInProgress;
@property (nonatomic, assign) BOOL resumeAfterEnterForground;
@property (nonatomic, assign) BOOL enterBackground;

@end

@implementation ZYVideoPlayView

#pragma mark - Override

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupPlayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupPlayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseVideoPlayer];
}

#pragma mark - Setter/Getter

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    if (videoURL) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *requestedKeys = @[@"playable"];
        
        __weak typeof(self) weakSelf = self;
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler: ^{
            dispatch_async( dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf && [strongSelf.videoURL isEqual:videoURL]) {
                    [strongSelf prepareToPlayAsset:asset withKeys:requestedKeys];
                }
            });
        }];
    }
}

- (void)setPlayer:(AVPlayer *)player
{
    if (_player != player) {
        
        [self removePlayerTimeObserver];
        [self removeObserversFromPlayer];
        
        if (player && !player.currentItem) {
            [self removeObserversFromPlayerItem];
            self.playerItem = nil;
            _player = nil;
            [self.playerLayer setPlayer:nil];
            [self setVideoURL:self.videoURL];
        } else {
            _player = player;
            [self.playerLayer setPlayer:player];
            
            if (self.playerItem != player.currentItem && player) {
                [self removeObserversFromPlayerItem];
                self.playerItem = player.currentItem;
                [self addObserversToPlayerItem];
            }
            
            [self addPlayerTimeObserver];
            [self addObserversToPlayer];
        }
    }
}

- (NSTimeInterval)currentTime
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds(self.playerItem.currentTime);
    }
    
    return 0;
}

- (NSTimeInterval)currentTimeUpdateDuration
{
    return _currentTimeUpdateDuration ?: 0.5;
}

- (CGSize)videoSize
{
    return self.playerItem.presentationSize;
}

- (BOOL)isPlaying
{
    return [self.player rate] != 0.f;
}

- (NSTimeInterval)duration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTIME_IS_VALID([[self.player currentItem] duration]) ? CMTimeGetSeconds([[self.player currentItem] duration]) : 0;
    }
    
    return 0;
}

#pragma mark - Observers

- (void)addObserversToPlayer
{
    if (self.player) {
        [self.player addObserver:self
                      forKeyPath:ZYPlayerRateKey
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
}

- (void)removeObserversFromPlayer
{
    if (self.player) {
        [self.player removeObserver:self forKeyPath:ZYPlayerRateKey];
    }
}

- (void)addObserversToPlayerItem
{
    [self.playerItem addObserver:self
                      forKeyPath:ZYPlayerItemStatusKey
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:ZYPlayerItemLoadedTimeRangesKey
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:ZYPlayerItemPlaybackBufferEmptyKey
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:ZYPlayerItemPlaybackLikelyToKeepUpKey
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

- (void)removeObserversFromPlayerItem
{
    [self.playerItem removeObserver:self
                         forKeyPath:ZYPlayerItemStatusKey
                            context:nil];
    [self.playerItem removeObserver:self
                         forKeyPath:ZYPlayerItemLoadedTimeRangesKey
                            context:nil];
    
    [self.playerItem removeObserver:self forKeyPath:ZYPlayerItemPlaybackBufferEmptyKey];
    [self.playerItem removeObserver:self forKeyPath:ZYPlayerItemPlaybackLikelyToKeepUpKey];
}

- (void)addPlayerTimeObserver
{
    if (self.player) {
        
        [self removePlayerTimeObserver];
        
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1/self.currentTimeUpdateDuration) queue:NULL usingBlock:^(CMTime time) {
            if ([weakSelf.delegate respondsToSelector:@selector(zy_videoPlayView:didUpdateCurrentTime:)]) {
                [weakSelf.delegate zy_videoPlayView:weakSelf didUpdateCurrentTime:CMTimeGetSeconds(time)];
            }
        }];
    }
}

- (void)removePlayerTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - Seek

- (void)stopPlayingAndSeekSmoothlyToTime:(CMTime)newChaseTime completion:(void (^)())completion
{
    [self.player pause];
    
    if (CMTIME_COMPARE_INLINE(newChaseTime, !=, self.chaseTime)) {
        self.chaseTime = newChaseTime;
        
        if (!self.isSeekInProgress) {
            [self trySeekToChaseTimeCompletion:completion];
        }
    }
}

- (void)trySeekToChaseTimeCompletion:(void (^)())completion
{
    if (self.player.status == AVPlayerItemStatusUnknown) {
        // wait until item becomes ready
        if (completion) {
            completion();
        }
    } else if (self.player.status == AVPlayerItemStatusReadyToPlay) {
        [self actuallySeekToTimeCompletion:completion];
    }
}

- (void)actuallySeekToTimeCompletion:(void (^)())completion
{
    self.isSeekInProgress = YES;
    CMTime seekTimeInProgress = self.chaseTime;
    [self.player seekToTime:seekTimeInProgress
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero
          completionHandler: ^(BOOL isFinished) {
              
         if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, self.chaseTime)) {
             self.isSeekInProgress = NO;
             self.chaseTime = kCMTimeInvalid;
             if (completion) {
                 completion();
             }
         } else {
             [self trySeekToChaseTimeCompletion:completion];
         }
     }];
}

#pragma mark - Private

- (void)setupPlayer
{
    self.actionAtItemEnd = ZYPlayerActionAtItemEndPause;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
    [self addNotifications];
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    for (NSString *thisKey in requestedKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            [self assetFailedToPrepareForPlayback:error];
            return;
        } else if (keyStatus == AVKeyValueStatusCancelled) {
            //-[AVAsset cancelLoading]
        }
    }
    
    if (!asset.playable) {
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    //Remove existing player item key value observers and notifications
    if (self.playerItem) {
        [self removeObserversFromPlayerItem];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self addObserversToPlayerItem];
    
    if (!self.player) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        _player.actionAtItemEnd = (AVPlayerActionAtItemEnd)self.actionAtItemEnd;
        [self.playerLayer setPlayer:self.player];
        [self.player seekToTime:kCMTimeZero
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimeZero
              completionHandler:^(BOOL finished) {}];
        [self addObserversToPlayer];
    }
    
    if (self.player.currentItem != self.playerItem) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    if ([self.delegate respondsToSelector:@selector(zy_videoPlayViewFailedToPlay:)]) {
        [self.delegate zy_videoPlayViewFailedToPlay:self];
    }
}

#pragma mark - Notifications

- (void)addNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onPlayerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [center addObserver:self selector:@selector(onAppDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(onAppDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onPlayerItemDidReachEnd:(NSNotification *)notification
{
    if (notification.object == self.playerItem) {
        if ([self.delegate respondsToSelector:@selector(zy_videoPlayViewDidFinishPlay:)]) {
            [self.delegate zy_videoPlayViewDidFinishPlay:self];
        }
    }
}

- (void)onAppDidEnterBackground:(NSNotification *)notification
{
    self.enterBackground = YES;
    
    if ([self isPlaying]) {
        [self pause];
        self.resumeAfterEnterForground = YES;
    }
}

- (void)onAppDidEnterForeground:(NSNotification *)notification
{
    self.enterBackground = NO;

    if (self.resumeAfterEnterForground) {
        self.resumeAfterEnterForground = NO;
        [self play];
    }
}

#pragma mark - AVPlayerItem KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:ZYPlayerItemStatusKey]) {
        [self handleVideoStatus];
    } else if ([keyPath isEqualToString:ZYPlayerItemLoadedTimeRangesKey]) {
        [self handleVideoLoadedTimeRangesChange];
    } else if ([keyPath isEqualToString:ZYPlayerItemPlaybackBufferEmptyKey]) {
        [self handleBufferEmpty];
    } else if ([keyPath isEqualToString:ZYPlayerItemPlaybackLikelyToKeepUpKey]) {
        [self handlePlaybackLikelyToKeepUp];
    } else if ([keyPath isEqualToString:ZYPlayerRateKey]) {
        [self handlePlaybackRate:[[change valueForKey:NSKeyValueChangeNewKey] floatValue]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handleVideoLoadedTimeRangesChange
{
    if ([self.delegate respondsToSelector:@selector(zy_videoPlayView:didUpdateCacheDuration:)]) {
        
        NSArray * loadedTimeRanges = self.playerItem.loadedTimeRanges;
        if (!loadedTimeRanges.count) {
            return;
        }
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        double startSeconds = CMTimeGetSeconds(timeRange.start);
        double durationSeconds = CMTimeGetSeconds(timeRange.duration);
        _cacheDuration = startSeconds + durationSeconds;
        
        [self.delegate zy_videoPlayView:self didUpdateCacheDuration:self.cacheDuration];
    }
}

- (void)handleVideoStatus
{
    switch (self.player.status) {
        case AVPlayerStatusUnknown: {
            [self removePlayerTimeObserver];
        }
            break;
        case AVPlayerStatusReadyToPlay: {
            if (!self.enterBackground) {
                if ([self.delegate respondsToSelector:@selector(zy_videoPlayViewReadyToPlay:)]) {
                    [self.delegate zy_videoPlayViewReadyToPlay:self];
                }
            }
            
            [self addPlayerTimeObserver];
        }
            break;
        case AVPlayerStatusFailed: {
            if ([self.delegate respondsToSelector:@selector(zy_videoPlayViewFailedToPlay:)]) {
                [self.delegate zy_videoPlayViewFailedToPlay:self];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)handleBufferEmpty
{
    if ([self.playerItem isPlaybackBufferEmpty] && [self.delegate respondsToSelector:@selector(zy_videoPlayViewPlaybackBufferEmpty:)]) {
        [self.delegate zy_videoPlayViewPlaybackBufferEmpty:self];
    }
}

- (void)handlePlaybackLikelyToKeepUp
{
    if ([self.playerItem isPlaybackLikelyToKeepUp] && [self.delegate respondsToSelector:@selector(zy_videoPlayViewPlaybackLikelyToKeepUp:)]) {
        [self.delegate zy_videoPlayViewPlaybackLikelyToKeepUp:self];
    }
}

- (void)handlePlaybackRate:(float)rate
{
    if ([self.delegate respondsToSelector:@selector(zy_videoPlayViewCurrentPlaybackRate:)]) {
        [self.delegate zy_videoPlayViewCurrentPlaybackRate:rate];
    }
}

#pragma mark - Public

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)replay
{
    [self pause];
    [self.player seekToTime:kCMTimeZero
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero
          completionHandler:^(BOOL finished) {}];
    [self play];
}

- (void)seekToTime:(NSTimeInterval)time completion:(void (^)())completion
{
    [self stopPlayingAndSeekSmoothlyToTime:CMTimeMakeWithSeconds(time, 1) completion:completion];
}

- (void)releaseVideoPlayer
{
    [self removeObserversFromPlayerItem];
    [self removePlayerTimeObserver];
    [self removeObserversFromPlayer];
    
    [self pause];
    [self.playerItem.asset cancelLoading];
    [self.playerItem cancelPendingSeeks];
    
    _player = nil;
    self.playerItem = nil;
    [self.playerLayer setPlayer:nil];
    self.videoURL = nil;
    self.enterBackground = NO;
}

+ (instancetype)videoPlayViewWithUrlString:(NSString *)urlStr
{
    ZYVideoPlayView *playView = [[self alloc] init];
    playView.videoURL = [NSURL URLWithString:urlStr];
    return playView;
}


@end
