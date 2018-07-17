//
//  SYPopTip.h
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/6.
//  Copyright © 2018年 syx. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class SYPopTipConfig;
/**
  SYPopTip的方向
 */
typedef NS_ENUM(NSInteger, SYPopTipDirection) {
    SYPopTipDirection_up = 0,
    SYPopTipDirection_down,
    SYPopTipDirection_left,
    SYPopTipDirection_right,
    SYPopTipDirection_none
};
/**
 SYPopTip显示的动画方式
 */
typedef NS_ENUM(NSInteger, SYPopTipShowAnimation) {
    Show_none  = 0,
    Show_scale,
    Show_transition,
    Show_fadeIn,
    Show_custom,
    
};
/**
 SYPopTip消失的动画方式
 */
typedef NS_ENUM(NSInteger, SYPopTipHideAnimation) {
    Hide_none = 0,
    Hide_scale ,
    Hide_fadeOut,
    Hide_custom
    
};

typedef NS_ENUM(NSInteger, SYPopTipActionAnimation) {
    Action_none = 0,
    Action_bounce,
    Action_pulse
    
};

#pragma mark - SYPopTip
@interface SYPopTip : UIView

//default center
@property(nonatomic, assign) NSTextAlignment                textAlignment;
//default whiteColor
@property(nonatomic, strong) UIColor                        *textColor;

@property(nonatomic, assign) BOOL                           shouldShowMask;
@property(nonatomic, strong, readonly) UIView               *backgroundMask;
@property(nonatomic, strong) UIColor                        *maskColor;

@property(nonatomic, assign, readonly) CGRect               from;
@property(nonatomic, weak, readonly) UIView                 *containerView;
@property(nonatomic, assign, readonly) SYPopTipDirection    direction;

/*
 *  动画相关属性
 */
@property(nonatomic, assign) SYPopTipShowAnimation      showAnimation;
@property(nonatomic, assign) SYPopTipHideAnimation      disAnimation;
@property(nonatomic, assign) BOOL                       shouldActionAnimation;
@property(nonatomic, assign) NSTimeInterval             animationShow;
@property(nonatomic, assign) NSTimeInterval             animationDismiss;
@property(nonatomic, assign) NSTimeInterval             delayShow;
@property(nonatomic, assign) NSTimeInterval             delayDismiss;
/*
 *  气泡相关属性
 */
@property(nonatomic, assign,readonly) CGPoint           arrowPosition;//气泡箭头顶点位置
@property(nonatomic, assign) CGFloat                    bubbleOffset;//气泡偏移
@property(nonatomic, strong) UIColor                    *bubbleColor;//气泡颜色
/*
 * 手势相关属性
 */
@property(nonatomic, assign) BOOL           shouldDismissOnTap;
@property(nonatomic, assign) BOOL           shouldDismissOnTapOutside;
@property(nonatomic, assign) BOOL           shouldDismissOnSwipeOutside;
/*
 *  callBack 回调
 */
@property(nonatomic, copy) void(^tapHandler)(SYPopTip *popTip);
@property(nonatomic, copy) void(^tapOutsideHandler)(SYPopTip *popTip);
@property(nonatomic, copy) void(^swipeOutsideHandler)(SYPopTip *popTip);
@property(nonatomic, copy) void(^appearHandler)(SYPopTip *popTip);
@property(nonatomic, copy) void(^dismissHandler)(SYPopTip *popTip);
//
@property(nonatomic, copy) void(^showAnimationHandler)(SYPopTip *popTip,void(^completion)(void));


- (void)setConfigInfo:(void(^)(SYPopTipConfig *config))configBlock;

- (void)showWithText:(NSString *)text
           direction:(SYPopTipDirection)direction
            maxWidth:(CGFloat)maxWidth
              InView:(UIView *)inView
                From:(CGRect)from
            duration:(NSTimeInterval)duration;

@end

#pragma mark - SYPopTipConfig
@interface SYPopTipConfig : NSObject
//SYPopTip 文字使用的字体
@property(nonatomic, strong) UIFont             *font;
//SYPopTip的边缘弧度(default=4)
@property(nonatomic, assign) CGFloat            cornerRadius;
//(default=6)
@property(nonatomic, assign) CGFloat            padding;
//(default=ZERO)
@property(nonatomic, assign) UIEdgeInsets       edgeInsets;
//SYPopTip 距离from的偏移(default=0)
@property(nonatomic, assign) CGFloat            offset;
//(default=0)
@property(nonatomic, assign) CGFloat            bubbleOffset;
//(default=0)
@property(nonatomic, assign) CGFloat            borderWidth;
@property(nonatomic, strong) UIColor            *borderColor;
//arrow的size(default=(8,8))
@property(nonatomic, assign) CGSize             arrowSize;
@property(nonatomic, assign) CGFloat            arrowRadius;

/*
 *  阴影相关属性
 */
@property(nonatomic, strong) UIColor            *shadowColor;
@property(nonatomic, assign) CGSize             shadowOffset;
@property(nonatomic, assign) CGFloat            shadowRadius;
@property(nonatomic, assign) CGFloat            shadowOpacity;


+ (SYPopTipConfig *)globalConfig;

@end

NS_ASSUME_NONNULL_END
