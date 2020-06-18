//
//  UINavigationController+XT.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/31/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

@import ObjectiveC.runtime;
#import "UINavigationController+XT.h"

@implementation UINavigationController (XT)

+(instancetype) initWithLeftText:(NSString*) left leftIcon:(NSString*)leftIcon title:(NSString*) title rightText:(NSString*) rightText rightIcon:(NSString*)rightIcon target:(Class) targetPageClass{
    UINavigationController *uiNavigationController;
    // static dispatch_once_t onceToken; // 静态变量,初始化=0
    // 创建单例引用静态变量[dispatch_once:执行一次]
    //dispatch_once(&onceToken, ^{
        [Mylog info:@"创建导航Target类 ClassName=%@", [targetPageClass description]];
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
-(void)pushViewControllerFromTop:(UIViewController*)viewController{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;//可更改为其他方式
    transition.subtype = kCATransitionFromTop;//可更改为其他方式
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self pushViewController:viewController animated:NO];
}
-(void)popViewControllerFromTop{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromBottom;
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self popViewControllerAnimated:NO];
}
- (void)pushViewControllerFromLeft:(UIViewController *)viewController{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;//可更改为其他方式
    transition.subtype = kCATransitionFromLeft;//可更改为其他方式
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self pushViewController:viewController animated:NO];
}
-(void)popViewControllerFromRight{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self popViewControllerAnimated:NO];
}
//1.要是用push view controller ，首先必须确保根视图是NavigationController，不然是不可以用的。
//2.push与present都可以推出新的界面。
//3.present与dismiss对应，push和pop对应。
//4.present只能逐级返回，push所有视图由视图栈控制，可以返回上一级，也可以返回到根vc，其他vc。
//5.present一般用于不同业务界面的切换，push一般用于同一业务不同界面之间的切换。
@end
