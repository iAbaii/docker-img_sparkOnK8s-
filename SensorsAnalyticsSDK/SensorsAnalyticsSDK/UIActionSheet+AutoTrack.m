//
//  UIActionSheet.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/6/13.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "UIActionSheet+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#import "SASwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIActionSheet (AutoTrack)

#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UIACTIONSHEET

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @try {
//            NSError *error = NULL;
//            [[self class] sa_swizzleMethod:@selector(setDelegate:)
//                                withMethod:@selector(sa_sheetViewSetDelegate:)
//                                     error:&error];
//            if (error) {
//                SAError(@"Failed to swizzle setDelegate: on UIActionSheet. Details: %@", error);
//                error = NULL;
//            }
//        } @catch (NSException *exception) {
//            