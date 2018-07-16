//
//  SYPopTip.m
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/6.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "SYPopTip.h"
#import "SYPopTip+Transitions.h"
#import "SYPopTip+Draw.h"

static CGFloat DefaultBounceOffset = 8;
static CGFloat DefaultPulseOffset  = 1.1;
@interface SYPopTip ()
@property(nonatomic, copy) NSString                      *text;
@property(nonatomic, strong) NSAttributedString         *attributedText;
@property(nonatomic, assign) CGRect    textBounds;
//
@property(nonatomic, assign) BOOL           isAnimating;
@property(nonatomic, strong) NSTimer        *dismissTimer;

@property(nonatomic, strong) UILabel        *lable;
//配置信息
@property(nonatomic, strong) SYPopTipConfig        *popTipConfig;
//SYPopTip可占用的最大空间
@property(nonatomic, assign) CGFloat    maxWidth;;

@property(nonatomic, strong) NSMutableParagraphStyle        *paragraphStyle;

//手势
@property(nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property(nonatomic, strong) UITapGestureRecognizer        *tapRemoveGestureRecognizer;
@property(nonatomic, strong) UISwipeGestureRecognizer      *swipeGestureRecognizer;
//是否处于后台
@property(nonatomic, assign) BOOL    isApplicationInBackground;

@property(nonatomic, strong) UIView                     *customView;

@property(nonatomic, assign) BOOL    shouldBounce;

@end
@implementation SYPopTip
#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _construction];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _construction];
    }
    return self;
}
#pragma mark - Public Method

- (void)setConfigInfo:(void(^)(SYPopTipConfig *config))configBlock {
    self.popTipConfig = [[SYPopTipConfig alloc] init];
    if (configBlock) {
        configBlock(self.popTipConfig);
    }
}

- (void)showWithText:(NSString *)text
           direction:(SYPopTipDirection)direction
            maxWidth:(CGFloat)maxWidth
              InView:(UIView *)inView
                From:(CGRect)from
            duration:(NSTimeInterval)duration{
    
    _attributedText = nil;
    self.text = text;
    _direction = direction;
    _containerView = inView;
    self.maxWidth = maxWidth;
    if (self.customView) {
        [self.customView removeFromSuperview];
        _customView = nil;
    }
    self.from = from;
    
    [self showWithDuration:duration];
}

- (void)hide{
    [self hideWithForced:YES];
}

- (void)hideWithForced:(BOOL)forced {
    if (!forced && self.isAnimating) {
        return;
    }
    
    [self resetView];
    if (self.dismissTimer) {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
    }
    
    //移除手势
    if (self.tapRemoveGestureRecognizer) {
        [self.containerView removeGestureRecognizer:self.tapRemoveGestureRecognizer];
    }
    if (self.swipeGestureRecognizer) {
        [self.containerView removeGestureRecognizer:self.swipeGestureRecognizer];
    }
    
    void(^completion)(void)  = ^{
        if (self.customView) {
            [self.customView removeFromSuperview];
            self.customView = nil;
        }
        [self dismissActionAnimationWithCompletion:nil];
        if (self.backgroundMask) {
            [self.backgroundMask removeFromSuperview];
        }
        
        [self removeFromSuperview];
        [self.layer removeAllAnimations];
        self.transform = CGAffineTransformIdentity;
        self.isAnimating = NO;
        
    };
    
    if (self.isApplicationInBackground) {
        completion();
    } else {
        [self sy_performDismissAnimation:completion];
    }
        
    
}

- (void)updateText:(NSString *)text {
    self.text = text;
    [self updateBubble];
}
- (void)updateAttributedText:(NSAttributedString *)attributedText {
    self.attributedText = attributedText;
    [self updateBubble];
}
- (void)updateCustomView:(UIView *)customView {
    self.customView = customView;
    [self updateBubble];
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [self pathWithRect:rect
                                      frame:self.frame
                                  direction:self.direction
                                  arrowSize:self.popTipConfig.arrowSize
                              arrowPosition:self.arrowPosition
                                arrowRadius:self.popTipConfig.arrowRadius
                                borderWidth:self.popTipConfig.borderWidth
                                     radius:self.popTipConfig.cornerRadius];
    
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowOpacity = self.popTipConfig.shadowOpacity;
    self.layer.shadowRadius  = self.popTipConfig.shadowRadius;
    self.layer.shadowOffset  = self.popTipConfig.shadowOffset;
    self.layer.shadowColor   = self.popTipConfig.shadowColor.CGColor;
    
    [self.bubbleColor setFill];
    [path fill];
    [self.popTipConfig.borderColor setStroke];
    path.lineWidth = self.popTipConfig.borderWidth;
    [path stroke];
    
    self.paragraphStyle.alignment = self.textAlignment;
    NSDictionary *titleAttributes = @{NSFontAttributeName:self.popTipConfig.font,
                                      NSParagraphStyleAttributeName:self.paragraphStyle,
                                      NSForegroundColorAttributeName:self.textColor
                                      };
    
    if (self.text) {
        self.lable.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:titleAttributes];
    } else if (self.attributedText) {
        self.lable.attributedText = self.attributedText;
    }else {
        self.lable.attributedText = nil;
    }
}

