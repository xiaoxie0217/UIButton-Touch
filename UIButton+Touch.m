//
//  UIButton+Touch.m
//  iOSComprehensiveDemo
//
//  Created by 谢立新 on 2019/11/27.
//  Copyright © 2019 谢立新. All rights reserved.
//

#import "UIButton+Touch.h"
#import <objc/runtime.h>
//私有方法定义按钮是否允许点击的
@interface UIButton ()
//在间隔的时间内 isClick为 YES,不允许点击
@property (nonatomic,assign) BOOL isClick;

@end
//保证全局唯一的 key,区分定义的属性(runtime 方法使用)
static char *const timerKey = "timerKey";
static char *const isClickKey = "isClickKey";

@implementation UIButton (Touch)
//load 和 init 的区别,以及加载时间等,请自行百度
+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获取系统点击的实例方法
        SEL selA = @selector(sendAction:to:forEvent:);
        Method thodA = class_getInstanceMethod(self, selA);
        //获取自己写的点击实例方法
        SEL selB = @selector(mySendAction:to:forEvent:);
        Method thodB = class_getInstanceMethod(self, selB);
        //添加方法
        BOOL addThod = class_addMethod(self, selA, method_getImplementation(thodB), method_getTypeEncoding(thodB));
        
        if (addThod) {
            //如果方法已经添加,则替换
            class_replaceMethod(self, selB, method_getImplementation(thodA), method_getTypeEncoding(thodA));
        }else{
            //否则直接交换方法
            method_exchangeImplementations(thodA, thodB);
        }
    });
}
//timer 的 set方法
-(void)setTimer:(NSTimeInterval)timer{
/*
 &timerKey:该 key 也行可用@selector(timer)实现,就不用定义上面的属性key
 OBJC_ASSOCIATION_COPY 可以粗浅理解成定义属性的关键字
 */
    objc_setAssociatedObject(self, &timerKey, @(timer), OBJC_ASSOCIATION_COPY);
}
//timer 的 get 方法
-(NSTimeInterval)timer{
    return [objc_getAssociatedObject(self, &timerKey) doubleValue];
}
//isClick的 set方法
-(void)setIsClick:(BOOL)isClick{
    objc_setAssociatedObject(self, &isClickKey, @(isClick), OBJC_ASSOCIATION_COPY);
}
//isClick的 get方法
-(BOOL)isClick{
    return [objc_getAssociatedObject(self, &isClickKey) boolValue];
}

//自己写的点击方法
-(void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    //判断的那个点击的控件为 UIButton 的时候才执行该方法
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
        //如果时间没有规定,则用三目运算法赋初始值给 timer
        self.timer = self.timer == 0?defaultTimer:self.timer;
        //如果isClick为 YES 则为间隔时间,不执行方法
        if (self.isClick) return;
        
        if (self.timer >0) {
            
            self.isClick = YES;
            //倒计时
            [self performSelector:@selector(setIsClick:) withObject:@(NO) afterDelay:self.timer];
        }
    }
    [self mySendAction:action to:target forEvent:event];
}

@end
