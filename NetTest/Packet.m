//
//  Packet.m
//  NetTest
//
//  Created by Alexey Grabik on 09.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import "Packet.h"

void lpsString(char *dest, char *source)
{
    u_int len = strlen(source);
    memcpy(dest, &len, 4);
    memcpy(dest + 4, source, len);
    *(dest + 4 + len) = 0;
}

int strlen_lps(char *str)
{
    int len = strlen(str + 4) + 4;//
    return strlen(str + 4) + 4;
}

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
                _body_size = 2 * sizeof(u_long);
                _body_size = 0;
                _header->dlen = _body_size;
                _header->msg = MRIM_CS_HELLO;
                
                     
                u_long ping_period = 0x50000000;
                u_long server_ping_period = 0x50000000;
                
                _body = malloc(_body_size);
                memcpy(_body, &ping_period, sizeof(u_long));
                memcpy(_body + sizeof(u_long), &server_ping_period, sizeof(u_long));                
                break;
             
            case MRIM_CS_LOGIN3:
                _header->msg = MRIM_CS_LOGIN3;
                char lps_login[32];
                lpsString(lps_login, "gralexey@mail.ru");
                
                //char lps_password[64];
                //lpsString(lps_password,                          "cd    45    cc    fd     6f    6c    8c    a8    69    7b    64    0d    f8    fa    8c    57");
                char lps_password[] =  {0x10, 0x00, 0x00, 0x00,   0xcd, 0x45, 0xcc, 0xfd,  0x6f, 0x6c, 0x8c, 0xa8, 0x69, 0x7b, 0x64, 0x0d, 0xf8, 0xfa, 0x8c, 0x57};
                
                u_long com_support = 0x0195;
                
                char lps_useragent[64];
                lpsString(lps_useragent, "client=\"chuck\" version=\"1\" build=\"1\"");
                
                char lps_lang[32];
                lpsString(lps_lang, "ru");
                
                //char clps_ua_data_names[32];
                //clps_ua_data_names[0] = 0;
                char clps_ua_data_names[] = {0x04, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00};       // 8                
                
                char lps_client_description[32];
                lpsString(lps_client_description, "norris");
                
                NSMutableData *data = [[NSMutableData alloc] init];
                [data appendBytes:lps_login length:strlen_lps(lps_login)];
                [data appendBytes:lps_password length:20];
                [data appendBytes:&com_support length:sizeof(u_long)];
                [data appendBytes:lps_useragent length:strlen_lps(lps_useragent)];
                [data appendBytes:lps_lang length:strlen_lps(lps_lang)];
                [data appendBytes:clps_ua_data_names length:8];
                [data appendBytes:lps_client_description length:strlen_lps(lps_client_description)];
                //[data appendBytes:lps_client_description length:strlen_lps(lps_client_description)];
                
                _body_size = [data length];
                _header->dlen = _body_size;
                _body = malloc(_body_size);
                memcpy(_body, [data bytes], [data length]);
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
        else {
            return nil;
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
    char str[16];
    int i;
    switch (msg) {
        case MRIM_CS_HELLO:
            return "MRIM_CS_HELLO";
        case MRIM_CS_HELLO_ACK:
            return "MRIM_CS_HELLO_ACK";
        case MRIM_CS_LOGIN3:
            return "MRIM_CS_LOGIN3";
        case MRIM_CS_LOGIN_ACK:
            return "MRIM_CS_LOGIN_ACK";            
        default:
            sprintf(str, "0x%x", msg);
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
    
//    for (int idx = 0; idx < _body_size; idx++) {
//        printf("%x ", _body[idx]);
//    }
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
