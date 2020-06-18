//
//  UNUserNotificationCenter+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2020/3/17.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

/// iOS10+ 本地消息管理中心
@interface UNUserNotificationCenter(XT)

/// 检测是否已经开启了消息通知功能
+(void)checkOpenNotification:(nullable void(^)(BOOL granted, NSError * _Nullable error)) completionHandler;
/// 发送本地通知消息
+(void)sendLocalNotification:(NSString*)title subTitle:(NSString*)subTitle body:(NSString*)body;
@end

NS_ASSUME_NONNULL_END
