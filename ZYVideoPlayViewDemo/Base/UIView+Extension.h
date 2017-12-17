//
//  UIView+Extension.h
//  iOS_Extensions
//
//  Created by zouzhiyong on 2017/12/7.
//  Copyright © 2017年 zouzhiyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGSize size;

- (void)removeAllSubViews;

@end
