//  SensorsAnalyticsSDK.m
//  SensorsAnalyticsSDK
//
//  Created by 曹犟 on 15/7/1.
//  Copyright (c) 2015年 SensorsData. All rights reserved.

#import <objc/runtime.h>
#include <sys/sysctl.h>
#include <stdlib.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>

#import "JSONUtil.h"
#import "SAGzipUtility.h"
#import "MessageQueueBySqlite.h"
#import "NSData+SABase64.h"
#import "SADesignerConnection.h"
#import "SADesignerEventBindingMessage.h"
#import "SADesignerSessionCollection.h"
#import "SAEventBinding.h"
#import "SALogger.h"
#import "SAReachability.h"
#import "SASwizzler.h"
#import "SensorsAnalyticsSDK.h"
#import "JSONUtil.h"
#import "UIApplication+AutoTrack.h"
#import "UIViewController+AutoTrack.h"
#import "SASwizzle.h"
#import "AutoTrackUtils.h"
#import "NSString+HashCode.h"
#import "SensorsAnalyticsExceptionHandler.h"
#define VERSION @"1.8.12"

#import "UIWindow+SASnapshotImage.h"

#define PROPERTY_LENGTH_LIMITATION 819100



// 自动追踪相关事件及属性
// App 启动或激活
NSString* const APP_START_EVENT = @"$AppStart";
// App 退出或进入后台
NSString* const APP_END_EVENT = @"$AppEnd";
// App 浏览页面
NSString* const APP_VIEW_SCREEN_EVENT = @"$AppViewScreen";
// App 首次启动
NSString* const APP_FIRST_START_PROPERTY = @"$is_first_time";
// App 是否从后台恢复
NSString* const RESUME_FROM_BACKGROUND_PROPERTY = @"$resume_from_background";
// App 浏览页面名称
NSString* const SCREEN_NAME_PROPERTY = @"$screen_name";
// App 浏览页面 Url
NSString* const SCREEN_URL_PROPERTY = @"$url";
// App 浏览页面 Referrer Url
NSString* const SCREEN_REFERRER_URL_PROPERTY = @"$referrer";

// APP 截屏行为
NSString* const APP_DID_TAKE_SCREENSHOT = @"$take_screenshot";


@implementation SensorsAnalyticsDebugException

@end

@implementation UIImage (SensorsAnalytics)
- (NSString *)sensorsAnalyticsImageName {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsImageName");
}

