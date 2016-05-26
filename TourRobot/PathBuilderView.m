//
//  PathBuilderView.m
//  AnimatedPath
//
//  Created by Andrew Hershberger on 11/13/13.
//  Copyright (c) 2013 Two Toasters, LLC. All rights reserved.
//

#import "PathBuilderView.h"
#import "PointViews.h"
#import "ShapeView.h"
static CGFloat const kDistanceThreshold = 50.0;
static CGFloat const kPointDiameter = 7.0;

#define POINTLABELCOLOR [UIColor redColor]
#define PATHLABELCOLOR [UIColor blueColor]

@interface PathBuilderView () {
    NSMutableArray *m_pointLabelArray;
    BOOL canEdit;
    UIBezierPath *lineBezierPath;
    UIBezierPath *pointPath;
    NSValue *m_newPointValue;
    
}
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSValue *prospectivePointValue;
@property (nonatomic) NSUInteger indexOfSelectedPoint;
@property (nonatomic) CGVector touchOffsetForSelectedPoint;
@property (nonatomic, strong) NSTimer *pressTimer;
@property (nonatomic) BOOL ignoreTouchEvents;

@end

@implementation PathBuilderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _points = [[NSMutableArray alloc] init];
        m_pointLabelArray = [[NSMutableArray alloc] init];
        self.multipleTouchEnabled = NO;
        lineBezierPath = [UIBezierPath new];
        pointPath = [[UIBezierPath alloc] init];

        _ignoreTouchEvents = NO;
        _indexOfSelectedPoint = NSNotFound;
        canEdit = YES;

        _pathShapeView = [[ShapeView alloc] init];
        _pathShapeView.shapeLayer.fillColor = nil;
        _pathShapeView.backgroundColor = [UIColor clearColor];
        _pathShapeView.opaque = NO;
        _pathShapeView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pathShapeView];

        _prospectivePathShapeView = [[ShapeView alloc] init];
        _prospectivePathShapeView.shapeLayer.fillColor = nil;
        _prospectivePathShapeView.backgroundColor = [UIColor clearColor];
        _prospectivePathShapeView.opaque = NO;
        _prospectivePathShapeView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_prospectivePathShapeView];

        _pointsShapeView = [[ShapeView alloc] init];
        _pointsShapeView.backgroundColor = [UIColor clearColor];
        _pointsShapeView.opaque = NO;
        _pointsShapeView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pointsShapeView];

        NSDictionary *views = NSDictionaryOfVariableBindings(_pathShapeView, _prospectivePathShapeView, _pointsShapeView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pathShapeView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_prospectivePathShapeView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pointsShapeView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_pathShapeView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_prospectivePathShapeView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_pointsShapeView]|" options:0 metrics:nil views:views]];
    }
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    self.pointsShapeView.shapeLayer.fillColor = self.tintColor.CGColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.ignoreTouchEvents) {
        return;
    }
    if (!canEdit) {
        m_newPointValue = [self pointValueWithTouches:touches];
        [self updatePaths];
        return;
    }
    NSValue *pointValue = [self pointValueWithTouches:touches];
    
    NSIndexSet *indexes = [self.points indexesOfObjectsPassingTest:^BOOL(NSValue *existingPointValue, NSUInteger idx, BOOL *stop) {
        CGPoint point = [pointValue CGPointValue];
        CGPoint existingPoint = [existingPointValue CGPointValue];
        CGFloat distance = ABS(point.x - existingPoint.x) + ABS(point.y - existingPoint.y);
        return distance < kDistanceThreshold;
    }];
    
    if ([indexes count] > 0) { //Tap and hold existing points to remove them.
        self.indexOfSelectedPoint = [indexes lastIndex];
        NSValue *existingPointValue = [self.points objectAtIndex:self.indexOfSelectedPoint];
        CGPoint point = [pointValue CGPointValue];
        CGPoint existingPoint = [existingPointValue CGPointValue];
        self.touchOffsetForSelectedPoint = CGVectorMake(point.x - existingPoint.x, point.y - existingPoint.y);

        self.pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(pressTimerFired:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
    else {
        self.prospectivePointValue = pointValue;
    }

    [self updatePaths];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.ignoreTouchEvents) {
        return;
    }
    if (!canEdit) {
        m_newPointValue = [self pointValueWithTouches:touches];
        [self updatePaths];
        return;
    }

    [self.pressTimer invalidate];
    self.pressTimer = nil;

    NSValue *pointValue = [self pointValueWithTouches:touches];

    if (self.indexOfSelectedPoint != NSNotFound) {
        NSValue *offsetPointValue = [self pointValueByRemovingOffset:self.touchOffsetForSelectedPoint fromPointValue:pointValue];
        [self.points replaceObjectAtIndex:self.indexOfSelectedPoint withObject:offsetPointValue];
    }
    else {
        self.prospectivePointValue = pointValue;
    }
    
    [self updatePaths];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.ignoreTouchEvents) {
        self.ignoreTouchEvents = NO;
        return;
    }
    if (!canEdit) {
        m_newPointValue = nil;
        [self updatePaths];
        return;
    }

    [self.pressTimer invalidate];
    self.pressTimer = nil;

    self.indexOfSelectedPoint = NSNotFound;
    self.prospectivePointValue = nil;

    [self updatePaths];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.ignoreTouchEvents) {
        self.ignoreTouchEvents = NO;
        return;
    }
    if (!canEdit) {//显示label的时候不能编辑
        m_newPointValue = [self pointValueWithTouches:touches];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:[[self.points objectAtIndex:3] CGPointValue]];
        [path addLineToPoint:[m_newPointValue CGPointValue]];
        [lineBezierPath appendPath:path];
        self.pathShapeView.shapeLayer.path = lineBezierPath.CGPath;
        [pointPath appendPath:[UIBezierPath bezierPathWithArcCenter:m_newPointValue.CGPointValue radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
        return;
    }

    [self.pressTimer invalidate];
    self.pressTimer = nil;

    NSValue *pointValue = [self pointValueWithTouches:touches];
    
    if (self.indexOfSelectedPoint != NSNotFound) {
        NSValue *offsetPointValue = [self pointValueByRemovingOffset:self.touchOffsetForSelectedPoint fromPointValue:pointValue];
        [self.points replaceObjectAtIndex:self.indexOfSelectedPoint withObject:offsetPointValue];
        self.indexOfSelectedPoint = NSNotFound;
    }
    else {
        [self.points addObject:pointValue];
        self.prospectivePointValue = nil;
    }
    [self updatePaths];
}

