//
//  UIViewController+XT.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

typedef void(^ViewControllerCallBack)(void);
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(XT)

// Lifecycle Callback
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidLoad;
@property(copy,nonatomic)ViewControllerCallBack callBackViewWillAppear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidAppear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewWillDisappear;
@property(copy,nonatomic)ViewControllerCallBack callBackViewDidDisappear;
@property(copy,nonatomic)ViewControllerCallBack callBackDealloc;

// Category Method
+(instancetype) getInstance;

// Method
-(void)showLoadingView;
-(void)closeLoadingView;
-(void)showToast:(NSString*)toast;
-(void)showToast:(NSString*)toast with:(NSString*)imageName textColor:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
