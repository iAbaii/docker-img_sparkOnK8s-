
//
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

//
//   Portions Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "SAWebSocket.h"

#if TARGET_OS_IPHONE
#define HAS_ICU
#endif

#ifdef HAS_ICU

#import <unicode/utf8.h>

#endif

#if TARGET_OS_IPHONE

#import <Endian.h>

#else

#import <CoreServices/CoreServices.h>

#endif

#import <CommonCrypto/CommonDigest.h>
#import <Security/SecRandom.h>
#import "SALogger.h"
#import "NSData+SABase64.h"

#if OS_OBJECT_USE_OBJC_RETAIN_RELEASE
#define sa_dispatch_retain(x)
#define sa_dispatch_release(x)
#define maybe_bridge(x) ((__bridge void *) x)
#else
#define sa_dispatch_retain(x) dispatch_retain(x)
#define sa_dispatch_release(x) dispatch_release(x)
#define maybe_bridge(x) (x)
#endif

#if !__has_feature(objc_arc)
#error SAWebSocket must be compiled with ARC enabled
#endif


typedef NS_OPTIONS(unsigned int, SAOpCode)  {
    SAOpCodeTextFrame = 0x1,
    SAOpCodeBinaryFrame = 0x2,
    // 3-7 reserved.
    SAOpCodeConnectionClose = 0x8,
    SAOpCodePing = 0x9,
    SAOpCodePong = 0xA,
    // B-F reserved.
};

typedef NS_ENUM(unsigned int, SAStatusCode) {
    SAStatusCodeNormal = 1000,
    SAStatusCodeGoingAway = 1001,
    SAStatusCodeProtocolError = 1002,
    SAStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    MPStatusNoStatusReceived = 1005,
    // 1004-1006 reserved.
    SAStatusCodeInvalidUTF8 = 1007,
    SAStatusCodePolicyViolated = 1008,
    SAStatusCodeMessageTooBig = 1009,
};

typedef struct {
    BOOL fin;
//  BOOL rsv1;
//  BOOL rsv2;
//  BOOL rsv3;
    uint8_t opcode;
    BOOL masked;
    uint64_t payload_length;
} frame_header;

static NSString *const SAWebSocketAppendToSecKeyString = @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

static inline int32_t validate_dispatch_data_partial_string(NSData *data);

@interface NSData (SAWebSocket)

- (NSString *)stringBySHA1ThenBase64Encoding;

@end


@interface NSString (SAWebSocket)

- (NSString *)stringBySHA1ThenBase64Encoding;

@end


@interface NSURL (SAWebSocket)

// The origin isn't really applicable for a native application.
// So instead, just map ws -> http and wss -> https.
- (NSString *)mp_origin;

@end


@interface _SARunLoopThread : NSThread

@property (nonatomic, readonly) NSRunLoop *runLoop;

@end


static NSData *newSHA1(const char *bytes, size_t length) {
    uint8_t md[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(bytes, (uint)length, md);

    return [NSData dataWithBytes:md length:CC_SHA1_DIGEST_LENGTH];
}

@implementation NSData (SAWebSocket)

- (NSString *)stringBySHA1ThenBase64Encoding
{
    return [newSHA1(self.bytes, self.length) sa_base64EncodedString];
}

@end


@implementation NSString (SAWebSocket)

- (NSString *)stringBySHA1ThenBase64Encoding
{
    return [newSHA1(self.UTF8String, self.length) sa_base64EncodedString];
}

@end

NSString *const SAWebSocketErrorDomain = @"cn.sensorsdata.error.WebSocket";

// Returns number of bytes consumed. Returning 0 means you didn't match.
// Sends bytes to callback handler;
typedef size_t (^stream_scanner)(NSData *collected_data);

typedef void (^data_callback)(SAWebSocket *webSocket,  NSData *data);

@interface SAIOConsumer : NSObject {
    stream_scanner _scanner;
    data_callback _handler;
    size_t _bytesNeeded;
    BOOL _readToCurrentFrame;
    BOOL _unmaskBytes;
}
@property (nonatomic, copy, readonly) stream_scanner consumer;
@property (nonatomic, copy, readonly) data_callback handler;
@property (nonatomic, assign) size_t bytesNeeded;
@property (nonatomic, assign, readonly) BOOL readToCurrentFrame;
@property (nonatomic, assign, readonly) BOOL unmaskBytes;

@end

// This class is not thread-safe, and is expected to always be run on the same queue.
@interface SAIOConsumerPool : NSObject

- (instancetype)initWithBufferCapacity:(NSUInteger)poolSize;

- (SAIOConsumer *)consumerWithScanner:(stream_scanner)scanner handler:(data_callback)handler bytesNeeded:(size_t)bytesNeeded readToCurrentFrame:(BOOL)readToCurrentFrame unmaskBytes:(BOOL)unmaskBytes;
- (void)returnConsumer:(SAIOConsumer *)consumer;

@end

@interface SAWebSocket ()  <NSStreamDelegate>

- (void)_writeData:(NSData *)data;
- (void)_closeWithProtocolError:(NSString *)message;
- (void)_failWithError:(NSError *)error;

- (void)_disconnect;

- (void)_readFrameNew;
- (void)_readFrameContinue;

- (void)_pumpScanner;

- (void)_pumpWriting;

- (void)_addConsumerWithScanner:(stream_scanner)consumer callback:(data_callback)callback;
- (void)_addConsumerWithDataLength:(size_t)dataLength callback:(data_callback)callback readToCurrentFrame:(BOOL)readToCurrentFrame unmaskBytes:(BOOL)unmaskBytes;
- (void)_addConsumerWithScanner:(stream_scanner)consumer callback:(data_callback)callback dataLength:(size_t)dataLength;
- (void)_readUntilBytes:(const void *)bytes length:(size_t)length callback:(data_callback)dataHandler;
- (void)_readUntilHeaderCompleteWithCallback:(data_callback)dataHandler;

- (void)_sendFrameWithOpcode:(SAOpCode)opcode data:(id)data;

- (BOOL)_checkHandshake:(CFHTTPMessageRef)httpMessage;
- (void)_SA_commonInit;

- (void)_initializeStreams;
- (void)_connect;

@property (nonatomic) SAWebSocketReadyState readyState;

@property (nonatomic) NSOperationQueue *delegateOperationQueue;
@property (nonatomic) dispatch_queue_t delegateDispatchQueue;

@end


@implementation SAWebSocket {
    NSInteger _webSocketVersion;

    NSOperationQueue *_delegateOperationQueue;
    dispatch_queue_t _delegateDispatchQueue;

    dispatch_queue_t _workQueue;
    NSMutableArray *_consumers;

    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;

    NSMutableData *_readBuffer;
    NSUInteger _readBufferOffset;

    NSMutableData *_outputBuffer;
    NSUInteger _outputBufferOffset;

    uint8_t _currentFrameOpcode;
    size_t _currentFrameCount;
    size_t _readOpCount;
    uint32_t _currentStringScanPosition;
    NSMutableData *_currentFrameData;

    NSString *_closeReason;

    NSString *_secKey;

    BOOL _pinnedCertFound;

    uint8_t _currentReadMaskKey[4];
    size_t _currentReadMaskOffset;

    BOOL _consumerStopped;

    BOOL _closeWhenFinishedWriting;
    BOOL _failed;

    BOOL _secure;
    NSURLRequest *_urlRequest;

    CFHTTPMessageRef _receivedHTTPHeaders;

    BOOL _sentClose;
    BOOL _didFail;
    BOOL _cleanupScheduled;
    int _closeCode;

    BOOL _isPumping;

    NSMutableSet *_scheduledRunloops;