#pragma mark - Private Method
- (void)_construction {
    _direction = SYPopTipDirection_up;
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.maskColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    /*
     * 动画
     */
    self.showAnimation = Show_scale;
    self.animationShow = 0.4;
    self.animationDismiss= 0.2;
    self.delayShow= 0;
    self.delayDismiss = 0;
    
    self.shouldDismissOnSwipeOutside =NO;
    self.shouldDismissOnTapOutside = YES;
    self.shouldDismissOnTap = YES;
}

- (void)_setupViews {
    if (!self.containerView) {
        return;
    }
    
    CGRect rect = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    if (self.direction == SYPopTipDirection_left) {
        CGFloat calculateNum =  self.from.origin.x -
                                self.popTipConfig.padding*2 -
                                [self horizontal_edgInsets]-
                                self.popTipConfig.arrowSize.width;
        self.maxWidth = MIN(self.maxWidth, calculateNum);
        
    }
    if (self.direction == SYPopTipDirection_right) {
        CGFloat calculateNum =  self.containerView.bounds.size.width -
                                self.from.origin.x -
                                self.from.size.width - 
                                self.popTipConfig.padding*2 -
                                [self horizontal_edgInsets] -
                                self.popTipConfig.arrowSize.width;
        self.maxWidth = MIN(self.maxWidth, calculateNum);
    }
    //计算文字的frame
    self.textBounds = [self textBoundsWithText:self.text
                                attributedText:self.attributedText
                                          view:self.customView
                                          font:self.popTipConfig.font
                                       padding:self.popTipConfig.padding
                                          edgs:self.popTipConfig.edgeInsets
                                      maxWidth:self.maxWidth];
    
    switch (self.direction) {
        case SYPopTipDirection_up:
        {
            NSArray *dimensions = [self VerticallyFrameList];
            rect = [[dimensions firstObject] CGRectValue];
            _arrowPosition = [[dimensions lastObject] CGPointValue];
            CGFloat anchor = self.arrowPosition.x / rect.size.width;
            self.layer.anchorPoint = CGPointMake(anchor, 1);
            self.layer.position = CGPointMake(self.layer.position.x+ rect.size.width*anchor, self.layer.position.y+rect.size.height/2);
        }
            break;
        case SYPopTipDirection_down:
        {
            NSArray *dimensions = [self VerticallyFrameList];
            rect = [[dimensions firstObject] CGRectValue];
            _arrowPosition = [[dimensions lastObject] CGPointValue];
            
            
            CGPoint textPoint = CGPointMake(self.textBounds.origin.x, self.textBounds.origin.y+self.popTipConfig.arrowSize.height);
            self.textBounds = CGRectMake(textPoint.x, textPoint.y, self.textBounds.size.width, self.textBounds.size.height);
            
            CGFloat anchor = self.arrowPosition.x / rect.size.width;
            self.layer.anchorPoint = CGPointMake(self.layer.position.x+rect.size.width*anchor, self.layer.position.y-rect.size.height/2);
            
        }
            break;
        case SYPopTipDirection_left:
        {
            NSArray *dimensions = [self HorizontallyFrameList];
            rect = [[dimensions firstObject] CGRectValue];
            _arrowPosition = [[dimensions lastObject] CGPointValue];
            CGFloat anchor = self.arrowPosition.y / rect.size.height;
            self.layer.anchorPoint = CGPointMake(1, anchor);
            self.layer.position = CGPointMake(self.layer.position.x-rect.size.width/2, self.layer.position.y+rect.size.height*anchor);
            
        }
            break;
        case SYPopTipDirection_right:
        {
            NSArray *dimensions = [self HorizontallyFrameList];
            rect = [[dimensions firstObject] CGRectValue];
            _arrowPosition = [[dimensions lastObject] CGPointValue];
            CGFloat anchor = self.arrowPosition.y / rect.size.height;
            
            self.layer.anchorPoint = CGPointMake(0, anchor);
            self.layer.position = CGPointMake(self.layer.position.x + rect.size.width / 2, self.layer.position.y + rect.size.height * anchor);
        }
            break;
        case SYPopTipDirection_none:
        {
            rect.size = CGSizeMake(self.textBounds.size.width+self.popTipConfig.padding*2+[self horizontal_edgInsets]+self.popTipConfig.borderWidth*2, self.textBounds.size.height+self.popTipConfig.padding*2+[self vertical_edgInsets]+self.popTipConfig.borderWidth*2);
            rect.origin = CGPointMake(CGRectGetMidX(self.from)-rect.size.width, CGRectGetMidY(self.from)-rect.size.height/2);
            
            rect = [self rectContained:rect];
            
            _arrowPosition = CGPointZero;
            
            self.layer.anchorPoint = CGPointMake(0.5, 0.5);
            self.layer.position = CGPointMake(CGRectGetMidX(self.from), CGRectGetMidY(self.from));
        }
            break;
        default:
            break;
    }
    
    self.lable.frame = self.textBounds;
    if (self.lable.superview == nil) {
        [self addSubview:self.lable];
    }

    self.frame = rect;
    
    if (self.customView) {
        self.customView.frame = self.textBounds;
    }
    
    if (!self.shouldShowMask) {
        [self.backgroundMask removeFromSuperview];
    } else {
        if (!self.backgroundMask) {
            _backgroundMask = [UIView new];
            self.backgroundMask.backgroundColor = self.maskColor;
        }
        self.backgroundMask.frame = self.containerView.bounds;
    }
    
    [self setNeedsLayout];
    
    //添加手势
    if (self.shouldDismissOnTap || self.shouldDismissOnTapOutside) {
        if (!self.tapGestureRecognizer) {
            self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            self.tapGestureRecognizer.cancelsTouchesInView = NO;
            [self addGestureRecognizer:self.tapGestureRecognizer];
        }
        if (self.shouldDismissOnTapOutside && !self.tapRemoveGestureRecognizer) {
            self.tapRemoveGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOutside:)];
        }
    }
    
    if (self.shouldDismissOnSwipeOutside && self.swipeGestureRecognizer == nil) {
        self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOutside:)];
        self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    
}
//重置View
- (void)resetView{
    [CATransaction begin];
    [self.layer removeAllAnimations];
    [CATransaction commit];
    self.transform = CGAffineTransformIdentity;
}
//显示 当SYPopTip 显现时的动画
- (void)startActionAnimation{
    
}
//去除 当SYPopTip 显现时的动画
- (void)dismissActionAnimationWithCompletion:(void(^)(void))completion{
    
    [UIView animateWithDuration:self.animationDismiss/2 delay:self.delayDismiss options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.layer removeAllAnimations];
        if (completion) {
            completion();
        }
    }];
}

