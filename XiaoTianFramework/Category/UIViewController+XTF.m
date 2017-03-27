//
//  UIViewController.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "UIViewController+XTF.h"

@implementation UIViewController (XTF)

// 关闭页面
-(IBAction) dismissViewController:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