#pragma mark - Helper Methods

- (void)updatePaths
{
    {
        /*写文字*/
        UIFont *font = [UIFont fontWithName: @"Courier" size: 13];
//        UIBezierPath *pointPath = [[UIBezierPath alloc] init];
        [@"iglxxxx" drawInRect:CGRectMake(0 , 0, 100, 20) withAttributes:[[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName,nil]];
        for (NSValue *pointValue in self.points) {
            CGPoint point = [pointValue CGPointValue];
            [pointPath appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
        }
        self.pointsShapeView.shapeLayer.path = pointPath.CGPath; //draw points by bezieer path
    }
    
    if ([self.points count] >= 2) {
        UIBezierPath *lineBezierPath2 = [[UIBezierPath alloc] init];
        [lineBezierPath2 moveToPoint:[[self.points firstObject] CGPointValue]];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [self.points count] - 1)];//excepet 0
        [self.points enumerateObjectsAtIndexes:indexSet
                                       options:0
                                    usingBlock:^(NSValue *pointValue, NSUInteger idx, BOOL *stop) {
                                        [lineBezierPath2 addLineToPoint:[pointValue CGPointValue]];//form 0 to 1 to 2 to 3...
                                    }];
        self.pathShapeView.shapeLayer.path = lineBezierPath2.CGPath;//draw line with bezier path
        lineBezierPath = lineBezierPath2;
    }
    else {
        self.pathShapeView.shapeLayer.path = nil;
    }
    
    if ([self.points count] >= 1 && self.prospectivePointValue) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:[[self.points lastObject] CGPointValue]];
        CGPoint point = [self.prospectivePointValue CGPointValue];
        [path addLineToPoint:point];
        self.prospectivePathShapeView.shapeLayer.path = path.CGPath;
    }
    else {
        self.prospectivePathShapeView.shapeLayer.path = nil;
    }
    
    if (m_newPointValue) {
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:[[self.points objectAtIndex:3] CGPointValue]];
        CGPoint point = [m_newPointValue CGPointValue];
        [path addLineToPoint:point];
        self.prospectivePathShapeView.shapeLayer.path = path.CGPath;
    }
}

