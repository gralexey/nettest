//
//  NetController.m
//  NetTest
//
//  Created by Alexey Grabik on 01.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import "NetController.h"
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@implementation NetController

void callBackFunction(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    switch (callbackType) {
        case kCFSocketNoCallBack:
            NSLog(@"kCFSocketNoCallBack");
            break;
        case kCFSocketReadCallBack:
            NSLog(@"kCFSocketReadCallBack");
            printf("#%s\n", (const char *)data);
            CFSocketDisableCallBacks(s, kCFSocketReadCallBack );
            break;
        case kCFSocketAcceptCallBack:
            NSLog(@"kCFSocketAcceptCallBack");
            break;
        case kCFSocketDataCallBack:
            NSLog(@"kCFSocketDataCallBack");
            break;
        case kCFSocketConnectCallBack:
            NSLog(@"kCFSocketConnectCallBack");
            break;
        case kCFSocketWriteCallBack:
            NSLog(@"kCFSocketWriteCallBack");
            break;
        default:
            NSLog(@"Unknown callback");
            break;
    }
    CFSocketEnableCallBacks(s, kCFSocketReadCallBack );
}

- (id)init
{
    self = [super init];
    if (self) {
        _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketReadCallBack|kCFSocketConnectCallBack, (CFSocketCallBack)callBackFunction, NULL);     

        
        CFRunLoopRef cfrl = CFRunLoopGetCurrent();
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
        if(_socket) {
            NSLog(@"NetController initialized");
        }
        else {
           NSLog(@"Socket creation error occured"); 
        }
    }
    return self;
}

- (void)connect
{
    struct sockaddr_in sock_address;
    socklen_t sock_address_len = sizeof(sock_address);
    memset(&sock_address, 0, sizeof(sock_address_len));
    sock_address.sin_len = sock_address_len;
    sock_address.sin_family = PF_INET;
    sock_address.sin_port = htons(8000);
    sock_address.sin_addr.s_addr = inet_addr("192.168.1.137");
    
    NSData *sock_address_data = [[NSData alloc] initWithBytes:&sock_address length:sock_address_len];    
    CFSocketError err = CFSocketConnectToAddress(_socket, (CFDataRef)sock_address_data, -1);
    NSLog(@"Going on");
    switch (err) {
        case kCFSocketSuccess:
            NSLog(@"Connected");
            break;
        case kCFSocketError:
            NSLog(@"Connection error");
            break;
        case kCFSocketTimeout:
            NSLog(@"Timeout error");
            break;
        default:
            NSLog(@"Unknown Error");
            break;            
    }
}

- (void)sendData:(NSData *)data
{
    if(CFSocketIsValid(_socket)) {
        CFSocketError err = CFSocketSendData (_socket, NULL, data, 10);
        switch (err) {
            case kCFSocketSuccess:
                NSLog(@"Success");
                break;
            case kCFSocketError:
                NSLog(@"Error");
                break;
            case kCFSocketTimeout:
                NSLog(@"Timeout error");
                break;
            default:
                NSLog(@"Unknown Error");
                break;            
        }
    }
    else {
        NSLog(@"Socket is invalid");
    }
                                    
}

@end
