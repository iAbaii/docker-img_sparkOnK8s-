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
            [self sa_track:action to:to from:from forEvent:event];
        }
    } @catch (NSException *exception) {
        SAError(@"%@ error: %@", self, exception);
    }

    if (!sensorsAnalyticsAutoTrackAfterSendAction) {
        ret = [self sa_sendAction:action to:to from:from forEvent:event];
    }

    return ret;
}

- (void)sa_track:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event {
    @try {
        //关闭 AutoTrack
        if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
            return;
        }
        
        //忽略 $AppClick 事件
        if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppClick]) {
            return;
        }
        
        // ViewType 被忽略
        if ([from isKindOfClass:[NSClassFromString(@"UITabBarButton") class]]) {
            if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[UITabBar class]]) {
                return;
            }
        } else if ([from isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[UIBarButtonItem class]]) {
                return;
            }
        } else if ([to isKindOfClass:[UISearchBar class]]) {
            if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[UISearchBar class]]) {
                return;
            }
        } else {
            if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[from class]]) {
                return;
            }
        }
        
        /*
         此处不处理 UITabBar，放到 UITabBar+AutoTrack.h 中处理
         */
        if (from != nil) {
            if ([from isKindOfClass:[UIBarButtonItem class]] ||
                [from isKindOfClass:[NSClassFromString(@"UITabBarButton") class]]) {
                return;
            }
        }
        
        if (([event isKindOfClass:[UIEvent class]] && event.type==UIEventTypeTouches) ||
            [from isKindOfClass:[UISwitch class]] ||
            [from isKindOfClass:[UIStepper class]] ||
            [from isKindOfClass:[UISegmentedControl class]]) {//0
            if (![from isKindOfClass:[UIView class]]) {
                return;
            }
            
            UIView* view = (UIView *)from;
            if (!view) {
                return;
            }
            
            if (view.sensorsAnalyticsIgnoreView) {
                return;
            }
            
            NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
            
            //ViewID
            if (view.sensorsAnalyticsViewID != nil) {
                [properties setValue:view.sensorsAnalyticsViewID forKey:@"$element_id"];
            }
            
            UIViewController *viewController = 