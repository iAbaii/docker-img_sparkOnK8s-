
//
//  TabBar.m
//  daHePai
//
//  Created by 王灼洲 on 2017/6/21.
//  Copyright © 2017年 DHP. All rights reserved.
//

#import "UITabBar+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#import "SASwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UITabBar (AutoTrack)

#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UITABBAR

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            NSError *error = NULL;
            [[self class] sa_swizzleMethod:@selector(setDelegate:)
                                withMethod:@selector(sa_uiTabBarSetDelegate:)
                                     error:&error];
            if (error) {
                SAError(@"Failed to swizzle setDelegate: on UITabBar. Details: %@", error);
                error = NULL;
            }
        } @catch (NSException *exception) {
            SAError(@"%@ error: %@", self, exception);
        }
    });
}

void sa_uiTabBarDidSelectRowAtIndexPath(id self, SEL _cmd, id tabBar, UITabBarItem* item) {
    SEL selector = NSSelectorFromString(@"sa_uiTabBarDidSelectRowAtIndexPath");
    ((void(*)(id, SEL, id, id))objc_msgSend)(self, selector, tabBar, item);
    
    //插入埋点
    @try {
        //关闭 AutoTrack
        if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
            return;
        }
        
        //忽略 $AppClick 事件
        if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppClick]) {
            return;
        }
        
        if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[UITabBar class]]) {
            return;
        }
        
        if (!tabBar) {
            return;