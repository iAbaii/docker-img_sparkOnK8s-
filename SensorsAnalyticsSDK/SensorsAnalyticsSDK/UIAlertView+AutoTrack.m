
//
//  UIAlertView.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/6/13.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "UIAlertView+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#import "SASwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIAlertView (AutoTrack)

#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UIALERTVIEW

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @try {
//            NSError *error = NULL;
//            [[self class] sa_swizzleMethod:@selector(setDelegate:)
//                                withMethod:@selector(sa_alertViewSetDelegate:)
//                                     error:&error];
//            if (error) {
//                SAError(@"Failed to swizzle setDelegate: on UIAlertView. Details: %@", error);
//                error = NULL;
//            }
//        } @catch (NSException *exception) {
//            SAError(@"%@ error: %@", self, exception);
//        }
//    });
//}

void sa_alertViewClickedButtonAtIndex(id self, SEL _cmd, id alertView, NSInteger buttonIndex) {
    SEL selector = NSSelectorFromString(@"sa_alertViewClickedButtonAtIndex");
    ((void(*)(id, SEL, id, NSInteger))objc_msgSend)(self, selector, alertView, buttonIndex);
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
        
        if ([[SensorsAnalyticsSDK sharedInstance] isViewTypeIgnored:[UIAlertView class]]) {
            return;
        }
        
        if (!alertView) {
            return;
        }

        UIView *view = (UIView *)alertView;
        if (!view) {
            return;
        }
        
        if (view.sensorsAnalyticsIgnoreView) {
            return;
        }
        
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        [properties setValue:@"UIAlertView" forKey:@"$element_type"];
        
        //ViewID
        if (view.sensorsAnalyticsViewID != nil) {