//
//  UIViewController+XT.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "UIViewController+XT.h"
#import <objc/runtime.h>
#import "UtilMBProgressHUD.h"

@implementation UIViewController (XT)
/// 统一获取一个UIViewController实例(引入扩展类,重写本方法)
+ (instancetype)getInstance{
    return [[UIViewController alloc] init];
}
/// 从指定的storyboard中或者指定Id的UIViewController
+(instancetype) getInstance:(NSString*)storyboardId storyboard:(NSString*)stroryboardName{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:stroryboardName bundle:NSBundle.mainBundle];
    return [storyboard instantiateViewControllerWithIdentifier:storyboardId];
}

// dynamic Property Associsted Get/Set(not auto property value)
@dynamic callBackViewDidLoad;
/// 触发ViewDidLoad时回调
-(ViewControllerCallBack) callBackViewDidLoad{
    return objc_getAssociatedObject(self, @selector(callBackViewDidLoad));
}
/// 设置触发ViewDidLoad时回调
- (void)setCallBackViewDidLoad:(ViewControllerCallBack)callBackViewDidLoad{
    objc_setAssociatedObject(self, @selector(callBackViewDidLoad), callBackViewDidLoad, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewDidAppear;
- (ViewControllerCallBack)callBackViewDidAppear{
    return objc_getAssociatedObject(self, @selector(callBackViewDidAppear));
}
- (void)setCallBackViewDidAppear:(ViewControllerCallBack)callBackViewDidAppear{
    objc_setAssociatedObject(self, @selector(callBackViewDidAppear), callBackViewDidAppear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewWillAppear;
- (ViewControllerCallBack)callBackViewWillAppear{
    return objc_getAssociatedObject(self, @selector(callBackViewWillAppear));
}
- (void)setCallBackViewWillAppear:(ViewControllerCallBack)callBackViewWillAppear{
    objc_setAssociatedObject(self, @selector(callBackViewWillAppear), callBackViewWillAppear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewWillDisappear;
- (ViewControllerCallBack)callBackViewWillDisappear{
    return objc_getAssociatedObject(self, @selector(callBackViewWillDisappear));
}
- (void)setCallBackViewWillDisappear:(ViewControllerCallBack)callBackViewWillDisappear{
    objc_setAssociatedObject(self, @selector(callBackViewWillDisappear), callBackViewWillDisappear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewDidDisappear;
- (ViewControllerCallBack)callBackViewDidDisappear{
    return objc_getAssociatedObject(self, @selector(callBackViewDidDisappear));
}
- (void)setCallBackViewDidDisappear:(ViewControllerCallBack)callBackViewDidDisappear{
    objc_setAssociatedObject(self, @selector(callBackViewDidDisappear), callBackViewDidDisappear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackDealloc;
- (ViewControllerCallBack)callBackDealloc{
    return objc_getAssociatedObject(self, @selector(callBackDealloc));
}
- (void)setCallBackDealloc:(ViewControllerCallBack)callBackDealloc{
    objc_setAssociatedObject(self, @selector(callBackDealloc), callBackDealloc, OBJC_ASSOCIATION_COPY);
}
/// 获取当前APP的顶层VC控制器(用于present)
+(UIViewController*)getTopViewController{
    UIViewController *resultVC;
    UIViewController* (^_topViewController)(UIViewController *);//declare block strong
    __block __weak typeof(_topViewController) __topViewController;//__block __weak struct Block引用
    //
    _topViewController = ^UIViewController* (UIViewController * vc){//init block
        if ([vc isKindOfClass:[UINavigationController class]]) {//NVC的顶层VC
            return __topViewController([(UINavigationController *)vc topViewController]);
        } else if ([vc isKindOfClass:[UITabBarController class]]) {//TBC的选中VC
            return __topViewController([(UITabBarController *)vc selectedViewController]);
        } else {
            return vc;
        }
        return nil;
    };
    __topViewController = _topViewController;//__weak reference
    // APP 根VC
    resultVC = _topViewController([[UIApplication sharedApplication].keyWindow rootViewController]);
    while (resultVC.presentedViewController) {
        resultVC = _topViewController(resultVC.presentedViewController);
    }
    return resultVC;
}
/// 添加点击背景收起键盘事件(必须重写onTapViewHideKeyboard)
- (void)addTapViewHideKeyboard:(SEL)selector{
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector?selector:@selector(onTapViewHideKeyboard)];
    [tap setCancelsTouchesInView:NO];//内部的View可点击
    [self.view addGestureRecognizer:tap];
}
-(void)onTapViewHideKeyboard{}
/// MBProgressHUD弹出文本提示
- (void)showToast:(NSString *)toast{
    [UtilMBProgressHUD showToast:toast view:self.view];
}
/// MBProgressHUD弹出文本提示
- (void)showToast:(NSString *)toast with:(NSString *)imageName textColor:(UIColor *)color{
    [UtilMBProgressHUD showToast:toast with:imageName textColor:color view:self.view];
}
/// MBProgressHUD弹出加载中提示
- (void)showLoadingView{
    [UtilMBProgressHUD showLoading:self.view];
}
/// MBProgressHUD关闭弹出加载中提示
- (void)closeLoadingView{
    [UtilMBProgressHUD closeLoading:self.view];
}
/// VC 呈现,隐藏时调用,隐藏导航栏(apparent 前必须显示,不然无滑动返回手势)
-(void)setNavigationBarHidden:(BOOL)hidden{
    [self.navigationController.navigationBar setHidden:hidden];
    //self.navigationController.navigationBar.hidden = hidden;
    // apparent前调用,无滑动返回手势
    //self.navigationController.navigationBarHidden = hidden;
    //[self.navigationController setNavigationBarHidden:hidden animated:NO];
}
/// 返回按钮图标
-(void)changeBackImage:(NSString*)image{
    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:image];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:image];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];//无阴影(下部分割线)
}
/// Notification点击事件回调
-(void)notificationOnClick:(NSNotification*) notification{}

@end
