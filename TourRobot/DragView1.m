//
//  DragView1.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/12.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DragView1.h"
#import "PinchView.h"

typedef NS_ENUM(NSInteger, DRAGEIMAGETYPER) {
    DRAGEIMAGETYPER_desk,
    DRAGEIMAGETYPER_chair,
    DRAGEIMAGETYPER_table
};

typedef NS_OPTIONS(NSUInteger, TOUCHTYPE) {
    TOUCHTYPE_NONE    = 1 << 0, //0
    TOUCHTYPE_MOVE    = 1 << 1, // 2
    TOUCHTYPE_PINCH   = 1 << 2, // 4
};

@interface DragView1 (){
    int touchType;
}

@end

@implementation DragView1
@synthesize beginpoint;

//- (DragView1 *)viewWithFrame:(CGRect)frame image:(UIImage *)image{
//    DragView1 *view = [[DragView1 alloc] initWithFrame:frame];
//    view.backgroundColor = [UIColor redColor];
//    UIImageView *subV = [[UIImageView alloc] initWithImage:image];
//    [view addSubview: subV];
//    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, subV.frame.size.width, subV.frame.size.height);
//    view.frame = rect;
//    
//    self.pinchView= [[PinchView alloc] initWithImage:[UIImage imageNamed:@"analogue_bg"]];
//    int width = 20;
//    self.pinchView.frame =CGRectMake(0 + rect.size.width - width, 0 + rect.size.height - width, width, width);
//    [view addSubview:self.pinchView];
//    return view;
//}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        PinchView *pv = [[PinchView alloc] initWithImage:[UIImage imageNamed:@"analogue_bg"]];
        pv.userInteractionEnabled = YES;
        int width = 20;
        pv.frame =CGRectMake(0 + self.frame.size.width - width, 0 + self.frame.size.height - width, width, width);
        [self addSubview:pv];
        return self;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [touches anyObject];
    beginpoint = [touch locationInView:self];
    touchType = [self pointIsInView:beginpoint view:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *to = [touches anyObject];
    switch (touchType) {
        case TOUCHTYPE_MOVE:{
            CGPoint mpt = [to locationInView:self];
            CGRect frame = [self frame];
            frame.origin.x += mpt.x - beginpoint.x;
            frame.origin.y += mpt.y - beginpoint.y;
            self.frame = frame;
            break;
        }
        case TOUCHTYPE_PINCH:{
            CGPoint mpt = [to locationInView:self];
            CGRect frame = [self frame];
            frame.size.width  = mpt.x ;
            frame.size.height = mpt.y ;
            self.frame = frame;
            
            //rotation
//            CGPoint mpt2 = [to locationInView:self.superview];
//            float disX = mpt2.x - self.center.x;
//            float disY = mpt2.y - self.center.y;
//            float angel = atan2f(disY, disX);
//            float a = angel/M_PI *180;
//            
//            CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI);
//            self.transform = transform;
            
            break;
        }
        default:
            break;
    }
    
}

- (TOUCHTYPE) pointIsInView :(CGPoint )point view:(UIView *)view{
    if ((ABS(point.x - view.frame.size.width) + ABS(point.y - view.frame.size.height)) <= 100) {
        return TOUCHTYPE_PINCH;
    }
    if (point.x > 0 && point.y > 0 && point.x <= view.frame.size.width && point.y <= view.frame.size.height) {
        return TOUCHTYPE_MOVE;
    }
    return TOUCHTYPE_NONE;
}


@end