- (void)updateBubble {
    
    if (self.shouldActionAnimation) {
        [self stopActionAnimationWith:^(void (^completion)(void)) {
            
            
            
        }];
    } else {
        [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            [self _setupViews];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)updateContentView {
    
}

- (void)stopActionAnimationWith:(void(^)(void(^completion)(void)))block {
    
}



- (CGRect)textBoundsWithText:(NSString *)text
              attributedText:(NSAttributedString *)attributedText
                        view:(UIView *)view
                        font:(UIFont *)font
                     padding:(CGFloat)padding
                        edgs:(UIEdgeInsets)edgs
                    maxWidth:(CGFloat)maxWidth {
    CGRect bounds = CGRectZero;
    if (text) {
        bounds = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil];
    }
    if (attributedText) {
        bounds = [attributedText boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    }
    if (view) {
        bounds = view.frame;
    }
    
    bounds.origin = CGPointMake(padding+edgs.left, padding+edgs.top);
    
    return CGRectMake(ceil(bounds.origin.x), ceil(bounds.origin.y),
                      ceil(bounds.size.width), ceil(bounds.size.height));
}

- (NSArray *)VerticallyFrameList{
    if (!self.containerView) return @[@(CGRectZero),@(CGPointZero)];
    //frame
    CGRect frame = CGRectZero;
    //
    CGFloat offset = self.popTipConfig.offset * (self.direction == SYPopTipDirection_up ? -1 : 1);
    //计算SYPopTip的Size
    frame.size = CGSizeMake(self.textBounds.size.width +
                            self.popTipConfig.padding*2 +
                            [self horizontal_edgInsets],
                            self.textBounds.size.height +
                            self.popTipConfig.padding*2 +
                            [self vertical_edgInsets] +
                            self.popTipConfig.arrowSize.height);
    //此时SYPopTip的centerX与from的保持一致
    CGFloat x = self.from.origin.x + self.from.size.width /2 - frame.size.width /2;
    //direction错误会使 x < 0
    if (x < 0) {
        x = 0;
    }
    //SYPopTip超出containerView
    if (x + frame.size.width > self.containerView.bounds.size.width) {
        x = self.containerView.bounds.size.width - frame.size.width;
    }
    
    if (self.direction == SYPopTipDirection_down) {
        frame.origin = CGPointMake(x, self.from.origin.y+self.from.size.height + offset);
    } else {
        frame.origin = CGPointMake(x, self.from.origin.y-frame.size.height + offset);
    }
    
    //ArrowPosition 此时X在SYPopTip的centerX
    CGPoint arrowPosition = CGPointMake(self.from.origin.x+ self.from.size.width/2 - frame.origin.x,
                                        (self.direction == SYPopTipDirection_up) ? frame.size.height : self.from.origin.y+self.from.size.height - frame.origin.y+offset);
    
    if (self.bubbleOffset > 0 && arrowPosition.x < self.bubbleOffset) {
        self.bubbleOffset = arrowPosition.x - self.popTipConfig.arrowSize.width;
    } else if (self.bubbleOffset < 0 && frame.size.width < fabs(self.bubbleOffset)) {
        self.bubbleOffset = -(arrowPosition.x - self.popTipConfig.arrowSize.width);
    } else if (self.bubbleOffset < 0 && (frame.origin.x-arrowPosition.x) < fabs(self.bubbleOffset)) {
        self.bubbleOffset = -(self.popTipConfig.arrowSize.width + 0);
    }
    
    CGFloat leftSpace = frame.origin.x - self.containerView.frame.origin.x;
    CGFloat rightSpace= self.containerView.frame.size.width - leftSpace -frame.size.width;
    
    if (self.bubbleOffset < 0 && leftSpace < fabs(self.bubbleOffset)) {
        self.bubbleOffset = - leftSpace + 0;
    } else if (self.bubbleOffset > 0 && rightSpace < self.bubbleOffset) {
        self.bubbleOffset = rightSpace - 0;
    }
    
    frame.origin.x += self.bubbleOffset;
    frame.size = CGSizeMake(frame.size.width + self.popTipConfig.borderWidth * 2, frame.size.height+self.popTipConfig.borderWidth*2);
    return @[@(frame), @(arrowPosition)];
}

- (NSArray *)HorizontallyFrameList{
    if (!self.containerView) return @[@(CGRectZero),@(CGPointZero)];
    
    CGRect frame = CGRectZero;
    CGFloat offset = self.popTipConfig.offset * (self.direction == SYPopTipDirection_left ? -1:1);
    
    frame.size = CGSizeMake(self.textBounds.size.width+self.popTipConfig.padding*2+[self horizontal_edgInsets]+self.popTipConfig.arrowSize.height, self.textBounds.size.height+self.popTipConfig.padding*2+[self vertical_edgInsets]);
    
    CGFloat x = self.direction == SYPopTipDirection_left ? self.from.origin.x - frame.size.width + offset : self.from.origin.x + self.from.size.width + offset;
    CGFloat y = self.from.origin.y + self.from.size.height / 2 - frame.size.height / 2;
    
    if (y < 0) {
        y = 0;
    }
    if (y + frame.size.height > self.containerView.bounds.size.height) {
        y = self.containerView.bounds.size.height - frame.size.height ;
    }
    frame.origin = CGPointMake(x, y);
    
    CGPoint arrowPosition = CGPointMake(self.direction == SYPopTipDirection_left ? self.from.origin.x - frame.origin.x + offset : self.from.origin.x + self.from.size.width-frame.origin.x+offset, self.from.origin.y+self.from.size.height/2-frame.origin.y);
    
    if (self.bubbleOffset > 0 && arrowPosition.y < self.bubbleOffset) {
        self.bubbleOffset = arrowPosition.y - self.popTipConfig.arrowSize.width;
    } else if (self.bubbleOffset < 0 && frame.size.width < fabs(self.bubbleOffset)) {
        self.bubbleOffset = -(arrowPosition.y - self.popTipConfig.arrowSize.width);
    }
    
    CGFloat topSpace = frame.origin.y - self.containerView.frame.origin.y;
    CGFloat bottomSpace= self.containerView.frame.size.height - topSpace -frame.size.height;
    
    
    if (self.bubbleOffset < 0 && topSpace < fabs(self.bubbleOffset)) {
        self.bubbleOffset = - topSpace + 0;
    } else if (self.bubbleOffset > 0 && bottomSpace < self.bubbleOffset) {
        self.bubbleOffset = bottomSpace - 0;
    }
    
   
    
    frame.origin.y += self.bubbleOffset;
    frame.size = CGSizeMake(frame.size.width+self.popTipConfig.borderWidth*2, frame.size.height+self.popTipConfig.borderWidth*2);
    
    return @[@(frame), @(arrowPosition)];
}

- (void)showWithDuration:(NSTimeInterval)duration {
    self.isAnimating = YES;
    if (self.dismissTimer) {
        [self.dismissTimer invalidate];
    }
    [self setNeedsLayout];
    
    [self sy_performShowAnimation:^{
        
        if (self.tapRemoveGestureRecognizer) {
            
            if (self.backgroundMask) {
                [self.backgroundMask addGestureRecognizer:self.tapRemoveGestureRecognizer];
            } else {
                [self.containerView addGestureRecognizer:self.tapRemoveGestureRecognizer];
            }
            
            
        }
        if (self.swipeGestureRecognizer) {
            [self.containerView addGestureRecognizer:self.swipeGestureRecognizer];
        }
        
        self.isAnimating = NO;
        //
        if (duration > 0) {
            self.dismissTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(hide) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.dismissTimer forMode:(NSRunLoopCommonModes)];
        }
        
    }];
    
}

- (CGFloat)horizontal_edgInsets {
    return self.popTipConfig.edgeInsets.left+self.popTipConfig.edgeInsets.right;
}

- (CGFloat)vertical_edgInsets {
    return self.popTipConfig.edgeInsets.top+self.popTipConfig.edgeInsets.bottom;
}

- (CGRect)rectContained:(CGRect)rect {
    if(!self.containerView) return CGRectZero;
    
    CGRect finalRect = rect;
    
    if ((rect.origin.x) < self.containerView.frame.origin.x) {
        finalRect.origin.x = 0;
    }
    if ((rect.origin.y) < self.containerView.frame.origin.y) {
        finalRect.origin.y = 0;
    }
    if ((rect.origin.x + rect.size.width) > (self.containerView.frame.origin.x + self.containerView.frame.size.width)) {
        finalRect.origin.x = self.containerView.frame.origin.x + self.containerView.frame.size.width - rect.size.width - 0;
    }
    if ((rect.origin.y + rect.size.height) > (self.containerView.frame.origin.y + self.containerView.frame.size.height)) {
        finalRect.origin.y = self.containerView.frame.origin.y + self.containerView.frame.size.height - rect.size.height - 0;
    }
    
    return finalRect;
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - Setter && Getter
- (void)setText:(NSString *)text {
    _text = text;
    self.accessibilityLabel = text;
    [self setNeedsLayout];
}

- (void)setFrom:(CGRect)from {
    _from = from;
    [self _setupViews];
}

- (UILabel *)lable {
    if (_lable == nil) {
        _lable = [[UILabel alloc] init];
        _lable.numberOfLines = 0;
    }
    return _lable;
}

- (SYPopTipConfig *)popTipConfig {
    if (!_popTipConfig) {
        _popTipConfig = [SYPopTipConfig globalConfig];
    }
    return _popTipConfig;
}

- (NSMutableParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    }
    return _paragraphStyle;
}
#pragma mark - Gesture
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (self.shouldDismissOnTap) {
        [self hide];
    }
    if (self.tapHandler) {
        self.tapHandler(self);
    }
}

- (void)handleTapOutside:(UITapGestureRecognizer *)sender {
    if (self.shouldDismissOnTapOutside) {
        [self hide];
    }
    if (self.tapOutsideHandler) {
        self.tapOutsideHandler(self);
    }
    
}
- (void)handleSwipeOutside:(UISwipeGestureRecognizer *)sender{
    if (self.shouldDismissOnSwipeOutside) {
        [self hide];
    }
    if (self.swipeOutsideHandler) {
        self.swipeOutsideHandler(self);
    }
}
#pragma mark - Notification
- (void)handleApplicationActive{
    self.isApplicationInBackground = NO;
}
- (void)handleApplicationResignActive{
    self.isApplicationInBackground = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - SYPopTipConfig
@implementation SYPopTipConfig

+ (SYPopTipConfig *)globalConfig
{
    static SYPopTipConfig *config;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        config = [SYPopTipConfig new];
    });
    
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.arrowSize = CGSizeMake(8, 8);
    self.cornerRadius = 4;
    self.padding = 6;
    self.edgeInsets = UIEdgeInsetsZero;
    self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    return self;
}

@end
