//
//  GlViewController.m
//  AnimatedPath
//
//  Created by 郭龙 on 16/5/5.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "GlViewController.h"
#import "PathBuilderView.h"
#import "ShapeView.h"
#import "PointViews.h"
//static CFTimeInterval const kDuration = 2.0;
//static CFTimeInterval const kInitialTimeOffset = 2.0;

#define SHOWLABEL @"显示索引"
#define HIDENSLABEL @"隐藏索引"
#define COMBINEPOINTS @"闭合"
#define COMBINETWOPOINTS @"闭合两点"

@interface GlViewController ()
@property (nonatomic, readonly) PathBuilderView *pathBuilderView;
@end

@implementation GlViewController
- (void)loadView
{
    self.view = [[PathBuilderView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pathBuilderView.pathShapeView.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.pathBuilderView.prospectivePathShapeView.shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    self.pathBuilderView.pointsShapeView.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    
    UIButton *doneBtn = [UIButton new];
    [self.view addSubview:doneBtn];
    doneBtn.backgroundColor = [UIColor blueColor];
    [doneBtn setTitle:SHOWLABEL forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.left.equalTo(self.view).offset(20);
    }];
    
    UIButton *combineBtn = [UIButton new];
    [self.view addSubview:combineBtn];
    combineBtn.backgroundColor = [UIColor blueColor];
    [combineBtn setTitle:COMBINEPOINTS forState:UIControlStateNormal];
    [combineBtn addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [combineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(doneBtn);
        make.left.equalTo(doneBtn.mas_right).offset(20);
    }];
    
    UIButton *combineTwoPoints = [UIButton new];
    [self.view addSubview:combineTwoPoints];
    combineTwoPoints.backgroundColor = [UIColor blueColor];
    [combineTwoPoints setTitle:COMBINETWOPOINTS forState:UIControlStateNormal];
    [combineTwoPoints addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [combineTwoPoints mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(combineBtn);
        make.left.equalTo(combineBtn.mas_right).offset(20);
    }];
}

- (void)buttonTaped :(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:SHOWLABEL]) {
        [self.pathBuilderView showLabels];
        [btn setTitle:HIDENSLABEL forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor grayColor];
        return;
    }
    if ([btn.titleLabel.text isEqualToString:HIDENSLABEL]) {
        [self.pathBuilderView hidenLabel];
        [btn setTitle:SHOWLABEL forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blueColor];
        return;
    }
    if ([btn.titleLabel.text isEqualToString:COMBINEPOINTS]) {
        [self.pathBuilderView combineStartToEndPoints];
        return;
    }
    if ([btn.titleLabel.text isEqualToString:COMBINETWOPOINTS]) {
        [self.pathBuilderView combineTwoPointsWithStartId:3 endId:5];
        return;
    }
}

//- (void)drawText
//{
//    NSString *text = @"水印文字";
//    //	[[UIColor whiteColor]set];
//    // 新建一个UIColor
//    UIColor *color = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
//    [color set];
//    
//    [text drawInRect:CGRectMake(0, 170, 300, 20) withFont:[UIFont systemFontOfSize:12] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
//}

- (PathBuilderView *)pathBuilderView
{
    return (PathBuilderView *)self.view;
}

@end
