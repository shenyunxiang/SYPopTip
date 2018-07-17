//
//  ViewController.m
//  SYPopTip
//
//  Created by 沈云翔 on 2018/7/6.
//  Copyright © 2018年 syx. All rights reserved.
//

#import "ViewController.h"
#import <SYPopTip.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    UIButton *btn  = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(self.view.bounds.size.width / 2 - 25, self.view.bounds.size.width / 2 - 25, 50, 50);
    [btn addTarget:self action:@selector(test:) forControlEvents:(UIControlEventTouchUpInside)];
    btn.backgroundColor = [UIColor redColor];
}

- (void)test:(UIButton *)sender {
    SYPopTip *tip = [[SYPopTip alloc] init];
    tip.shouldDismissOnTapOutside = NO;
    tip.shouldShowMask = YES;
    [tip showWithText:@"ces" direction:(SYPopTipDirection_up) maxWidth:100 InView:self.view From:sender.frame duration:10];
    
    
}
- (void)tapAction{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
