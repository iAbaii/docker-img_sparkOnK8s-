
//
//  SADesignerConnection.,
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import "SADesignerConnection.h"
#import "SADesignerDeviceInfoMessage.h"
#import "SADesignerDisconnectMessage.h"
#import "SADesignerEventBindingMessage.h"
#import "SADesignerMessage.h"
#import "SADesignerSnapshotMessage.h"
#import "SADesignerSessionCollection.h"
#import "SALogger.h"
#import "SensorsAnalyticsSDK.h"

@interface SADesignerConnection () <SAWebSocketDelegate>

@end

@implementation SADesignerConnection {
    /* The difference between _open and _connected is that open
     is set when the socket is open, and _connected is set when
     we actually have started sending/receiving messages from
     the server. A connection can become _open/not _open in quick
     succession if the websocket proxy rejects the request, but
     we will only try and reconnect if we were actually _connected.
     */
    BOOL _open;
    BOOL _connected;

    NSURL *_url;
    NSMutableDictionary *_session;
    NSDictionary *_typeToMessageClassMap;
    SAWebSocket *_webSocket;
    NSOperationQueue *_commandQueue;
    UIView *_recordingView;
    void (^_connectCallback)();
    void (^_disconnectCallback)();
}

- (instancetype)initWithURL:(NSURL *)url
                 keepTrying:(BOOL)keepTrying
            connectCallback:(void (^)())connectCallback
         disconnectCallback:(void (^)())disconnectCallback {
    self = [super init];
    if (self) {
        _typeToMessageClassMap = @{
            SADesignerDeviceInfoRequestMessageType : [SADesignerDeviceInfoRequestMessage class],
            SADesignerDisconnectMessageType : [SADesignerDisconnectMessage class],
            SADesignerEventBindingRequestMessageType : [SADesignerEventBindingRequestMessage class],
            SADesignerSnapshotRequestMessageType : [SADesignerSnapshotRequestMessage class],
        };

        _open = NO;
        _connected = NO;
        _sessionEnded = NO;
        _useGzip = NO;
        _session = [[NSMutableDictionary alloc] init];
        _url = url;
        _connectCallback = connectCallback;
        _disconnectCallback = disconnectCallback;

        _commandQueue = [[NSOperationQueue alloc] init];
        _commandQueue.maxConcurrentOperationCount = 1;
        _commandQueue.suspended = YES;

        if (keepTrying) {
            [self open:YES maxInterval:15 maxRetries:999];
        } else {
            [self open:YES maxInterval:0 maxRetries:0];
        }
    }

    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url keepTrying:NO connectCallback:nil disconnectCallback:nil];
}


- (void)open:(BOOL)initiate maxInterval:(int)maxInterval maxRetries:(int)maxRetries {
    static int retries = 0;
    BOOL inRetryLoop = retries > 0;

    SADebug(@"In open. initiate = %d, retries = %d, maxRetries = %d, maxInterval = %d, connected = %d", initiate, retries, maxRetries, maxInterval, _connected);

    if (self.sessionEnded || _connected || (inRetryLoop && retries >= maxRetries) ) {
        // break out of retry loop if any of the success conditions are met.
        retries = 0;
    } else if (initiate ^ inRetryLoop) {
        // If we are initiating a new connection, or we are already in a
        // retry loop (but not both). Then open a socket.
        if (!_open) {
            SADebug(@"Attempting to open WebSocket to: %@, try %d/%d ", _url, retries, maxRetries);
            _open = YES;
            _webSocket = [[SAWebSocket alloc] initWithURL:_url];
            _webSocket.delegate = self;
            [_webSocket open];
        }
        if (retries < maxRetries) {
            __weak SADesignerConnection *weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SADesignerConnection *strongSelf = weakSelf;
                [strongSelf open:NO maxInterval:maxInterval maxRetries:maxRetries];
            });
            retries++;
        }
    }
}

- (void)close {