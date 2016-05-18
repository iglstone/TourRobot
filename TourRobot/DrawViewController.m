//
//  DrawViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/12.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DrawViewController.h"
#import "DragView1.h"
#import "ZDStickerView.h"

#define TABLEVIEWWIDTH 100
#define TOUCHPINCHTHRESHHOLD 10
#define TABLEVIEWTOPOFFSET 0//30

//typedef NS_OPTIONS(NSUInteger, TOUCHTYPE) {
//    TOUCHTYPE_NONE    = 1 << 0, //0
//    TOUCHTYPE_MOVE    = 1 << 1, // 2
//    TOUCHTYPE_PINCH   = 1 << 2, // 4
//};

@interface DrawViewController () <UITableViewDataSource, UITableViewDelegate,ZDStickerViewDelegate>{
    UIView *backgroundRightView;
    CGPoint begainPoint;
    BOOL canEdit;
    int touchType;
    
    UITableView *leftTabelView;
    NSInteger screenHeight;
    NSInteger screenWidth;
    
    UIView *tmpPickedView;
    NSMutableArray *zdsticks;
    
    UIView *rightView;
}

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    canEdit = NO;
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    zdsticks  = [NSMutableArray new];
    
    backgroundRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgroundRightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundRightView];

    CGRect rect = CGRectMake(200, 30, 100, 100);
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"music"]];
    view.frame = rect;
    ZDStickerView *sticker = [[ZDStickerView alloc] initWithFrame:rect];
    sticker.contentView = view;
    sticker.stickerViewDelegate = self;
    sticker.translucencySticker = NO;
    sticker.minHeight = 50;
    sticker.minWidth = 50;
    [sticker showEditingHandles];
    [backgroundRightView addSubview:sticker];
    [zdsticks addObject:sticker];
    
    
    UIButton *btn = [UIButton new];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.width.mas_equalTo(@100);
    }];
    [btn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    leftTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, TABLEVIEWTOPOFFSET, TABLEVIEWWIDTH, screenHeight - TABLEVIEWTOPOFFSET*2) style:UITableViewStylePlain];
    leftTabelView.frame = CGRectMake(0, TABLEVIEWTOPOFFSET, 0, screenHeight - TABLEVIEWTOPOFFSET * 2);
    [self.view addSubview:leftTabelView];
    leftTabelView.dataSource = self;
    leftTabelView.delegate = self;
    leftTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    leftTabelView.showsVerticalScrollIndicator = NO;
    leftTabelView.backgroundColor = [UIColor clearColor];
    
    
    CGRect rect2 = CGRectMake(screenWidth - TABLEVIEWWIDTH, 0, 100, screenHeight);
    rightView = [[UIView alloc] initWithFrame:rect2];
    rightView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rightView];
    
    
}

//- (TOUCHTYPE) pointIsInView :(CGPoint )point view:(UIView *)view{
//    if ((ABS(point.x - view.frame.size.width) + ABS(point.y - view.frame.size.height)) <= 20) {
//        return TOUCHTYPE_PINCH;
//    }
//    if (point.x > 0 && point.y > 0 && point.x <= view.frame.size.width && point.y <= view.frame.size.height) {
//        return TOUCHTYPE_MOVE;
//    }
//    return TOUCHTYPE_NONE;
//}

#pragma mark - btn taped
- (void) btnTaped:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"编辑"]) {
        canEdit = YES;
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        
        [UIView beginAnimations:@"table" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        leftTabelView.frame = CGRectMake(0, TABLEVIEWTOPOFFSET, TABLEVIEWWIDTH, screenHeight - TABLEVIEWTOPOFFSET * 2);
        backgroundRightView.frame = CGRectMake( TABLEVIEWWIDTH, 0, screenWidth - TABLEVIEWWIDTH, screenHeight );
        [UIView commitAnimations];
        
        for (ZDStickerView *st in zdsticks) {
            [st showEditingHandles];
        }
        
        
        return;
    }
    if ([btn.titleLabel.text isEqualToString:@"完成"]) {
        canEdit = NO;
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor orangeColor];
        
        [UIView beginAnimations:@"table" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        leftTabelView.frame = CGRectMake(0, TABLEVIEWTOPOFFSET, 0, screenHeight - TABLEVIEWTOPOFFSET * 2);
        backgroundRightView.frame = CGRectMake(0, 0, screenWidth , screenHeight );
        [UIView commitAnimations];
        
        for (ZDStickerView *st in zdsticks) {
            [st hideEditingHandles];
        }
        
        
        return;
    }
}

#pragma  mark - table dele
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *st = @"leftabtlview";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:st];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftTableView"];
    }
//    cell.textLabel.text = @"桌子";
    cell.imageView.image = [UIImage imageNamed:@"desk_red"];
    cell.backgroundColor = [UIColor orangeColor];
    cell.imageView.image = [self imagePinch:[UIImage imageNamed:@"desk_white"] width:60 height:60];
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [self imagePinch:[UIImage imageNamed:@"desk_red"] width:60 height:60];
            break;
        case 1:
            cell.imageView.image = [self imagePinch:[UIImage imageNamed:@"robot_2"] width:60 height:60];
            break;
        case 2:
            cell.imageView.image = [self imagePinch:[UIImage imageNamed:@"robot_3"] width:60 height:60];
        default:
            break;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *pickedView = [cell imageView];
    UIImage *new = [self imagePinch:[pickedView image] width:pickedView.frame.size.width height:pickedView.frame.size.height];
    tmpPickedView = [[UIImageView alloc] initWithImage:new];
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
    CGRect rect1 = [tableView convertRect:rectInTableView toView:self.view];
    ZDStickerView *zt = [[ZDStickerView alloc] initWithFrame:rect1];
    zt.contentView = tmpPickedView;
    zt.stickerViewDelegate = self;
    [zt showEditingHandles];
    zt.translucencySticker = NO;
    zt.preventsPositionOutsideSuperview = YES;
    [backgroundRightView addSubview:zt];
    [zdsticks addObject:zt];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//not pinch image in scale
- (UIImage *)imagePinch:(UIImage *)img width:(int)width height:(int)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO ,0.0);
    CGRect imageRect = CGRectMake(0, 0,width, height);
    [img drawInRect:imageRect];
    UIImage *new = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return new;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
