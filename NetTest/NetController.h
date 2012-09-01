//
//  NetController.h
//  NetTest
//
//  Created by Alexey Grabik on 01.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetController : NSObject
{
    CFSocketRef _socket;
}

- (void)connect;
- (void)sendData:(NSData *)data;
@end
