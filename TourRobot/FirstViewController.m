//
//  FirstViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "FirstViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "ConnectStatesCell.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "UdpClient.h"

@interface FirstViewController ()
{
    UdpClient *udpClient;
}
@property (nonatomic) ServerSocket *server;
@property (nonatomic) HitControl *control;
@property (nonatomic) BOOL isStart;

@end

@implementation FirstViewController
@synthesize control;
@synthesize isStart;

#pragma mark - lifecicle
- (instancetype)init {
    self = [super init];
    if (self) {
        self  = [super init];
        udpClient = [UdpClient sharedUdpSocket];
        control = [HitControl sharedControl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToForground:) name:NOTICE_FORGRAOUND object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MainViewController *main =(MainViewController *) self.tabBarController;
    if (![CommonsFunc isDeviceIpad]) {
        main.views.hidden = NO;
        main.m_debugLabel.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    isStart = NO;
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIImageView *robot1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"robot_1.png"]];
    [self.view addSubview:robot1];
    [robot1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(10);
        if (![CommonsFunc isDeviceIpad]) {
            make.size.mas_equalTo(CGSizeMake(150, 220));
        }
    }];
    
    UIImageView *robot2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"robot_2.png"]];
    [self.view addSubview:robot2];
    [robot2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(5);
    }];
    
    UIImageView *robot3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"robot_3.png"]];
    [self.view addSubview:robot3];
    [robot3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(80);
    }];
    if (![CommonsFunc isDeviceIpad]) {
        robot2.hidden = YES;
        robot3.hidden = YES;
    }
    
    UIImageView *robot4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:robot4];
    [robot4 mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(50);
        }else {
            make.centerX.equalTo(self.view).offset(screenWidth/8);
            make.top.equalTo(self.view).offset(20);
        }
        
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    UILabel *hitLable = [UILabel new];
    hitLable.text = @"芜湖哈特机器人研究院";
    [self.view addSubview:hitLable];
    [hitLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(robot4.mas_bottom).offset(5);
        make.centerX.equalTo(robot4);
    }];
    
    UILabel *ipLabel= [UILabel new];
    ipLabel.text = @"本机ip地址";
    [self.view addSubview:ipLabel];
    [ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-100);
        if ([CommonsFunc isDeviceIpad]) {
            make.left.equalTo(self.view).offset(150);
        }else
            make.left.equalTo (self.view).offset(20);
    }];
    
    UITextField *ipTextField = [UITextField new];
    NSString *serverIp = [self deviceIPAdress];
    ipTextField.backgroundColor = [CommonsFunc colorOfSystemBackground];
    [ipTextField setEnabled:NO];
    ipTextField.text = serverIp;
    [self.view addSubview:ipTextField];
    [ipTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ipLabel.mas_right).offset(20);
        make.centerY.equalTo(ipLabel);
    }];

    UILabel *portLabel = [UILabel new];
    portLabel.text = @"端口";
    [self.view addSubview:portLabel];
    [portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ipLabel);
        make.top.equalTo(ipLabel.mas_bottom).offset(15);
    }];
    
    UITextField *portTextField = [UITextField new];
    NSInteger portNum = LISTEN_PORT;
    portTextField.enabled = NO;
    portTextField.text = [NSString stringWithFormat:@"%ld", (long)portNum];//@"1234";
    portTextField.backgroundColor = [CommonsFunc colorOfSystemBackground];
    [self.view addSubview:portTextField];
    [portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ipTextField);
        make.centerY.equalTo(portLabel);
    }];
    
    UIButton *startBtn = [UIButton new];
    [self.view addSubview:startBtn];
    [startBtn setTitle:@"开始服务" forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ipLabel);
        make.left.equalTo(ipTextField.mas_right).offset(20);
    }];
    [startBtn addTarget:self action:@selector(playBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton *settingBtn = [UIButton new];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [self.view addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.bottom.equalTo(self.view).offset(-60);
            make.left.equalTo(self.view).offset(20);
        } else {
            make.top.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
        }
    }];
    [settingBtn addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:NOTICE_LOGOUTSUCCESS object:nil];
    
}

#pragma mark - noti
/**
 *  返回该程序后的重新监听
 *  @param
 */
- (void)backToForground :(NSNotification *)noti {
    NSLog(@"backToForground noti");
    [control startListen];
}

#pragma mark - action.
- (void)logout:(id)sender {
    MainViewController *main =(MainViewController *) self.tabBarController;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 在delegate中初始化新的controller
    // 修改rootViewController
    // [delegate.window addSubview:delegate.main.view];
    [main.view removeFromSuperview];
    delegate.window.rootViewController = [LoginViewController new];
}

- (void)setting :(id) sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[SettingViewController new]];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playBtnTaped:(UIButton *)btn {
    NSLog(@"image taped");
    
    [udpClient sentMessage:@"glGuolong"];
//    Byte *byte;
//    byte = {1,2,3,5};
//    byte[2] = 5;
    
//    if (isStart == NO) {
//        isStart = YES;
//        [control startListen];
//        [btn setBackgroundColor:[UIColor lightGrayColor]];
//        [btn setTitle:@"停止服务" forState:UIControlStateNormal];
//        
//    }else
//    {
//        isStart = NO;
//        [control stopAll];
//        [btn setBackgroundColor:[UIColor clearColor]];
//        [btn setTitle:@"开始服务" forState:UIControlStateNormal];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) { // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    NSLog(@"server的IP是：%@", address);
    return address;  
}

@end
