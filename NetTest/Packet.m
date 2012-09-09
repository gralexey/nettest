//
//  Packet.m
//  NetTest
//
//  Created by Alexey Grabik on 09.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import "Packet.h"

@implementation Packet

- (id)initWithType:(u_int)msg
{
    self = [super init];
    if (self) {
        _header = malloc(MRIM_HEADER_SIZE);
        
        static u_int seq = 0;
        _header->magic = 0xDEADBEEF;
        _header->proto = PROTO_VERSION;
        _header->seq = seq++;        
        memset(_header->reserved, 0, sizeof(_header->reserved));
        
        switch (msg) {
            case MRIM_CS_HELLO:
                _header->dlen = _body_size;
                _header->msg = MRIM_CS_HELLO;
                
                _body_size = 2 * sizeof(unsigned long);      
                unsigned long ping_period = 0x50000000;
                unsigned long server_ping_period = 0x50000000;
                
                _body = malloc(_body_size);
                memcpy(_body, &ping_period, sizeof(unsigned long));
                memcpy(_body + sizeof(unsigned long), &server_ping_period, sizeof(unsigned long));                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

- (id)initWithBytes:(char *)bytes length:(u_int)len
{
    self = [super init];
    if (self) {
        if (len >= MRIM_HEADER_SIZE) {
            _body_size = len - MRIM_HEADER_SIZE;
            _header = malloc(MRIM_HEADER_SIZE);        
            _body = malloc(_body_size);
            
            memcpy(_header, bytes, MRIM_HEADER_SIZE);
            memcpy(_body, bytes + MRIM_HEADER_SIZE, _body_size);
        }
    }
    return self;
}

- (u_int)type
{
    return _header->msg;
}

- (char *)bytes
{
    _content = malloc(sizeof(mrim_packet_header_t) + _body_size);
    memcpy(_content, _header, sizeof(mrim_packet_header_t));
    memcpy(_content + sizeof(mrim_packet_header_t), _body, _body_size);
    return _content;
}

- (char *)captionForMsg:(u_int)msg
{
    char str[32];
    int i;
    switch (msg) {
        case MRIM_CS_HELLO:
            return "MRIM_CS_HELLO";
        case MRIM_CS_HELLO_ACK:
            return "MRIM_CS_HELLO_ACK";            
        default:
            for (i = 0; i < 4; i++) {
                str[i] = (msg >> i) & 0xFF;
            }
            str[i] = 0;
            return strdup(str);
            break;
    }
}

- (void)printPacket
{
    printf("- header - magic: %x\n", _header->magic);
    printf("- header - proto: %x\n", _header->proto);
    printf("- header - seq: %u\n", _header->seq);
    printf("- header - msg: %s\n", [self captionForMsg:_header->msg]);
    printf("- header - dlen: %u\n", _header->dlen);
    printf("- header - from: %x\n", _header->from);
    printf("- header - fromport: %u\n", _header->fromport);
    
    for (int idx = 0; idx < _body_size; idx++) {
        printf("%x ", _body[idx]);
    }
    printf("\n");
}

- (u_int)length
{
    return MRIM_HEADER_SIZE + _body_size;
}

- (void)dealloc
{
    if (_header)    { free(_header);    }
    if (_body)      { free(_body);      }
    if (_content)   { free(_content);   }
    [super dealloc];
}

@end
