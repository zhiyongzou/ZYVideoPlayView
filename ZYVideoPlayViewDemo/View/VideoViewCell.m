//
//  VideoViewCell.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <Masonry.h>
#import "VideoModel.h"
#import "VideoViewCell.h"
#import "ZYLoadingView.h"
#import "ZYVideoPlayView.h"
#import "VideoPlayControlView.h"
#import <UIImageView+YYWebImage.h>

@interface VideoViewCell () <ZYVideoPlayViewDelegate, VideoPlayControlViewDelegate>

@property (nonatomic, strong) ZYVideoPlayView *videoPlayView;
@property (nonatomic, strong) UILabel *videoPlayNum;
@property (nonatomic, strong) UILabel *videoDuration;
@property (nonatomic, strong) UIImageView *videoCoverView;
@property (nonatomic, strong) VideoPlayControlView * videoPlayControlView;

@property (nonatomic, strong) UIView *bottomInfoView;
@property (nonatomic, strong) UIImageView *authorIcon;
@property (nonatomic, strong) UILabel *authorName;
@property (nonatomic, strong) UIButton *commentButton;

@end

@implementation VideoViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - setter/getter

- (void)setVideoInfo:(VideoModel *)videoInfo
{
    if (_videoInfo != videoInfo) {
        _videoInfo = videoInfo;
        self.videoPlayControlView.videoTitleLabel.text = videoInfo.video_title;
        self.videoPlayNum.text = videoInfo.video_playNum;
        self.videoDuration.text = videoInfo.video_duration;
        [self.videoCoverView yy_setImageWithURL:[NSURL URLWithString:videoInfo.video_cover]
                                    placeholder:nil];
        [self.authorIcon yy_setImageWithURL:[NSURL URLWithString:videoInfo.avatar_url] placeholder:nil];
        self.authorName.text = videoInfo.nick_name;
        [self.commentButton setTitle:[NSString stringWithFormat:@" %@", videoInfo.video_commentNum] forState:UIControlStateNormal];
    }
}

#pragma mark - action

- (void)onCommentButtonClicked
{
    
}

#pragma mark - VideoPlayControlViewDelegate

- (void)videoPlayControlViewDidPlayVideo:(BOOL)isPlay
{
//    self.videoPlayControlView.hidden = YES;
    if (!self.videoPlayView.videoURL) {
        [ZYLoadingView showInView:self.videoCoverView];
        [self.videoPlayView setVideoURL:[NSURL URLWithString:self.videoInfo.video_url]];
        self.videoPlayNum.hidden = YES;
        self.videoDuration.hidden = YES;
    } else {
        if (isPlay) {
            [self.videoPlayView play];
        } else {
            [self.videoPlayView pause];
        }
    }
}

#pragma mark - VideoPlayViewDelegate

- (void)zy_videoPlayViewReadyToPlay:(ZYVideoPlayView *)videoPlayView
{
    [ZYLoadingView dismiss];
    [self.videoPlayControlView setDuration:videoPlayView.duration];
    self.videoCoverView.hidden = YES;
    [videoPlayView play];
}

- (void)zy_videoPlayViewFailedToPlay:(ZYVideoPlayView *)videoPlayView
{
    
}

- (void)zy_videoPlayViewDidFinishPlay:(ZYVideoPlayView *)videoPlayView
{
    
}

- (void)zy_videoPlayViewPlaybackBufferEmpty:(ZYVideoPlayView *)videoPlayView
{
    
}

- (void)zy_videoPlayViewPlaybackLikelyToKeepUp:(ZYVideoPlayView *)videoPlayView
{
    
}

- (void)zy_videoPlayView:(ZYVideoPlayView *)videoPlayView didUpdateCurrentTime:(NSTimeInterval)currenttime
{
    [self.videoPlayControlView updateVideoCurrentPlayTime:currenttime];
}

- (void)zy_videoPlayView:(ZYVideoPlayView *)videoPlayView didUpdateCacheDuration:(NSTimeInterval)cacheDuration
{
    
}

#pragma mark - private

- (void)setupSubviews
{
    self.videoPlayView = [[ZYVideoPlayView alloc] init];
    self.videoPlayView.delegate = self;
    [self.contentView addSubview:self.videoPlayView];
    [self.videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
    
    self.videoCoverView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.videoCoverView];
    [self.videoCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(self.videoPlayView);
    }];
    
    self.videoPlayControlView = [[VideoPlayControlView alloc] init];
    self.videoPlayControlView.delegate = self;
    [self.contentView addSubview:self.videoPlayControlView];
    [self.videoPlayControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(self.videoPlayView);
    }];
    
    self.videoPlayNum = [[UILabel alloc] init];
    self.videoPlayNum.textColor = [UIColor whiteColor];
    self.videoPlayNum.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.videoPlayNum];
    [self.videoPlayNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoPlayView).offset(10);
        make.bottom.equalTo(self.videoPlayView).offset(-10);
    }];
    
    self.videoDuration = [[UILabel alloc] init];
    self.videoDuration.textColor = [UIColor whiteColor];
    self.videoDuration.textAlignment = NSTextAlignmentRight;
    self.videoDuration.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.videoDuration];
    [self.videoDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.videoPlayView).offset(-10);
    }];
    
    self.bottomInfoView = [[UIView alloc] init];
    [self .contentView addSubview:self.bottomInfoView];
    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    CGFloat icon_h = 24;
    self.authorIcon = [[UIImageView alloc] init];
    self.authorIcon.layer.cornerRadius = icon_h * 0.5;
    self.authorIcon.layer.masksToBounds = YES;
    [self.bottomInfoView addSubview:self.authorIcon];
    [self.authorIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(icon_h);
        make.centerY.equalTo(self.bottomInfoView);
        make.left.equalTo(self.bottomInfoView).offset(10);
    }];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.commentButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(onCommentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setImage:[UIImage imageNamed:@"video_comment"] forState:UIControlStateNormal];
    [self.bottomInfoView addSubview:self.commentButton];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomInfoView);
        make.right.equalTo(self.bottomInfoView).offset(-10);
    }];
    
    self.authorName = [[UILabel alloc] init];
    self.authorName.textColor = [UIColor blackColor];
    self.authorName.font = [UIFont systemFontOfSize:12];
    [self.bottomInfoView addSubview:self.authorName];
    [self.authorName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomInfoView);
        make.left.equalTo(self.authorIcon.mas_right).offset(5);
        make.right.equalTo(self.commentButton.mas_left).offset(-5);
    }];
}

@end