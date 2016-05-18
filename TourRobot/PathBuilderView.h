//
//  PathBuilderView.h
//  AnimatedPath
//
//  Created by Andrew Hershberger on 11/13/13.
//  Copyright (c) 2013 Two Toasters, LLC. All rights reserved.
//

@import UIKit;

@class ShapeView;
@class PointViews;

@interface PathBuilderView : UIView

@property (nonatomic, strong, readonly) ShapeView *pathShapeView;
@property (nonatomic, strong, readonly) ShapeView *prospectivePathShapeView;
@property (nonatomic, strong, readonly) ShapeView *pointsShapeView;

- (void)showLabels;//显示points 的label
- (void)hidenLabel;//隐藏Label
- (void)combineStartToEndPoints;//首尾闭合
- (void)combineTwoPointsWithStartId:(int)startId endId:(int)endId ;
@end