- (void)setSensorsAnalyticsImageName:(NSString *)sensorsAnalyticsImageName {
    objc_setAssociatedObject(self, @"sensorsAnalyticsImageName", sensorsAnalyticsImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end

@implementation UIView (SensorsAnalytics)
- (UIViewController *)viewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

//viewID
- (NSString *)sensorsAnalyticsViewID {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsViewID");
}

- (void)setSensorsAnalyticsViewID:(NSString *)sensorsAnalyticsViewID {
    objc_setAssociatedObject(self, @"sensorsAnalyticsViewID", sensorsAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//ignoreView
- (BOOL)sensorsAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, @"sensorsAnalyticsIgnoreView") boolValue];
}

- (void)setSensorsAnalyticsIgnoreView:(BOOL)sensorsAnalyticsIgnoreView {
    objc_setAssociatedObject(self, @"sensorsAnalyticsIgnoreView", [NSNumber numberWithBool:sensorsAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

//afterSendAction
- (BOOL)sensorsAnalyticsAutoTrackAfterSendAction {
    return [objc_getAssociatedObject(self, @"sensorsAnalyticsAutoTrackAfterSendAction") boolValue];
}

- (void)setSensorsAnalyticsAutoTrackAfterSendAction:(BOOL)sensorsAnalyticsAutoTrackAfterSendAction {
    objc_setAssociatedObject(self, @"sensorsAnalyticsAutoTrackAfterSendAction", [NSNumber numberWithBool:sensorsAnalyticsAutoTrackAfterSendAction], OBJC_ASSOCIATION_ASSIGN);
}


//viewProperty
- (NSDictionary *)sensorsAnalyticsViewProperties {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsViewProperties");
}

- (void)setSensorsAnalyticsViewProperties:(NSDictionary *)sensorsAnalyticsViewProperties {
    objc_setAssociatedObject(self, @"sensorsAnalyticsViewProperties", sensorsAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)sensorsAnalyticsDelegate {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsDelegate");
}

- (void)setSensorsAnalyticsDelegate:(id)sensorsAnalyticsDelegate {
    objc_setAssociatedObject(self, @"sensorsAnalyticsDelegate", sensorsAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}
@end

@interface SensorsAnalyticsSDK()

// 在内部，重新声明成可读写的
@property (atomic, strong) SensorsAnalyticsPeople *people;

@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *configureURL;
@property (atomic, copy) NSString *vtrackServerURL;

@property (atomic, copy) NSString *distinctId;
@property (atomic, copy) NSString *originalId;
@property (atomic, copy) NSString *loginId;
@property (atomic, copy) NSString *firstDay;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (atomic, strong) NSDictionary *automaticProperties;
@property (atomic, strong) NSDictionary *superProperties;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;

@property (nonatomic, strong) NSPredicate *regexTestName;

@property (atomic, strong) MessageQueueBySqlite *messageQueue;

@property (nonatomic, strong) id abtestDesignerConnection;
@property (atomic, strong) NSSet *eventBindings;

@property (assign, nonatomic) BOOL safariRequestInProgress;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *vtrackConnectorTimer;

//用户设置的不被AutoTrack的Controllers
@property (nonatomic, strong) NSMutableArray *ignoredViewControllers;

@property (nonatomic, strong) NSMutableArray *ignoredViewTypeList;

// 用于 SafariViewController
@property (strong, nonatomic) UIWindow *secondWindow;

- (instancetype)initWithServerURL:(NSString *)serverURL
                  andConfigureURL:(NSString *)configureURL
               andVTrackServerURL:(NSString *)vtrackServerURL
                     andDebugMode:(SensorsAnalyticsDebugMode)debugMode;

@end

@implementation SensorsAnalyticsSDK {
    SensorsAnalyticsDebugMode _debugMode;
    UInt64 _flushBulkSize;
    UInt64 _flushInterval;
    UInt64 _maxCacheSize;
    UIWindow *_vtrackWindow;
    NSDateFormatter *_dateFormatter;
    BOOL _autoTrack;                    // 自动采集事件
    BOOL _appRelaunched;                // App 从后台恢复
    BOOL _showDebugAlertView;
    UInt8 _debugAlertViewHasShownNumber;
    NSString *_referrerScreenUrl;
    NSDictionary *_lastScreenTrackProperties;
    BOOL _applicationWillResignActive;
    BOOL _clearReferrerWhenAppEnd;
	SensorsAnalyticsAutoTrackEventType _autoTrackEventType;
    SensorsAnalyticsNetworkType _networkTypePolicy;
}

static SensorsAnalyticsSDK *sharedInstance = nil;
#pragma mark UIApplicationUserDidTakeScreenshotNotification
- (void)userDidTakeScreenShort:(NSNotification*)notification {
    SADebug(@"用户产生截屏操作");
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIImage *snapshotImage = [window snapshotImage];
    NSData *snapshotImage_data = [NSData dataWithData:UIImageJPEGRepresentation(snapshotImage, 0.5)];
    NSString *snapshotImage_data_base64 = [snapshotImage_data sa_base64EncodedString];
    NSString *uid = [self distinctId];
    NSTimeInterval timeInterval = [[NSDate date]timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%@_%.0lf",uid,timeInterval];
    
    if (_autoTrack) {
        if (_autoTrack && SensorsAnalyticsEventTypeAppDidTakeScreenshot) {
            [self track:APP_DID_TAKE_SCREENSHOT withProperties:@{
                                                                 @"snapshotImage":snapshotImage_data_base64,
                                                                 @"snapshotImage_name":key,
                                                                 }];
        }
    }
}


#pragma mark - Initialization

+ (SensorsAnalyticsSDK *)sharedInstanceWithServerURL:(NSString *)serverURL
                                     andConfigureURL:(NSString *)configureURL
                                        andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    return [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL
                                            andConfigureURL:configureURL
                                         andVTrackServerURL:nil
                                               andDebugMode:debugMode];
}


+ (SensorsAnalyticsSDK *)sharedInstanceWithServerURL:(NSString *)serverURL
                                     andConfigureURL:(NSString *)configureURL
                                  andVTrackServerURL:(NSString *)vtrackServerURL
                                        andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithServerURL:serverURL
                                          andConfigureURL:configureURL
                                       andVTrackServerURL:vtrackServerURL
                                             andDebugMode:debugMode];
    });
    return sharedInstance;
}

+ (SensorsAnalyticsSDK *)sharedInstance {
    return sharedInstance;
}

+ (UInt64)getCurrentTime {
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    return time;
}

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal {
    NSString *distinctId = NULL;

    // 宏 SENSORS_ANALYTICS_IDFA 定义时，优先使用IDFA
#if defined(SENSORS_ANALYTICS_IDFA)
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        distinctId = [uuid UUIDString];
        // 在 iOS 10.0 以后，当用户开启限制广告跟踪，advertisingIdentifier 的值将是全零
        // 00000000-0000-0000-0000-000000000000
        if (distinctId && ![distinctId hasPrefix:@"00000000"]) {
            *isReal = YES;
        } else{
            distinctId = NULL;
        }
    }
#endif
    
    // 没有IDFA，则使用IDFV
    if (!distinctId && NSClassFromString(@"UIDevice")) {
        distinctId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        *isReal = YES;
    }
    
    // 没有IDFV，则使用UUID
    if (!distinctId) {
        SADebug(@"%@ error getting device identifier: falling back to uuid", self);
        distinctId = [[NSUUID UUID] UUIDString];
        *isReal = NO;
    }
    
    return distinctId;
}

- (BOOL)shouldTrackClass:(Class)aClass {
    static NSSet *blacklistedClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *_blacklistedViewControllerClassNames = @[@"SFBrowserRemoteViewController",
                                                          @"SFSafariViewController",
                                                          @"UIAlertController",
                                                          @"UIInputWindowController",
                                                          @"UINavigationController",
                                                          @"UIKeyboardCandidateGridCollectionViewController",
                                                          @"UICompatibilityInputViewController",
                                                          @"UIApplicationRotationFollowingController",
                                                          @"UIApplicationRotationFollowingControllerNoTouches",
                                                          @"AVPlayerViewController",
                                                          @"UIActivityGroupViewController",
                                                          @"UIReferenceLibraryViewController",
                                                          @"UIKeyboardCandidateRowViewController",
                                                          @"UIKeyboardHiddenViewController",
                                                          @"_UIAlertControllerTextFieldViewController",
                                                          @"_UILongDefinitionViewController",
                                                          @"_UIResilientRemoteViewContainerViewController",
                                                          @"_UIShareExtensionRemoteViewController",
                                                          @"_UIRemoteDictionaryViewController",
                                                          @"UISystemKeyboardDockController",
                                                          @"_UINoDefinitionViewController",
                                                          @"UIImagePickerController",
                                                          @"_UIActivityGroupListViewController",
                                                          @"_UIRemoteViewController",
                                                          @"_UIFallbackPresentationViewController",
                                                          @"_UIDocumentPickerRemoteViewController",
                                                          @"_UIAlertShimPresentingViewController",
                                                          @"_UIWaitingForRemoteViewContainerViewController",
                                                          @"UIAlertController",
                                                          @"UIDocumentMenuViewController",
                                                          @"UIActivityViewController",
                                                          @"_UIActivityUserDefaultsViewController",
                                                          @"_UIActivityViewControllerContentController",
                                                          @"_UIRemoteInputViewController",
                                                          @"UIViewController",
                                                          @"UITableViewController",
                                                          @"_UIUserDefaultsActivityNavigationController",
                                                          @"UISnapshotModalViewController",
                                                          @"WKActionSheet",
                                                          @"DDSafariViewController",
                                                          @"SFAirDropActivityViewController",
                                                          @"CKSMSComposeController",
                                                          @"DDParsecLoadingViewController",
                                                          @"PLUIPrivacyViewController",
                                                          @"PLUICameraViewController",
                                                          @"SLRemoteComposeViewController",
                                                          @"CAMViewfinderViewController",
                                                          @"DDParsecNoDataViewController",
                                                          @"CAMPreviewViewController",
                                                          @"DDParsecCollectionViewController",
                                                          @"SLComposeViewController",
                                                          @"DDParsecRemoteCollectionViewController",
                                                          @"AVFullScreenPlaybackControlsViewController",
                                                          @"PLPhotoTileViewController",
                                                          @"AVFullScreenViewController",
                                                          @"CAMImagePickerCameraViewController",
                                                          @"CKSMSComposeRemoteViewController",
                                                          @"PUPhotoPickerHostViewController",
                                                          @"PUUIAlbumListViewController",
                                                          @"PUUIPhotosAlbumViewController",
                                                          @"SFAppAutoFillPasswordViewController",
                                                          @"PUUIMomentsGridViewController",
                                                          @"SFPasswordRemoteViewController",
                                                          ];
        NSMutableSet *transformedClasses = [NSMutableSet setWithCapacity:_blacklistedViewControllerClassNames.count];
        for (NSString *className in _blacklistedViewControllerClassNames) {
            if (NSClassFromString(className) != nil) {
                [transformedClasses addObject:NSClassFromString(className)];
            }
        }
        blacklistedClasses = [transformedClasses copy];
    });

    return ![blacklistedClasses containsObject:aClass];
}

