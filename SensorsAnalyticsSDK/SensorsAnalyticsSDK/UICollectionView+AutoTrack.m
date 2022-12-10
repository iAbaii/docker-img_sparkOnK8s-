//
//  UICollectionView+SensorsAnalytics.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 17/3/22.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "UICollectionView+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SASwizzle.h"
#import "SALogger.h"
#import "AutoTrackUtils.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UICollectionView (AutoTrack)

#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UICOLLECTIONVIEW

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @try {
//            NSError *error = NULL;
//            [[self class] sa_swizzleMethod:@selector(setDelegate:)
//                                withMethod:@selector(sa_collectionViewSetDelegate:)
//                                     error:&error];
//            if (error) {
//                SAError(@"Failed to swizzle s