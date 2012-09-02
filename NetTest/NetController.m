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
#import <CFNetwork/CFSocketStream.h>
//#import <CFNetwork/CFStream.h>

@implementation NetController

/*void callBackFunction(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    switch (callbackType) {
        case kCFSocketNoCallBack:
            NSLog(@"kCFSocketNoCallBack");
            break;
        case kCFSocketReadCallBack:
            NSLog(@"kCFSocketReadCallBack");            
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
}*/

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable");
            uint8_t buf[256];
            int read_bytes = [_inputStream read:buf maxLength:255];
            *(buf + read_bytes - 1) = 0;
            NSLog(@"%s", buf);
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            break;
        default:
            NSLog(@"Unknown");
            break;
    }
}

- (void)connect
{
    CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, "192.168.1.137", kCFStringEncodingUTF8);
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, name);
    SInt32 port = 8000;
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, port, &readStream, &writeStream);
    _inputStream = (NSInputStream *)readStream;
    _outputStream = (NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    [_inputStream open];
}


- (void)sendData:(char *)data
{
    if ([_outputStream streamStatus] == NSStreamStatusOpen) {
        [_outputStream write:(uint8_t *)"test_string\n" maxLength:strlen("test_string\n")];
    }    
}

@end
