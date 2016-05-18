//
//  PointViews.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/7.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "PointViews.h"

@implementation PointViews
@synthesize idAndAngelLabel;

//secend
- (void)drawRect:(CGRect)rect {
//    float width = rect.size.width/2;
//    CGContextRef ref = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(ref, [[UIColor blueColor] CGColor]);//画线颜色
//    CGContextSetLineWidth(ref, 2);//画笔宽度
//    CGContextSetFillColorWithColor(ref, [[UIColor redColor]CGColor]);//填充颜色
//    CGContextAddArc(ref, rect.origin.x+width, rect.origin.y+width, width-1, 0, 2*M_PI, 0);
//    CGContextDrawPath(ref, kCGPathFillStroke);//填充+绘线

    //获得当前画板
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    //颜色
    CGContextSetRGBStrokeColor(ctx,0.2,0.2,0.2,1.0);
    //画线的宽度
    CGContextSetLineWidth(ctx,0.25);
    //开始写字
//    UIFont *ft = [UIFont systemFontOfSize:12];
//    [@"我是文字" drawInRect:CGRectMake(0,0,rect.size.width,30) withFont:ft];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBFillColor (context,  1, 0, 0, 1.0);//设置填充颜色
//    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
//    UIFont *font = [UIFont fontWithName: @"Courier" size: 13];
//    [@"igl" drawInRect:CGRectMake(100, 100, 100, 20) withAttributes:[[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName,nil]];
//    CGContextDrawPath(context, kCGPathStroke);
//    CGContextStrokePath(context);
    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(100, 100) radius:20 startAngle:0 endAngle:M_PI clockwise:0];
//    [path fill];

}

//first
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.idAndAngelLabel = [UILabel new];
//        idAndAngelLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:idAndAngelLabel];
//        idAndAngelLabel.text = @"l:20,0:100";
//        [idAndAngelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.mas_bottom);
//            make.centerX.equalTo(self);
//            make.size.mas_equalTo(CGSizeMake(100, 20));
//        }];
//        return self;
//    }
//    return self;
//}

@end

