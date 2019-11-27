//
//  UIButton+Touch.h
//  iOSComprehensiveDemo
//
//  Created by 谢立新 on 2019/11/27.
//  Copyright © 2019 谢立新. All rights reserved.
//


#import <UIKit/UIKit.h>
//默认点击间隔时间
#define defaultTimer .3

@interface UIButton (Touch)
//按钮间隔时间,如果不设置,则为默认时间0.3s
@property (nonatomic,assign) NSTimeInterval timer;

@end

