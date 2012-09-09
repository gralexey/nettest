//
//  Packet.h
//  NetTest
//
//  Created by Alexey Grabik on 09.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proto.h"

@interface Packet : NSObject
{
    mrim_packet_header_t *_header;
    char *_body;
    char *_content;
    int _body_size;
}
- (id)initWithType:(u_int)msg;
- (id)initWithBytes:(char *)bytes length:(u_int)len;
- (u_int)length;
- (char *)bytes;
- (void)printPacket;

@end
