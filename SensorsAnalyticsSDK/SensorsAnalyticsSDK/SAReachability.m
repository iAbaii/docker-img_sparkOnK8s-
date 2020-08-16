/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>

#import "SAReachability.h"

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *kSAReachabilityChangedNotification = @"kSANetworkReachabilityChangedNotification";

#pragma mark - SAReachability implementation

@implementation SAReachability
{
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	SAReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL)
	{
		returnValue= [[self alloc] init];
		if (returnValue != NULL)
		{
            returnValue->_reachabilityRef = reachability;
		}
        else {
            CFRelease(reachability);
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
	SCNetworkReachabilityRef reachab