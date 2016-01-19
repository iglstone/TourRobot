//
//  AppDelegate.h
//  TourRobot
//
//  Created by 郭龙 on 16/1/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSocket.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) MainViewController *main;
@property (strong, nonatomic) UIViewController *main;

@end