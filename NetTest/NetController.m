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
#import "proto.h"

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

- (int)connect
{
    CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, "mrim.mail.ru", kCFStringEncodingUTF8);
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, name);
    SInt32 port = 2042;
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, port, &readStream, &writeStream);
    _inputStream = (NSInputStream *)readStream;
    _outputStream = (NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    [_inputStream open];
    
    uint8_t serverAddr[32];
    int readBytes = [_inputStream read:serverAddr maxLength:31];
    NSLog(@"stream status 1: %u", [_outputStream streamStatus]);
    [_inputStream close];
    [_outputStream close];
    NSLog(@"stream status 2: %u", [_outputStream streamStatus]);
    
    serverAddr[readBytes - 1] = 0;
    char *colon = strchr((char *)serverAddr, ':');
    *colon = 0;
    char *serverPort = colon + 1;
    char *serverIp = (char *)serverAddr;
    printf("ip: %s\nport: %s\n\n", serverIp, serverPort);
    
    [self connectToSpecifiedServerIP:serverIp withPort:serverPort];
    
    mrim_packet_header_t packet_header;
    packet_header.magic = 0xDEADBEEF;
    packet_header.proto = PROTO_VERSION;
    packet_header.seq = 0;
    packet_header.msg = MRIM_CS_HELLO;
    memset(packet_header.reserved, 0, sizeof(packet_header.reserved));
    
    if([_outputStream streamStatus] == NSStreamStatusNotOpen) {
        return -1;
    }
    
    int num_write_bytes = [_outputStream write:(uint8_t *)&packet_header maxLength:sizeof(packet_header)];
    printf("write bytes: %d\n\n", num_write_bytes);
    
    uint8_t buf[128];
    int num_read_bytes = [_inputStream read:buf maxLength:127];
    buf[num_read_bytes - 1] = 0;
    printf("read bytes: %d\nread string: %s\n", num_read_bytes, buf);
    
    NSString *answer = [[NSString alloc] initWithBytes:buf length:num_read_bytes encoding:NSUTF8StringEncoding];
    NSLog(@"answer: %@", answer);
    
    return 0;
}

- (void)connectToSpecifiedServerIP:(char *)serverIp withPort:(char *)serverPort
{    
    CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, serverIp, kCFStringEncodingUTF8);
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, name);
    SInt32 port = atoi(serverPort);    
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, port, &readStream, &writeStream);
    _inputStream = (NSInputStream *)readStream;
    _outputStream = (NSOutputStream *)writeStream;    
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
