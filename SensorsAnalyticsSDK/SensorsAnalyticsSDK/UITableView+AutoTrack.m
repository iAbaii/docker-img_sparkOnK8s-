//
//
//  UITableView+SensorsAnalytics.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 17/3/22.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "UITableView+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#import "SASwizzle.h"
#import "AutoTrackUtils.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UITableView (AutoTrack)

#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UITABLEVIEW

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @try {
//            NSError *error = NULL;
//            [[self class] sa_swizzleMethod:@selector(setDelegate:)
//                                withMethod:@selector(sa_tableViewSetDelegate:)
//                                     error:&error];
//            if (error) {
//                SAError(@"Failed to swizzle setDelegate: on UITableView. Details: %@", error);
//                error = NULL;
//            }
//