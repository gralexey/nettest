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
#import "Packet.h"

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
            [self processPacket];
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
    return 0;
}

- (void)processPacket
{
    uint8_t buf[128];
    int num_read_bytes = [_inputStream read:buf maxLength:127];
    printf("*** read bytes: %d\n", num_read_bytes);
    if (num_read_bytes < 1) {
        NSLog(@"Recieved 0 bytes(?)");
        return;
    }
    
    Packet *packet = [[Packet alloc] initWithBytes:(char *)buf length:num_read_bytes];
    NSLog(@"recieving packet:");
    [packet printPacket];
    
    //mrim_packet_header_t answer_header;
    //memcpy(&answer_header, buf, sizeof(mrim_packet_header_t));
    //printf("%x\n", answer_header.magic);
}

- (void)sendPacketHello
{
    if([_outputStream streamStatus] == NSStreamStatusNotOpen) {
        NSLog(@"*** outputStream isn't opened");
        return;
    }
    Packet *packet = [[Packet alloc] initWithType:MRIM_CS_HELLO];
    
    [_outputStream write:(uint8_t *)[packet bytes] maxLength:[packet length]];
    NSLog(@"sending packet:");
    [packet printPacket];
    [packet release];
}

- (void)sendPacketLogin3
{
    if([_outputStream streamStatus] == NSStreamStatusNotOpen) {
        NSLog(@"*** outputStream isn't opened");
        return;
    }
    Packet *packet = [[Packet alloc] initWithType:MRIM_CS_LOGIN3];
    [packet printPacket];
}

- (void)connectToSpecifiedServerIP:(char *)serverIp withPort:(char *)serverPort
{    
    CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, serverIp, kCFStringEncodingUTF8);
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, name);
    SInt32 port = atoi(serverPort);    
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, port, &readStream, &writeStream);
    _inputStream = (NSInputStream *)readStream;
    _outputStream = (NSOutputStream *)writeStream;        
    [_outputStream open];
    [_inputStream open];
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)sendData:(char *)data
{
    if ([_outputStream streamStatus] == NSStreamStatusOpen) {
        [_outputStream write:(uint8_t *)"test_string\n" maxLength:strlen("test_string\n")];
    }    
}

@end
