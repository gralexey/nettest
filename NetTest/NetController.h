//
//  NetController.h
//  NetTest
//
//  Created by Alexey Grabik on 01.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetController : NSObject <NSStreamDelegate>
{
    CFSocketRef _socket;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
}

- (void)connect;
- (void)sendData:(char *)data;
@end
