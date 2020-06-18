//
//  UIViewController+XT.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

// Block Declaration Aliases 定义
typedef void(^ViewControllerCallBack)(UIViewController* vc);

@interface UIViewController(XT)
// 实例
+(instancetype) getInstance;
+(instancetype) getInstance:(NSString*)storyboardId storyboard:(NSString*)stroryboardName;
// Property Get/Set 扩展属性
// Block Aliases Property Lifecycle Callback strong reference
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidLoad;
@property(copy,nonatomic)ViewControllerCallBack callBackViewWillAppear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidAppear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewWillDisappear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidDisappear;
@property(copy,nonatomic)ViewControllerCallBack callBackDealloc;

// 扩展方法 Category Method
+(UIViewController*) getTopViewController;
//
-(void)changeBackImage:(NSString*)image;
-(void)setNavigationBarHidden:(BOOL)hidden;
-(void)addTapViewHideKeyboard:(nullable SEL) selector;
-(void)onTapViewHideKeyboard;
-(void)notificationOnClick:(NSNotification*) notification;

// Dialog/Toast Method
-(void)showLoadingView;
-(void)closeLoadingView;
-(void)showToast:(NSString*)toast;
-(void)showToast:(NSString*)toast with:(NSString*)imageName textColor:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