- (instancetype)initWithServerURL:(NSString *)serverURL
                  andConfigureURL:(NSString *)configureURL
               andVTrackServerURL:(NSString *)vtrackServerURL
                     andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    
    if (self = [self init]) {
        if (serverURL == nil || [serverURL length] == 0) {
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [NSException exceptionWithName:@"InvalidArgumentException"
                                               reason:@"serverURL is nil"
                                             userInfo:nil];
            } else {
                SAError(@"serverURL is nil");
            }
        }

        if (debugMode != SensorsAnalyticsDebugOff) {
            // 将 Server URI Path 替换成 Debug 模式的 '/debug'
            NSURL *url = [[[NSURL URLWithString:serverURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"debug"];
            serverURL = [url absoluteString];
        }

        _autoTrackEventType = SensorsAnalyticsEventTypeNone;
        _networkTypePolicy = SensorsAnalyticsNetworkType3G | SensorsAnalyticsNetworkType4G | SensorsAnalyticsNetworkTypeWIFI;

        // 将 Configure URI Path 末尾补齐 iOS.conf
        NSURL *url = [NSURL URLWithString:configureURL];
        if ([[url lastPathComponent] isEqualToString:@"config"]) {
            url = [url URLByAppendingPathComponent:@"iOS.conf"];
        }
        configureURL = [url absoluteString];

        self.people = [[SensorsAnalyticsPeople alloc] initWithSDK:self];
        
        self.serverURL = serverURL;
        self.configureURL = configureURL;
        self.vtrackServerURL = vtrackServerURL;
        _debugMode = debugMode;
        
        _flushInterval = 15 * 1000;
        _flushBulkSize = 100;
        _maxCacheSize = 10000;
        _vtrackWindow = nil;
        _autoTrack = NO;
        _appRelaunched = NO;
        _showDebugAlertView = YES;
        _debugAlertViewHasShownNumber = 0;
        _referrerScreenUrl = nil;
        _lastScreenTrackProperties = nil;
        _applicationWillResignActive = NO;
        _clear