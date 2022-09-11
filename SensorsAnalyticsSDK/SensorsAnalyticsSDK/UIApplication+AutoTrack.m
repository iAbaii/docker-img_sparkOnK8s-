//
//  UIApplication+AutoTrack.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 17/3/22.
//  Copyright (c) 2017年 SensorsData. All rights reserved.
//

#import "UIApplication+AutoTrack.h"
#import "SALogger.h"
#import "SensorsAnalyticsSDK.h"
#import "AutoTrackUtils.h"

@implementation UIApplication (AutoTrack)

- (BOOL)sa_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event {

    /*
     默认先执行 AutoTrack
     如果先执行原点击处理逻辑，可能已经发生页面 push 或者 pop，导致获取当前 ViewController 不正确
     可以通过 UIView 扩展属性 sensorsAnalyticsAutoTrackAfterSendAction，来配置 AutoTrack 是发生在原点击处理函数之前还是之后
     */

    BOOL ret = YES;
    BOOL sensorsAnalyticsAutoTrackAfterSendAction = NO;

    @try {
        if (from) {
            if ([from isKindOfClass:[UIView class]]) {
                UIView* view = (UIView *)from;
                if (view) {
                    if (view.sensorsAnalyticsAutoTrackAfterSendAction) {
                        sensorsAnalyticsAutoTrackAfterSendAction = YES;
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        SAError(@"%@ error: %@", self, exception);
        sensorsAnalyticsAutoTrackAfterSendAction = NO;
    }

    if (sensorsAnalyticsAutoTrackAfterSendAction) {
        ret = [self sa_sendAction:action to:to from:from forEvent:event];
    }

    @try {
        /*
         caojiangPreVerify:forEvent: & caojiangEventAction:forEvent: 是我们可视化埋点中的点击事件
         这个地方如果不过滤掉，会导致 swizzle 多次，从而会触发多次 $AppClick 事件
         caojiang 是我们 CTO 名字，我们相信这个前缀应该是唯一的
         如果这个前缀还会重复，请您告诉我，我把我们架构师的名字也加上
         */
        if (![@"caojiangPreVerify:forEvent:" isEqualToString:NSStringFromSelector(action)] &&
            ![@"caojiangEventAction:forEvent:" isEqualToString:NSStringFromSelector(action)]) {
            [self sa_track:action to:to from: