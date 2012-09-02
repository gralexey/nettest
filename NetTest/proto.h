//
//  proto.h
//  NetTest
//
//  Created by Alexey Grabik on 02.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#ifndef NetTest_proto_h
#define NetTest_proto_h

typedef struct mrim_packet_header_t
{
    u_int      magic;          // Magic
    u_int      proto;          // Версия протокола
    u_int      seq;            // Sequence
    u_int      msg;            // Тип пакета
    u_int      dlen;           // Длина данных
    u_int      from;           // Адрес отправителя
    u_int      fromport;       // Порт отправителя
    u_char     reserved[16];   // Зарезервировано
}
mrim_packet_header_t;

#define PROTO_VERSION 0x00010016
#define MRIM_CS_HELLO 0x1001

#endif
