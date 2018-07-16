//
//  SYPopTip+Transitions.m
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/6.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "SYPopTip+Transitions.h"

@implementation SYPopTip (Transitions)

- (void)sy_performShowAnimation:(void(^)(void))completion{
    switch (self.showAnimation) {
        case Show_scale:
            [self sy_showScaleWithCompletion:completion];
            break;
        case Show_fadeIn:
            [self sy_showFadeInWithCompletion:completion];
            break;
        case Show_transition:
            [self sy_showTransitionWithCompletion:completion];
            break;
        case Show_custom:
        {
            if (self.backgroundMask) {
                [self.containerView addSubview:self.backgroundMask];
            }
            [self.containerView addSubview:self];
            if (self.showAnimationHandler) {
                self.showAnimationHandler(self, completion);
            }
        }
            break;
        case Show_none:
        {
            if (self.backgroundMask) {
                [self.containerView addSubview:self.backgroundMask];
            }
            [self.containerView addSubview:self];
            if (completion) {
                completion();
            }
        }
            break;
        default:
            break;
    }
}

- (void)sy_performDismissAnimation:(void(^)(void))completion {
    switch (self.disAnimation) {
        case Hide_none:
            if (completion) {
                completion();
            }
            break;
        case Hide_scale:
            [self sy_disScaleWithCompletion:completion];
            break;
        case Hide_fadeOut:
            [self sy_disFadeOutWithCompletion:completion];
            break;
        case Hide_custom:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private Method
- (void)sy_showScaleWithCompletion:(void(^)(void))completion {
    self.transform = CGAffineTransformMakeScale(0, 0);
    if (self.backgroundMask) {
        [self.containerView addSubview:self.backgroundMask];
    }
    [self.containerView addSubview:self];
    
    [UIView animateWithDuration:self.animationShow delay:self.delayShow usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.transform = CGAffineTransformIdentity;
        if (self.backgroundMask) {
            self.backgroundMask.alpha = 1;
        }
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)sy_showFadeInWithCompletion:(void(^)(void))completion  {
    if (self.backgroundMask) {
        [self.containerView addSubview:self.backgroundMask];
    }
    [self.containerView addSubview:self];
    
    self.alpha = 0;
    
    [UIView animateWithDuration:self.animationShow delay:self.delayShow options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.alpha = 1;
        if (self.backgroundMask) {
            self.backgroundMask.alpha = 1;
        }
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)sy_showTransitionWithCompletion:(void(^)(void))completion {
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    
    switch (self.direction) {
        case SYPopTipDirection_up:
            self.transform = CGAffineTransformTranslate(self.transform, 0, - self.from.origin.y);
            break;
        case SYPopTipDirection_down:
        case SYPopTipDirection_none:
            self.transform = CGAffineTransformTranslate(self.transform, 0, self.containerView.frame.size.height - self.from.origin.y);
            break;
        case SYPopTipDirection_left:
            self.transform = CGAffineTransformTranslate(self.transform, self.from.origin.x, 0);
            break;
        case SYPopTipDirection_right:
            self.transform = CGAffineTransformTranslate(self.transform, self.containerView.frame.size.width - self.from.origin.x, 0);
            break;
        default:
            break;
    }
    
    if (self.backgroundMask) {
        [self.containerView addSubview:self.backgroundMask];
    }
    [self.containerView addSubview:self];
    
    [UIView animateWithDuration:self.animationShow delay:self.delayShow usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.transform = CGAffineTransformIdentity;
        if (self.backgroundMask) {
            self.backgroundMask.alpha = 1;
        }
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
}

- (void)sy_disScaleWithCompletion:(void(^)(void))completion {
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:self.animationShow delay:self.delayShow usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        if (self.backgroundMask) {
            self.backgroundMask.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)sy_disFadeOutWithCompletion:(void(^)(void))completion {
    self.alpha =1;
    
    [UIView animateWithDuration:self.animationShow delay:self.delayShow options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        
        self.alpha = 0;
        if (self.backgroundMask) {
            self.backgroundMask.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}


@end
