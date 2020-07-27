//
//  SAPropertyDescription.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import "SALogger.h"
#import "SAPropertyDescription.h"

@implementation SAPropertySelectorParameterDescription

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary[@"name"] != nil);
    NSParameterAssert(dictionary[@"type"] != nil);

    self = [super init];
    if (self) {
        _name = [dictionary[@"name"] copy];
        _type = [dictionary[@"type"] copy];
    }

    return self;
}

@end

@implementation SAPropertySelectorDescription

- (instancetype)initWithDictiona