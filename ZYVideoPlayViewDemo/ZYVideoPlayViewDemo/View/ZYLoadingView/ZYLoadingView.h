//
//  ZYLoadingView.h
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/10/11.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYLoadingView : UIView

+ (ZYLoadingView *)loadingView;

- (void)showInView:(UIView *)parentView;
- (void)dismiss;

@end
