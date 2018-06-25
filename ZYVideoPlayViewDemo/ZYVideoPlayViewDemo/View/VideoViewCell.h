//
//  VideoViewCell.h
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;

@protocol VideoViewCellDelegate <NSObject>

- (void)videoDidPlayVideo:(VideoModel *)videoInfo indexPath:(NSIndexPath *)indexPath;

@end

@interface VideoViewCell : UICollectionViewCell

@property (nonatomic, weak) id<VideoViewCellDelegate> delegate;

- (void)stopPlay;
- (void)setupVideoInfo:(VideoModel *)videoInfo indexPath:(NSIndexPath *)indexPath;

@end
