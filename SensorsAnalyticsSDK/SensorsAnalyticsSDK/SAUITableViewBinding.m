
//
//  SAUITableViewBinding.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Amanda Canyon on 8/5/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "SALogger.h"
#import "SASwizzler.h"
#import "SAUITableViewBinding.h"

@implementation SAUITableViewBinding

+ (NSString *)typeName {
    return @"UITableView";
}

+ (SAEventBinding *)bindingWithJSONObject:(NSDictionary *)object {
    NSString *path = object[@"path"];
    if (![path isKindOfClass:[NSString class]] || [path length] < 1) {
        SAError(@"must supply a view path to bind by");
        return nil;
    }

    NSString *eventName = object[@"event_name"];
    if (![eventName isKindOfClass:[NSString class]] || [eventName length] < 1 ) {
        SAError(@"binding requires an event name");
        return nil;
    }
    
    NSInteger triggerId = [[object objectForKey:@"trigger_id"] integerValue];
    if (triggerId <= 0) {
        SAError(@"binding requires a trigger id");
    }