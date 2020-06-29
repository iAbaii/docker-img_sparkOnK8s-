
//
//  SADesignerEventBindingMessage.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Amanda Canyon on 11/18/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import "SADesignerConnection.h"
#import "SADesignerEventBindingMessage.h"
#import "SAEventBinding.h"
#import "SAObjectSelector.h"
#import "SALogger.h"
#import "SASwizzler.h"
#import "SensorsAnalyticsSDK.h"

# pragma mark -- EventBinding Request

NSString *const SADesignerEventBindingRequestMessageType = @"event_binding_request";

@implementation SADesignerEventBindingRequestMessage

+ (instancetype)message {
    return [(SADesignerEventBindingRequestMessage *)[self alloc] initWithType:@"event_binding_request"];
}

- (NSOperation *)responseCommandWithConnection:(SADesignerConnection *)connection {
    __weak SADesignerConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        SADesignerConnection *conn = weak_connection;

        dispatch_sync(dispatch_get_main_queue(), ^{
            SADebug(@"Loading event bindings:\n%@",[self payload][@"events"]);
            NSArray *payload = [self payload][@"events"];
            SAEventBindingCollection *bindingCollection = [conn sessionObjectForKey:@"event_bindings"];
            if (!bindingCollection || ![bindingCollection isKindOfClass:[SAEventBindingCollection class]]) {
                bindingCollection = [[SAEventBindingCollection alloc] init];
                [conn setSessionObject:bindingCollection forKey:@"event_bindings"];
            }
            [bindingCollection updateBindingsWithPayload:payload];
        });

        SADesignerEventBindingResponseMessage *changeResponseMessage = [SADesignerEventBindingResponseMessage message];
        changeResponseMessage.status = @"OK";
        [conn sendMessage:changeResponseMessage];
    }];

    return operation;
}

@end

# pragma mark -- EventBinding Response

@implementation SADesignerEventBindingResponseMessage

+ (instancetype)message {
    return [(SADesignerEventBindingResponseMessage *)[self alloc] initWithType:@"event_binding_response"];
}

- (void)setStatus:(NSString *)status {
    [self setPayloadObject:status forKey:@"status"];
}

- (NSString *)status {