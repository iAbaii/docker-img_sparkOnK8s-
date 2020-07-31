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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary[@"selector"] != nil);
    NSParameterAssert(dictionary[@"parameters"] != nil);

    self = [super init];
    if (self) {
        _selectorName = [dictionary[@"selector"] copy];
        NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:[dictionary[@"parameters"] count]];
        for (NSDictionary *parameter in dictionary[@"parameters"]) {
            [parameters addObject:[[SAPropertySelectorParameterDescription alloc] initWithDictionary:parameter]];
        }

        _parameters = [parameters copy];
        _returnType = [dictionary[@"result"][@"type"] copy]; // optional
    }

    return self;
}

@end

@interface SAPropertyDescription ()

@property (nonatomic, readonly) NSPredicate *predicate;

@end

@implementation SAPropertyDescription

+ (NSValueTransformer *)valueTransformerForType:(NSString *)typeName {
    // TODO: lookup transformer by type
    for (NSString *toTypeName in @[@"NSDictionary", @"NSNumber", @"NSString"]) {
        NSString *toTransformerName = [NSString stringWithFormat:@"SA%@To%@ValueTransformer", typeName, toTypeName];
        NSValueTransformer *toTransformer = [NSValueTransformer valueTransformerForName:toTransformerName];
        if (toTransformer) {
            return toTransfor