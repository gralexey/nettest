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
    int readBytes = [_inputStream read:serverAddr maxLength:31];                        // got address and port of target server
    [_inputStream close];
    [_outputStream close];
    
    serverAddr[readBytes - 1] = 0;
    char *colon = strchr((char *)serverAddr, ':');
    *colon = 0;
    char *serverPort = colon + 1;
    char *serverIp = (char *)serverAddr;
    printf("ip: %s\nport: %s\n\n", serverIp, serverPort);
    
    [self connectToSpecifiedServerIP:serverIp withPort:serverPort];                     // connect to specified server    
    [self sendPacketHello];    
    [self recvPacket];

    return 0;
}

- (void)recvPacket
{
    uint8_t buf[128];
    int num_read_bytes = [_inputStream read:buf maxLength:127];
    printf("read bytes: %d\n", num_read_bytes);
    
    mrim_packet_header_t answer_header;
    memcpy(&answer_header, buf, sizeof(mrim_packet_header_t));
    printf("%x\n", answer_header.magic);
}

- (void)sendPacketHello
{
    if([_outputStream streamStatus] == NSStreamStatusNotOpen) {
        NSLog(@"*** outputStream isn't opened");
        return;
    }
    
    mrim_packet_header_t packet_header;
    packet_header.magic = 0xDEADBEEF;
    packet_header.proto = PROTO_VERSION;
    packet_header.seq = 0;
    packet_header.msg = MRIM_CS_HELLO;
    packet_header.dlen = 2*sizeof(unsigned long);
    memset(packet_header.reserved, 0, sizeof(packet_header.reserved));    
    
    [_outputStream write:(uint8_t *)&packet_header maxLength:sizeof(packet_header)];
    
    unsigned long ping_period = 0x5000000000000000;
    unsigned long server_ping_period = 0x5000000000000000;    
    [_outputStream write:(uint8_t *)&ping_period maxLength:sizeof(ping_period)];
    [_outputStream write:(uint8_t *)&server_ping_period maxLength:sizeof(server_ping_period)];
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