#pragma mark - Action Methods

- (void)pressTimerFired:(NSTimer *)timer
{
    [self.pressTimer invalidate];
    self.pressTimer = nil;
    
    [self.points removeObjectAtIndex:self.indexOfSelectedPoint];
    self.indexOfSelectedPoint = NSNotFound;
    self.ignoreTouchEvents = YES; //when find long tap a ponit nearby the point ,ignore the touch
    
    [self updatePaths];
}

#pragma mark - views and show
- (void)showLabels{
    for (int i = 0; i < self.points.count; i++) {
        CGPoint startPt  = [[self.points objectAtIndex:i] CGPointValue];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startPt.x, startPt.y, 100, 30)];
        label.text = [NSString stringWithFormat:@"p:%d-x:%f,y:%f",i,startPt.x,startPt.y];
        label.layer.backgroundColor = POINTLABELCOLOR.CGColor;//  [UIColor redColor].CGColor;
        [self addSubview:label];
        
        if (self.points.count <=1 ) {
            continue;
        }
        CGPoint endPt;
        if (i == self.points.count-1) {
            endPt = [[self.points objectAtIndex:0] CGPointValue];
        }else
            endPt = [[self.points objectAtIndex:i+1] CGPointValue];
        CGPoint middlePt = CGPointMake((startPt.x + endPt.x)/2, (startPt.y + endPt.y)/2);
        UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(middlePt.x, middlePt.y, 100, 30)];
        middleLabel.text = [NSString stringWithFormat:@"long:%f,angel:%f",[self calCulateDistance:startPt endPoint:endPt],30.0];
        middleLabel.layer.backgroundColor = PATHLABELCOLOR.CGColor;//  [UIColor redColor].CGColor;
        [self addSubview:middleLabel];
    }
    canEdit = false;
}

- (float)calCulateDistance:(CGPoint )spt endPoint:(CGPoint)ept {
    float x = ABS(spt.x - ept.x);
    float y = ABS(spt.y - ept.y);
    float distance = sqrtf(x*x + y*y);
    return distance;
}

- (void)hidenLabel {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    canEdit = true;
}

- (void)combineStartToEndPoints {
    if (self.points.count <= 2) {
        return;
    }
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:[[self.points firstObject] CGPointValue]];
    [path addLineToPoint:[[self.points lastObject] CGPointValue]];
    [lineBezierPath appendPath:path];
    self.pathShapeView.shapeLayer.path = lineBezierPath.CGPath;
}

- (void)combineTwoPointsWithStartId:(int)startId endId:(int)endId {
    if (startId >= self.points.count || endId >= self.points.count || endId == startId || abs(endId - startId) ==1 ) {
        NSLog(@"wrong ids");
        return;
    }
    CGPoint endPt = [[self.points objectAtIndex:endId] CGPointValue];
    [self combinePointWithId:startId endPoint:endPt];
}

- (void)combinePointWithId:(int)startId endPoint:(CGPoint)endPoint {
    if (startId >= self.points.count) {
        NSLog(@"wrong start id");
        return;
    }
    CGPoint startPt = [[self.points objectAtIndex:startId] CGPointValue];
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:startPt];
    [path addLineToPoint:endPoint];
    [lineBezierPath appendPath:path];
    self.pathShapeView.shapeLayer.path = lineBezierPath.CGPath;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((startPt.x + endPoint.x)/2, (startPt.y + endPoint.y)/2, 100, 30)];
    label.text = [NSString stringWithFormat:@"long:%f,angel:%f",[self calCulateDistance:startPt endPoint:endPoint],30.0];
    label.layer.backgroundColor = [UIColor redColor].CGColor;
    [self addSubview:label];
}




- (NSValue *)pointValueWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    return [NSValue valueWithCGPoint:point];
}

- (NSValue *)pointValueByRemovingOffset:(CGVector)offset fromPointValue:(NSValue *)pointValue
{
    CGPoint point = [pointValue CGPointValue];
    CGPoint offsetPoint = CGPointMake(point.x - offset.dx, point.y - offset.dy);
    return [NSValue valueWithCGPoint:offsetPoint];
}

@end
