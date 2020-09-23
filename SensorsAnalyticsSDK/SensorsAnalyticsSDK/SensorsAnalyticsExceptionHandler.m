//
//  SensorsAnalyticsExceptionHandler.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/5/26.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "SensorsAnalyticsExceptionHandler.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@interface SensorsAnalyticsExceptionHandler ()

@property (nonatomic) NSUncaughtExceptionHandler *defaultExceptionHandler;
@property (nonatomic, unsafe_unretained) struct sigaction *prev_signal_handlers;
@property (nonatomic, strong) NSHashTable *sensorsAnalyticsSDKInstances;

@end

@interface SensorsAnalyticsSDK()
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation SensorsAnalyticsExceptionHandler

+ (instancetype)sharedHandler {
    static SensorsAnalyticsExceptionHandler *gSharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedHandler = [[SensorsAnalyticsExceptionHandler alloc] init];
    });
    return gSharedHandler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create a hash table of weak pointers to SensorsAnalytics instances
        _sensorsAnalyticsSDKInstances = [NSHashTable weakObjectsHashTable];
        
        _prev_signal_handlers = calloc(NSIG, sizeof(struct sigaction));
        
        // Install our handler
        [self setupHandlers];
    }
    return self;
}

- (void)dealloc {
    free(_prev_signal_handlers);
}

- (void)setupHandlers {
    _defaultExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&SAHandleException);
    
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_SIGINFO;
    action.sa_sigaction = &SASignalHandler;
    int signals[] = {SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE};
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        struct sigaction prev_action;
        int err = sigaction(signals[i], &action, &prev_action);
        if (err == 0) {
            memcpy(_prev_signal_handlers + signals[i], &prev_action, sizeof(prev_action));
        } else {
            NSLog(@"Errored while trying to set up sigaction for