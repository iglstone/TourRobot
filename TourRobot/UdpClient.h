//
//  UdpClient.h
//  TourRobot
//
//  Created by 郭龙 on 16/1/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

@interface UdpClient : NSObject

+ (instancetype) sharedUdpSocket;

- (void) sentMessage:(NSString *)string ;
@end
