//
//  UIButton+Touch.m
//  iOSComprehensiveDemo
//
//  Created by 谢立新 on 2019/11/27.
//  Copyright © 2019 谢立新. All rights reserved.
//

#import "UIButton+Touch.h"
#import <objc/runtime.h>
@interface UIButton ()

@property (nonatomic,assign) NSTimeInterval timingTimer;
@end
static char * const timingTimerKey = "timingTimerKey";
static char * const timerIntervalKey = "timerIntervalKey";

@implementation UIButton (Touch)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //处理事件的父类，它有三种事件相应的形式：基于触摸，基于值，基于编辑
        SEL selA = @selector(sendAction:to:forEvent:);
        Method thodA = class_getInstanceMethod(self, selA);
        //转换的方法(基于系统自己写的)
        SEL selB = @selector(mySendAction:to:forEvent:);
        Method thodB = class_getInstanceMethod(self, selB);
         //添加方法
        BOOL addB = class_addMethod(self, selA, method_getImplementation(thodB), method_getTypeEncoding(thodB));
        
        if (addB) {
            //如果方法已经添加,则替换
            class_replaceMethod(self, selB, method_getImplementation(thodA), method_getTypeEncoding(thodA));
        }else{
            //否则直接交换方法
            method_exchangeImplementations(thodA, thodB);
        }
    });
}
#pragma mark 点击按钮的间隔时间 set和 get 方法
-(void)setTimerInterval:(NSTimeInterval)timerInterval{
    /*
    &timerKey:该 key 也行可用@selector(timerIntervalKey)实现,就不用定义上面的属性key
    OBJC_ASSOCIATION_COPY 可以粗浅理解成定义属性的关键字
    */
    objc_setAssociatedObject(self, &timerIntervalKey, @(timerInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)timerInterval{
    return [objc_getAssociatedObject(self, &timerIntervalKey) doubleValue];
}
#pragma mark 点击按钮的计时 set和 get 方法
-(void)setTimingTimer:(NSTimeInterval)timingTimer{
    objc_setAssociatedObject(self, &timingTimerKey, @(timingTimer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)timingTimer{
    return [objc_getAssociatedObject(self, &timingTimerKey) doubleValue];
}


#pragma mark 防止暴力点击的方法
-(void)mySendAction:(SEL)action to:(id)target forEvent:(UIControlEvents *)event{
    //这个是判断是为了防止别的事件也走此方法
    if ([NSStringFromClass(self.class)isEqualToString:@"UIButton"]) {

        self.timerInterval = self.timerInterval == 0?defaultTimer:self.timerInterval;

        if (NSDate.date.timeIntervalSince1970 - self.timingTimer < self.timerInterval) {
               return;
           }
        if (self.timerInterval > 0) {
               self.timingTimer = NSDate.date.timeIntervalSince1970;
           }
    }
    [self mySendAction:action to:target forEvent:event];
}
@end
