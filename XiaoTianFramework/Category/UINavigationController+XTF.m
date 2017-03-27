//
//  XTF+UINavigationController.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/31/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

@import ObjectiveC.runtime;
#import "UINavigationController+XTF.h"

@implementation UINavigationController (XTF)

+(instancetype) initWithLeftText:(NSString*) left leftIcon:(NSString*)leftIcon title:(NSString*) title rightText:(NSString*) rightText rightIcon:(NSString*)rightIcon target:(Class) targetPageClass{
    UINavigationController *uiNavigationController;
    // static dispatch_once_t onceToken; // 静态变量,初始化=0
    // 创建单例引用静态变量[dispatch_once:执行一次]
    //dispatch_once(&onceToken, ^{
        [XTFMylog info:@"创建导航Target类 ClassName=%@", [targetPageClass description]];
        UIViewController *viewController = [[targetPageClass alloc] init];
        UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:uiNavigationController action:@selector(dismissViewController)];
        [viewController.navigationItem setLeftBarButtonItem:dismiss];
        uiNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //});
    return uiNavigationController;
}

// 关闭页面
-(void) dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
