//
//  AppDelegateXT.m
//  jjrcw
//
//  Created by XiaoTian on 2020/5/26.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "AppDelegateXT.h"

@implementation AppDelegateXT
//常见回调
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions{
    //告诉代理进程启动但还没进入状态保存
    
    return YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions{
    //告诉代理启动基本完成程序准备开始运行
    return YES;
}
- (void)applicationDidFinishLaunching:(UIApplication *)application{
    //当程序载入后执行
}
- (void)applicationDidBecomeActive:(UIApplication *)application{
    //当应用程序入活动状态执行，这个刚好跟上面那个方法相反
}
- (void)applicationDidEnterBackground:(UIApplication *)application{
    //当程序被推送到后台的时候调用。所以要设置后台继续运行，则在这个函数里面设置即可
}
- (void)applicationWillEnterForeground:(UIApplication *)application{
    //当程序从后台将要重新回到前台时候调用，这个刚好跟上面的那个方法相反。
}
- (void)applicationWillTerminate:(UIApplication *)application{
    //当程序将要退出是被调用，通常是用来保存数据和一些退出前的清理工作。这个需要要设置UIApplicationExitsOnSuspend的键值。
}

@end
