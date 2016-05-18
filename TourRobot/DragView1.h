//
//  DragView1.h
//  TourRobot
//
//  Created by 郭龙 on 16/5/12.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragView1 : UIImageView
@property (nonatomic) CGPoint beginpoint;

@property (nonatomic) UIView *pinchView;
@property (nonatomic) UIView *rotateView;

//- (DragView1 *)viewWithFrame:(CGRect)frame image:(UIImage *)image ;
@end
