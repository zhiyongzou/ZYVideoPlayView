//
//  VideoModel.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

+ (instancetype)videoModelWithDictionary:(NSDictionary *)videoDic
{
    VideoModel *videoModel = [[self alloc] init];
    [videoModel setValuesForKeysWithDictionary:videoDic];
    return videoModel;
}

@end
