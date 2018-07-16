//
//  SYPopTip+Transitions.h
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/6.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "SYPopTip.h"

/**
 SYPopTip  动画工具类
 */
@interface SYPopTip (Transitions)

- (void)sy_performShowAnimation:(void(^)(void))completion;

- (void)sy_performDismissAnimation:(void(^)(void))completion;

@end
