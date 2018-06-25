//
//  VideoModel.h
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property (nonatomic, strong) NSString *avatar_url;
@property (nonatomic, strong) NSString *nick_name;
@property (nonatomic, strong) NSString *video_commentNum;
@property (nonatomic, strong) NSString *video_cover;
@property (nonatomic, strong) NSString *video_duration;
@property (nonatomic, strong) NSString *video_playNum;
@property (nonatomic, strong) NSString *video_title;
@property (nonatomic, strong) NSString *video_url;

+ (instancetype)videoModelWithDictionary:(NSDictionary *)videoDic;

@end
