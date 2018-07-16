//
//  SYPopTip+Draw.m
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/9.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "SYPopTip+Draw.h"

@interface CornerPoint : NSObject
@property(nonatomic, assign) CGPoint    center;
@property(nonatomic, assign) CGFloat    startAngle;
@property(nonatomic, assign) CGFloat    endAngle;
@end
@implementation CornerPoint
@end

@implementation SYPopTip (Draw)

- (UIBezierPath *)pathWithRect:(CGRect)rect
                         frame:(CGRect)frame
                     direction:(SYPopTipDirection)direction
                     arrowSize:(CGSize)arrowSize
                 arrowPosition:(CGPoint)arrowPosition
                   arrowRadius:(CGFloat)arrowRadius
                   borderWidth:(CGFloat)borderWidth
                        radius:(CGFloat)radius {
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGRect baloonFrame = CGRectZero;
    
    switch (direction) {
        case SYPopTipDirection_none:
        {
            baloonFrame = CGRectMake(borderWidth, borderWidth, frame.size.width - 2*borderWidth, frame.size.height-2*borderWidth);
            path = [UIBezierPath bezierPathWithRoundedRect:baloonFrame cornerRadius:radius];
        }
            break;
        case SYPopTipDirection_up:
        {
            baloonFrame = CGRectMake(0, 0, rect.size.width - borderWidth*2, rect.size.height-borderWidth*2 - arrowSize.height);
            CGPoint arrowStartPoint = CGPointMake(arrowPosition.x+arrowSize.width/2, arrowPosition.y-arrowSize.height);
            CGPoint arrowEndPoint   = CGPointMake(arrowPosition.x-arrowSize.width/2, arrowPosition.y-arrowSize.height);
            CGPoint arrowVertex     = arrowPosition;
            CornerPoint *cornerPoint= [self roundCornerCircleCenterWithStart:arrowStartPoint vertex:arrowVertex end:arrowEndPoint radius:arrowRadius];
            //1.
            [path moveToPoint:CGPointMake(arrowStartPoint.x, arrowStartPoint.y)];
            //2.
            [path addArcWithCenter:cornerPoint.center radius:arrowRadius startAngle:cornerPoint.startAngle endAngle:cornerPoint.endAngle clockwise:YES];
            //3.
            [path addLineToPoint:CGPointMake(arrowEndPoint.x, arrowEndPoint.y)];
            //4.
            [path addLineToPoint:CGPointMake(CGRectGetMinX(baloonFrame) + radius + borderWidth, CGRectGetMaxY(baloonFrame))];
            //5.
            [path addArcWithCenter:CGPointMake(borderWidth + radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:M_PI /2 endAngle:M_PI clockwise:YES];
            //6.
            [path addLineToPoint:CGPointMake( borderWidth, CGRectGetMinY(baloonFrame)+ radius + borderWidth)];
            //7.
            [path addArcWithCenter:CGPointMake(CGRectGetMinY(baloonFrame)+radius+borderWidth, CGRectGetMinY(baloonFrame)+radius) radius:radius startAngle:M_PI endAngle:M_PI *1.5  clockwise:YES];
            //8.
            [path addLineToPoint:CGPointMake(baloonFrame.size.width - radius, CGRectGetMinY(baloonFrame))];
            //9.
            [path addArcWithCenter:CGPointMake(baloonFrame.size.width - radius, CGRectGetMinY(baloonFrame)+radius) radius:radius startAngle:M_PI *1.5 endAngle:0  clockwise:YES];
            //10.
            [path addLineToPoint:CGPointMake(baloonFrame.size.width, CGRectGetMaxY(baloonFrame)-radius-borderWidth)];
            //11.
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(baloonFrame)-radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:0 endAngle:M_PI/2 clockwise:YES];
            //12.
            [path closePath];
            
        }
            break;
        case SYPopTipDirection_down:
        {
            baloonFrame = CGRectMake(0, arrowSize.height, rect.size.width-borderWidth*2, rect.size.height-borderWidth*2 - arrowSize.height);
            CGPoint arrowStartPoint = CGPointMake(arrowPosition.x-arrowSize.width/2,        arrowPosition.y+arrowSize.height);
            CGPoint arrowEndPoint   = CGPointMake(arrowPosition.x+arrowSize.width/2, arrowPosition.y+arrowSize.height);
            CGPoint arrowVertex     = arrowPosition;
            CornerPoint *cornerPoint= [self roundCornerCircleCenterWithStart:arrowStartPoint vertex:arrowVertex end:arrowEndPoint radius:arrowRadius];
            
            // 1: Arrow starting point
            [path moveToPoint:CGPointMake(arrowStartPoint.x, arrowStartPoint.y)];
            // 2: Arrow vertex arc
            [path addArcWithCenter:cornerPoint.center radius:arrowRadius startAngle:cornerPoint.startAngle endAngle:cornerPoint.endAngle clockwise:YES];
            // 3: End drawing arrow
            [path addLineToPoint:CGPointMake(arrowEndPoint.x, arrowEndPoint.y)];
            // 4: Top right line
            [path addLineToPoint:CGPointMake(baloonFrame.size.width - radius, CGRectGetMinY(baloonFrame))];
            // 5: Top right arc
            [path addArcWithCenter:CGPointMake(baloonFrame.size.width-radius, CGRectGetMinY(baloonFrame)+radius) radius:radius startAngle:M_PI*1.5  endAngle:0 clockwise:YES];
            // 6: Right line
            [path addLineToPoint:CGPointMake(baloonFrame.size.width ,CGRectGetMaxY(baloonFrame)-radius-borderWidth)];
            // 7: Bottom right arc
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(baloonFrame)-radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:0  endAngle:M_PI/2 clockwise:YES];
            // 8: Bottom line
            [path addLineToPoint:CGPointMake(CGRectGetMinX(baloonFrame)+radius+borderWidth ,CGRectGetMaxY(baloonFrame))];
            // 9: Bottom left arc
            [path addArcWithCenter:CGPointMake(borderWidth-radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:M_PI/2  endAngle:M_PI clockwise:YES];
            // 10: Left line
            [path addLineToPoint:CGPointMake(borderWidth ,CGRectGetMinY(baloonFrame)+radius+borderWidth)];
            // 11: Top left arc
            [path addArcWithCenter:CGPointMake(borderWidth+radius, CGRectGetMinY(baloonFrame)+radius) radius:radius startAngle:M_PI endAngle:M_PI*1.5 clockwise:YES];
            // 13: Close path
            [path closePath];
            
        }
            break;
        case SYPopTipDirection_left:
        {
            baloonFrame = CGRectMake(0, 0, rect.size.width-arrowSize.height-borderWidth*2, rect.size.height-borderWidth*2);
            CGPoint arrowStartPoint = CGPointMake(arrowPosition.x-arrowSize.height,arrowPosition.y-arrowSize.width/2);
            CGPoint arrowEndPoint   = CGPointMake(arrowPosition.x-arrowSize.height, arrowPosition.y+arrowSize.width/2);
            CGPoint arrowVertex     = arrowPosition;
            CornerPoint *cornerPoint= [self roundCornerCircleCenterWithStart:arrowStartPoint vertex:arrowVertex end:arrowEndPoint radius:arrowRadius];
            // 1: Arrow starting point
            [path moveToPoint:CGPointMake(arrowStartPoint.x, arrowStartPoint.y)];
            // 2: Arrow vertex arc
            [path addArcWithCenter:cornerPoint.center radius:arrowRadius startAngle:cornerPoint.startAngle endAngle:cornerPoint.endAngle clockwise:YES];
            // 3: End drawing arrow
            [path addLineToPoint:CGPointMake(arrowEndPoint.x, arrowEndPoint.y)];
            // 4: Right bottom line
            [path addLineToPoint:CGPointMake(baloonFrame.size.width, CGRectGetMaxY(baloonFrame)-radius-borderWidth)];
            // 5: Bottom right arc
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(baloonFrame)-radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:0 endAngle:M_PI/2 clockwise:YES];
            // 6: Bottom line
            [path addLineToPoint:CGPointMake(CGRectGetMinX(baloonFrame)+radius+borderWidth, CGRectGetMaxY(baloonFrame))];
            // 7: Bottom left arc
            [path addArcWithCenter:CGPointMake(borderWidth+radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:YES];
            // 8: Left line
            [path addLineToPoint:CGPointMake(borderWidth, CGRectGetMinY(baloonFrame)+radius+borderWidth)];
            // 9: Top left arc
            [path addArcWithCenter:CGPointMake(borderWidth+radius, CGRectGetMinY(baloonFrame)+radius+borderWidth) radius:radius startAngle:M_PI endAngle:M_PI*1.5 clockwise:YES];
            // 10: Top line
            [path addLineToPoint:CGPointMake(baloonFrame.size.width-radius, CGRectGetMinY(baloonFrame)+borderWidth)];
            // 11: Top right arc
            [path addArcWithCenter:CGPointMake(baloonFrame.size.width-radius, CGRectGetMinY(baloonFrame)+radius+borderWidth) radius:radius startAngle:M_PI*1.5 endAngle:0 clockwise:YES];
            // 12: Close path
            [path closePath];
            
        }
            break;
        case SYPopTipDirection_right:
        {
            baloonFrame = CGRectMake(arrowSize.height, 0, rect.size.width-arrowSize.height-borderWidth*2, rect.size.height-borderWidth*2);
            CGPoint arrowStartPoint = CGPointMake(arrowPosition.x+arrowSize.height,arrowPosition.y+arrowSize.width/2);
            CGPoint arrowEndPoint   = CGPointMake(arrowPosition.x+arrowSize.height, arrowPosition.y-arrowSize.width/2);
            CGPoint arrowVertex     = arrowPosition;
            CornerPoint *cornerPoint= [self roundCornerCircleCenterWithStart:arrowStartPoint vertex:arrowVertex end:arrowEndPoint radius:arrowRadius];
            
            // 1: Arrow starting point
            [path moveToPoint:CGPointMake(arrowStartPoint.x, arrowStartPoint.y)];
            // 2: Arrow vertex arc
            [path addArcWithCenter:cornerPoint.center radius:arrowRadius startAngle:cornerPoint.startAngle endAngle:cornerPoint.endAngle clockwise:YES];
            // 3: End drawing arrow
            [path addLineToPoint:CGPointMake(arrowEndPoint.x, arrowEndPoint.y)];
            // 6: Left top line
            [path addLineToPoint:CGPointMake(CGRectGetMinX(baloonFrame), CGRectGetMinY(baloonFrame)+radius+borderWidth)];
            // 7: Top left arc
            [path addArcWithCenter:CGPointMake(CGRectGetMinX(baloonFrame)+radius, CGRectGetMinY(baloonFrame)+radius+borderWidth) radius:radius startAngle:M_PI endAngle:M_PI*1.5 clockwise:YES];
            // 8: Top line
            [path addLineToPoint:CGPointMake(baloonFrame.size.width-radius, CGRectGetMinY(baloonFrame)+borderWidth)];
            // 9: Top right arc
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(baloonFrame)-radius, CGRectGetMinY(baloonFrame)+radius+borderWidth) radius:radius startAngle:M_PI*1.5 endAngle:0 clockwise:YES];
            // 10: Right line
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(baloonFrame), CGRectGetMaxY(baloonFrame)-radius)];
            // 11: Bottom right arc
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(baloonFrame)-radius, CGRectGetMaxY(baloonFrame)-radius ) radius:radius startAngle:0 endAngle:M_PI/2  clockwise:YES];
            // 4: Bottom line
            [path addLineToPoint:CGPointMake(CGRectGetMinX(baloonFrame)+radius, CGRectGetMaxY(baloonFrame))];
            // 5: Bottom left arc
            [path addArcWithCenter:CGPointMake(CGRectGetMinX(baloonFrame)+radius, CGRectGetMaxY(baloonFrame)-radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:YES];
            //close
            [path closePath];
        }
            break;
        default:
            break;
    }
    
    
    return path;
}

