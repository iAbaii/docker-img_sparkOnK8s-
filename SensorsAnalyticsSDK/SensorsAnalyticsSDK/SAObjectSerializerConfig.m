//
//  SAObjectSerializerConfig.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import "SAClassDescription.h"
#import "SAEnumDescription.h"
#import "SAObjectSerializerConfig.h"
#import "SATypeDescription.h"

@implementation SAObjectSerializerConfig {
    NSDictionary *_classes;
    NSDictionary *_enums;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableDictionary *classDescriptions = [[NSMutableDictionary alloc] init];
        for (NSDictionary *d in dictionary[@"classes"]) {
            NSString *superclassName = d[@"superclass"];
            SAClassDescription *superclassDescription = superclassName ? classDescriptions[superclassName] : nil;
            SAClassDescription *classDescription = [[SAClassDescription alloc] initWithSuperclassDescription:superclassDescription
                                                                                                  dictionary:d];

            classDescriptions[classDescription.name] = classDescription;
        }

        NSMutableDictionary *enumDescriptions = [[NSMutableDictionary alloc] init];
        for (NSDictionary *d in dictionary[@"enums"]) {
            SAEnumDescription *enumDescription = [[SAEnumDescription alloc] initWithDictionary:d];
            enumDescriptions[enumDescription.name] = enumDescription;
        }

        _classes = [classDescriptions copy];
        _enums = [enumDescriptions copy];
    }

    return self;
}

- (NSArray *)classDescriptions {
    return [_classes allValues];
}

- (SAEnumDescription *)enumWithName:(NSString *)name {
