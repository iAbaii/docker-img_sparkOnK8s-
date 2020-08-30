
//
//  SAUIControlBinding.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//

#import "SASwizzler.h"
#import "SAUIControlBinding.h"
#import "SALogger.h"

@interface SAUIControlBinding()

// 已监听的控件的字典
@property (nonatomic, copy) NSHashTable *appliedTo;
// 已触发前置事件的控件的字典
@property (nonatomic, copy) NSHashTable *verified;

- (void)stopOnView:(UIView *)view;

@end

@implementation SAUIControlBinding

+ (NSString *)typeName {
    return @"UIControl";
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
    BOOL deployed = [[object objectForKey:@"deployed"] boolValue];

    if (!(object[@"control_event"] && ([object[@"control_event"] unsignedIntegerValue] & UIControlEventAllEvents))) {
        SAError(@"must supply a valid UIControlEvents value for control_event");
        return nil;
    }

    UIControlEvents verifyEvent = object[@"verify_event"] ? [object[@"verify_event"] unsignedIntegerValue] : 0;
    return [[SAUIControlBinding alloc] initWithEventName:eventName
                                            andTriggerId:triggerId
                                                  onPath:path
                                              isDeployed:deployed
                                        withControlEvent:[object[@"control_event"] unsignedIntegerValue]
                                          andVerifyEvent:verifyEvent];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (SAEventBinding *)bindngWithJSONObject:(NSDictionary *)object {
    return [self bindingWithJSONObject:object];
}
#pragma clang diagnostic pop

- (instancetype)initWithEventName:(NSString *)eventName
                     andTriggerId:(NSInteger)triggerId
                           onPath:(NSString *)path
                       isDeployed:(BOOL)deployed
                 withControlEvent:(UIControlEvents)controlEvent
                   andVerifyEvent:(UIControlEvents)verifyEvent {
    if (self = [super initWithEventName:eventName andTriggerId:triggerId onPath:path isDeployed:deployed]) {
        [self setSwizzleClass:[UIControl class]];
        _controlEvent = controlEvent;
        _verifyEvent = verifyEvent;

        [self resetAppliedTo];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Event Binding: '%@' for '%@'", [self eventName], [self path]];
}

- (void)resetAppliedTo {
    self.verified = [NSHashTable hashTableWithOptions:(NSHashTableWeakMemory|NSHashTableObjectPointerPersonality)];
    self.appliedTo = [NSHashTable hashTableWithOptions:(NSHashTableWeakMemory|NSHashTableObjectPointerPersonality)];
}

#pragma mark -- Executing Actions

- (void)execute {
    if (!self.running) {
        void (^executeBlock)(id, SEL) = ^(id view, SEL command) {
            NSArray *objects;
            //NSObject *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
            NSObject *root = [[UIApplication sharedApplication].delegate window].rootViewController;
            if (view && [self.appliedTo containsObject:view]) {
                if (![self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                    [self stopOnView:view];
                    [self.appliedTo removeObject:view];
                }
            } else {
                // select targets based off path
                if (view) {
                    if ([self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                        objects = @[view];
                    } else {
                        objects = @[];