- (CornerPoint *)roundCornerCircleCenterWithStart:(CGPoint)start
                                         vertex:(CGPoint)vertex
                                            end:(CGPoint)end
                                         radius:(CGFloat)radius{
    
    CGFloat firstLineAngle = atan2(vertex.y - start.y, vertex.x - start.x);
    CGFloat secondLineAngle= atan2(end.y - vertex.y , end.x - vertex.x);
    
    CGVector firstLineOffset =  CGVectorMake(-sin(firstLineAngle) * radius, cos(firstLineAngle) * radius);
    CGVector secondLineOffset=  CGVectorMake(-sin(secondLineAngle) * radius, cos(secondLineAngle) * radius);
    
    
    CGFloat x1 = start.x + firstLineOffset.dx;
    CGFloat y1 = start.y + firstLineOffset.dy;
    
    CGFloat x2 = vertex.x + firstLineOffset.dx;
    CGFloat y2 = vertex.y + firstLineOffset.dy;
    
    CGFloat x3 = vertex.x + secondLineOffset.dx;
    CGFloat y3 = vertex.y + secondLineOffset.dy;
    
    CGFloat x4 = end.x + secondLineOffset.dx;
    CGFloat y4 = end.y + secondLineOffset.dy;
    
    CGFloat intersectionX = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    CGFloat intersectionY = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    
    CornerPoint *cornerPoint = [[CornerPoint alloc] init];
    cornerPoint.center = CGPointMake(intersectionX, intersectionY);
    cornerPoint.startAngle = firstLineAngle - M_PI / 2;
    cornerPoint.endAngle   = secondLineAngle - M_PI / 2;
    return cornerPoint;
    
}

@end
