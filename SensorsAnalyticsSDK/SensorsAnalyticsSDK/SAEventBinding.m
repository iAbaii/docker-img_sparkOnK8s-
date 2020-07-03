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
                                   [SAUIControlBinding typeName] : [SAUIControlBinding class],
                                   [SAUITableViewBinding typeName] : [SAUITableViewBinding class]
                                   };
    return[classTypeMap valueForKey:bindingType] ?: [SAUIControlBinding class];
}

- (void)track:(NSString *)event withProperties:(NSDictionary *)properties {
    NSMutableDictionary *bindingProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                              [NSString stringWithFormat: @"%ld", (long)self.triggerId], @"$from_vtrack",
                                              @(self.triggerId), @"$binding_trigger_id",
                                              self.path.string, @"$binding_path",
                                              self.deployed ? @YES : @NO, @"$binding_depolyed",
                               