//
//  SAEventBinding.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//

#import "SAEventBinding.h"
#import "SALogger.h"
#import "SAUIControlBinding.h"
#import "SAUITableViewBinding.h"
#import "SensorsAnalyticsSDK.h"

@implementation SAEventBinding

+ (SAEventBinding *)bindingWithJSONObject:(NSDictionary *)object {
    if (object == nil) {
        SAError(@"must supply an JSON object to initialize from");
        return nil;
    }

    NSString *bindingType = object[@"event_type"];
    Class klass = [self subclassFromString:bindingType];
    return [klass bindingWithJSONObject:object];
}

+ (Class)subclassFromString:(NSString *)bindingType {
    NSDictionary *classTypeMap = @{
                                   [SAUIControlBinding typ