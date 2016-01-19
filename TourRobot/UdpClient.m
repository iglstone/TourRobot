//
//  UdpClient.m
//  TourRobot
//
//  Created by 郭龙 on 16/1/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "UdpClient.h"

@interface UdpClient ()<AsyncSocketDelegate> {
    AsyncUdpSocket  *client;
//    Byte byte[16];//  = Byte [16];
    Byte *byteChars;
}
@end

static UdpClient *_instance = nil;

@implementation UdpClient
+ (instancetype) sharedUdpSocket
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        client = [[AsyncUdpSocket alloc]initWithDelegate:self];
        [client receiveWithTimeout:-1 tag:0];
        NSInteger port = LISTEN_PORT;
        [client sendData:[CommonsFunc stringToData:@"hello world."] toHost:SERVER_IP port:port withTimeout:2.0 tag:1];
        Byte bt[] = {0,1,2,3,4};
        byteChars = bt;
    }
    return self;
}


- (void) sentMessage:(NSString *)string {
    if (!string) {
        return;
    }
    NSInteger port = LISTEN_PORT;
    Byte byte[] = {0,1,2,3};
    byte [2] = 4;
    NSData *data = [NSData dataWithBytes:byte length:4];
    [client sendData:data toHost:SERVER_IP port:port withTimeout:2.0 tag:1];
    [client sendData:[CommonsFunc stringToData:string] toHost:SERVER_IP port:port withTimeout:2.0 tag:1];
}

#pragma mark -
#pragma mark AsyncUdpSocketDelegate
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"----------");
}


- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"-----err-----%@",error);
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    NSLog(@"receive :%@",[CommonsFunc dataToString:data]);
    
    [sock receiveWithTimeout:-1 tag:0];
    return YES;
}

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"-----err-----%@",error);
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose");
}



//- (id)init
//{
//    self = [super init];
//    if (self)
//    {
//        result = [[NSMutableString alloc] init];
//        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
//        //        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
//        connectedSockets = [[NSMutableArray alloc] init];
//        self.selectedSocketArray = [[NSMutableArray alloc] init];
//        [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
//        receiveMessage = nil;
//        isRunning = NO;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toBackGround:) name:NOTICE_BACKGROUND object:nil];
//        socketMessageModlesArray = [[NSMutableArray alloc] init];
//        times = 0;
//
//        //client Socket init
//        clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
//        [clientSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
//
//    }
//    return self;
//}

@end
