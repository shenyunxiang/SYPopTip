//
//  SYPopTip+Draw.h
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/9.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "SYPopTip.h"

@interface SYPopTip (Draw)

- (UIBezierPath *)pathWithRect:(CGRect)rect
                         frame:(CGRect)frame
                     direction:(SYPopTipDirection)direction
                     arrowSize:(CGSize)arrowSize
                 arrowPosition:(CGPoint)arrowPosition
                   arrowRadius:(CGFloat)arrowRadius
                   borderWidth:(CGFloat)borderWidth
                        radius:(CGFloat)radius ;

@end
