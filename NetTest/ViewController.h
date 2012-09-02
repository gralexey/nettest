//
//  ViewController.h
//  NetTest
//
//  Created by Alexey Grabik on 01.09.12.
//  Copyright (c) 2012 Alexey Grabik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetController.h"

@interface ViewController : UIViewController
{
    NetController *_nc;
}

@property (retain) NetController *nc;

- (IBAction)sendData:(id)sender;
- (IBAction)connect:(id)sender;
@end
