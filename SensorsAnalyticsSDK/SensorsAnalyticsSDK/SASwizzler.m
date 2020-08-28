
//
//  SASwizzler.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Alex Hofsteede on 5/5/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <objc/runtime.h>

#import "SALogger.h"
#import "SASwizzler.h"

#define MIN_ARGS 2
#define MAX_ARGS 4
#define MIN_BOOL_ARGS 3
#define MAX_BOOL_ARGS 3

@interface SASwizzle : NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(swizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod;

@end

static NSMapTable *swizzles;

static void sa_swizzledMethod_2(id self, SEL _cmd) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    SASwizzle *swizzle = (SASwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL))swizzle.originalMethod)(self, _cmd);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}

static void sa_swizzledMethod_3(id self, SEL _cmd, id arg) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    SASwizzle *swizzle = (SASwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id))swizzle.originalMethod)(self, _cmd, arg);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

static void sa_swizzledMethod_3_bool(id self, SEL _cmd, BOOL arg) {
    Class klass = [self class];
    while (klass) {
        Method aMethod = class_getInstanceMethod(klass, _cmd);
        SASwizzle *swizzle = (SASwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
        if (swizzle) {
            ((void(*)(id, SEL, BOOL))swizzle.originalMethod)(self, _cmd, arg);
            
            NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, [NSNumber numberWithBool:arg]);
            }
            break;
        }
        klass = class_getSuperclass(klass);
    }
}

static void sa_swizzledMethod_4(id self, SEL _cmd, id arg, id arg2) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    SASwizzle *swizzle = (SASwizzle *)[swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

static void (*sa_swizzledMethods[MAX_ARGS - MIN_ARGS + 1])() = {sa_swizzledMethod_2, sa_swizzledMethod_3, sa_swizzledMethod_4};
static void (*sa_swizzledMethods_bool[MAX_BOOL_ARGS - MIN_BOOL_ARGS + 1])(id, SEL, BOOL) = {sa_swizzledMethod_3_bool};

@implementation SASwizzler

+ (void)load {
    swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
}

+ (void)printSwizzles {
    NSEnumerator *en = [swizzles objectEnumerator];
    SASwizzle *swizzle;
    while((swizzle = (SASwizzle *)[en nextObject])) {
        SADebug(@"%@", swizzle);
    }
}

+ (SASwizzle *)swizzleForMethod:(Method)aMethod {
    return (SASwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod {
    [swizzles removeObjectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(SASwizzle *)swizzle forMethod:(Method)aMethod {
    [swizzles setObject:swizzle forKey:MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
                  named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
//        [NSException raise:@"SwizzleException" format:@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass)];
        SALog(@"SwizzleException:Cannot find method for %@ on %@",NSStringFromSelector(aSelector), NSStringFromClass(aClass));
        return;
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs < MIN_ARGS || numArgs > MAX_ARGS) {
        [NSException raise:@"SwizzleException" format:@"Cannot swizzle method with %d args", numArgs];
    }
    
    IMP swizzledMethod = (IMP)sa_swizzledMethods[numArgs - 2];
    [SASwizzler swizzleSelector:aSelector onClass:aClass withBlock:aBlock andSwizzleMethod:swizzledMethod named:aName];
}

+ (void)swizzleBoolSelector:(SEL)aSelector
                    onClass:(Class)aClass
                  withBlock:(swizzleBlock)aBlock
                      named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
        [NSException raise:@"SwizzleBoolException" format:@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass)];
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs < MIN_BOOL_ARGS || numArgs > MAX_BOOL_ARGS) {