//
//  FWSlideMenu.h
//  左右划出菜单控制器
//  Created by XiaoTian on 2020/4/1.
//  Copyright © 2020 xfg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FWSideMenuPanModeDefaults = 0,
    FWSideMenuPanModeNone,
    FWSideMenuPanModeCenterViewController,
    FWSideMenuPanModeSideMenu,
} FWSideMenuPanMode;

typedef enum : NSUInteger {
    FWSideMenuStateClosed=0,
    FWSideMenuStateLeftMenuOpen,
    FWSideMenuStateRightMenuOpen
} FWSideMenuState;

typedef enum : NSUInteger {
    FWSideMenuStateEventWillClose=0,
    FWSideMenuStateEventWillOpen,
    FWSideMenuStateEventDidOpen,
    FWSideMenuStateEventDidClose
} FWSideMenuStateEvent;

typedef enum : NSUInteger {
    FWSideMenuPanDirectionNone=0,
    FWSideMenuPanDirectionLeft,
    FWSideMenuPanDirectionRight
} FWSideMenuPanDirection;

#define FWSideMenuStateNotificationEvent @"FWSideMenuStateNotificationEvent"
typedef void (^FWSideMenuVoidBlock)(void);
/**
 1. [FWSlideMenu container:nav centerLeftPanViewWidth:8 left:[[MenuViewController alloc] init] centerRightPanViewWidth:0 right:[[MenuViewController alloc] init]];//左边滑动触发距离8,右边滑动触发距离0
 2. [FWSlideMenu container:nav left:[[MenuViewController alloc] init] right:[[MenuViewController alloc] init]];//左右平分滑动触发距离
 */
@interface FWSlideMenu : UIViewController<UIGestureRecognizerDelegate>
@property(strong,nonatomic)UIViewController* centerViewController;
@property(strong,nonatomic)UIViewController* leftMenuViewController;
@property(strong,nonatomic)UIViewController* rightMenuViewController;
@property(assign,nonatomic)BOOL sideMenuShadowEnabled;
/// 左边菜单VC宽度
@property(assign,nonatomic)CGFloat leftMenuWidth;
/// 右边菜单VC宽度
@property(assign,nonatomic)CGFloat rightMenuWidth;
/// 展开模式(根VC:viewWillAppear开启滑动模式, viewWillDisappear:关闭滑动模式)
@property(assign,nonatomic)FWSideMenuPanMode sideMenuPanMode;
@property(assign,nonatomic)FWSideMenuState sideMenuState;
@property(assign,nonatomic)FWSideMenuPanDirection panGestureDirection;
/// 左右各占一半监控滑动触发距离(中间屏幕的触摸事件被监控拦截)的方式初始化:centerViewController中间VC, left:左边VC, right:右边VC, (UInavigationController系统返回滑动事件取消拦截:加入UINavigation+FDFullscreenPopGesture)
+(instancetype)container:(UIViewController*)centerViewController left:(UIViewController* _Nullable)left right:(UIViewController* _Nullable)right;
/// 指定左右滑动触发距离(没被监控的范围不会拦截触摸事件),centerLeftPanViewWidth: 左边触发滑动监控宽度, centerRightPanViewWidth:右边触发滑动监控宽度, centerViewController中间VC, left:左边VC, right:右边VC
+(instancetype)container:(UIViewController*)centerViewController centerLeftPanViewWidth:(CGFloat)centerLeftPanViewWidth left:(UIViewController*)left centerRightPanViewWidth:(CGFloat)centerRightPanViewWidth right:(UIViewController*)right;
/// 关闭菜单
-(void)closeSideMenu:(FWSideMenuVoidBlock _Nullable)completeBolck;
/// 打开左边菜单
-(void)openLeftSideMenu:(FWSideMenuVoidBlock _Nullable)completeBolck;
/// 打开右边菜单
-(void)openRightSideMenu:(FWSideMenuVoidBlock _Nullable)completeBolck;
/// Toggle左边菜单
-(void)toggleLeftSideMenu:(FWSideMenuVoidBlock _Nullable)completeBolck;
/// Toggle右边菜单
-(void)toggleRightSideMenu:(FWSideMenuVoidBlock _Nullable)completeBolck;
/// 设置菜单状态(关闭,打开左边,打开右边)
-(void)setSideMenuState:(FWSideMenuState)state completeBlock:(FWSideMenuVoidBlock _Nullable)completeBlock;
/// 在VC中查找当前左右划出菜单管理器
+(FWSlideMenu*)getCurrentSlideMenu:(UIViewController*)vc;

@end

@interface FWSideMenuShadow : NSObject
+(FWSideMenuShadow*)shadow:(UIView*)sdView;
@property(assign,nonatomic)BOOL enabled;
@property(assign,nonatomic)CGFloat opacity;
@property(assign,nonatomic)CGFloat radius;
@property(strong,nonatomic)UIColor* color;
@property(strong,nonatomic)UIView* shadowedView;
@end
NS_ASSUME_NONNULL_END
