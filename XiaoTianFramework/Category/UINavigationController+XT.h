//
//  UINavigationController+XT.h
//  XiaoTianFramework
//  导航控制容器
//  Created by XiaoTian on 12/31/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

#import "Mylog.h"
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (XT)
// 初始化导航控制容器
+(instancetype) initWithLeftText:(NSString*) left leftIcon:(NSString*)leftIcon title:(NSString*) title rightText:(NSString*) rightText rightIcon:(NSString*)rightIcon target:(Class) targetPageClass;

//
// 扩展属性
// 扩展方法
/// 向上推出方式呈现VC
-(void)pushViewControllerFromTop:(UIViewController*)viewController;
/// 向下推方式关闭VC
-(void)popViewControllerFromBottom;
/// 向左推出方式呈现VC
-(void)pushViewControllerFromLeft:(UIViewController*)viewController;
/// 向右推方式关闭VC
-(void)popViewControllerFromRight;
@end

NS_ASSUME_NONNULL_END
