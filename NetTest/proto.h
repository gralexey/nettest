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

typedef struct packet
{
    mrim_packet_header_t packet_header;
    
}
packet;

#define MRIM_HEADER_SIZE sizeof(mrim_packet_header_t)
#define PROTO_VERSION 0x00010016
#define MRIM_CS_HELLO 0x1001
#define MRIM_CS_HELLO_ACK 0x1002  // S -> C
#define MRIM_CS_LOGIN_ACK 0x1004  // S -> C
#define MRIM_CS_LOGIN3 0x1078  // C -> S


#endif

  /*  efbeadde    magic
    16000100    proto
    08000000    sequence
    78100000    message
    48010000    dlen
    00000050    from
    0c100000    fromport
    00000000000000000000000000000000*/

#define EX_BODY    100000006772616c65786579406d61696c2e727510000000cd45ccfd6f6c8ca8697b640df8fa8c57950100002e000000636c69656e743d226d61636167656e74222076657273696f6e3d22332e322e3022206275696c643d22323334372202000000727504000000000000002e0000004d61696c2e5275204d6163204f53205820436c69656e7420332e322e302e32333437206f733d2231302e372e34222c0000000120000000444232464534414442324631344244314239394244453134464641413237434643000000010f0000004d6163204f5320582031302e372e344f000000010900000031393230783130383045000000010500000072755f52554c000000010a0000004170706c6520496e632e830000000100000000850000000100000000b80000000200000000b70000000201000000b90000000201000000ba0000000200000000