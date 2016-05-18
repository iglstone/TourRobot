//
//  PinchView.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/13.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "PinchView.h"
typedef NS_OPTIONS(NSUInteger, TOUCHTYPE) {
    TOUCHTYPE_NONE    = 1 << 0, //0
    TOUCHTYPE_PINCH   = 1 << 2, // 4
};


@interface PinchView (){
    CGPoint beginpoint;
    int touchType;
}

@end

@implementation PinchView

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    beginpoint = [touch locationInView:self];
    touchType = [self pointIsInView:beginpoint view:self];
    [self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *to = [touches anyObject];
    CGPoint mpt = [to locationInView:self];
    CGRect frame = [self frame];
    frame.origin.x += mpt.x - beginpoint.x;
    frame.origin.y += mpt.y - beginpoint.y;
    self.frame = frame;
    
    
    if (touchType) {
        [self.superview touchesMoved:touches withEvent:event];
    }
        else ;
        
}

- (TOUCHTYPE) pointIsInView :(CGPoint )point view:(UIView *)view{
    if (point.x > 0 && point.y > 0 && point.x <= view.frame.size.width && point.y <= view.frame.size.height) {
        return YES;
    }
    return NO;
}

@end
