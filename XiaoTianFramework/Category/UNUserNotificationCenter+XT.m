//
//  UNUserNotificationCenter+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2020/3/17.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UNUserNotificationCenter+XT.h"

@implementation UNUserNotificationCenter(XT)

+(void)checkOpenNotification:(nullable void(^)(BOOL granted, NSError * _Nullable error)) completionHandler{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (completionHandler) completionHandler(granted, error);
    }];
}
+(void)sendLocalNotification:(NSString*)title subTitle:(NSString*)subTitle body:(NSString*)body{
    if(@available(iOS 10.0, *)){
        // iOS 10.0+ 使用UNUserNotificationCenter发送通知消息
        //第一步：获取推送通知中心
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //center.delegate = self;//必填,在appDelegate中侦听回调
        //第二步：设置推送内容
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = title;//单行文本,超出省略
        content.subtitle = subTitle;//单行文本,超出省略
        content.body  = body;//最多两行文本,超出省略
        content.badge = @1;
        content.categoryIdentifier = @"categoryIdentifier";
        content.userInfo = @{};//用户自定义参数
        NSString* requestID = [NSString stringWithFormat:@"random_notification_%ld", random()];
        // 下拉更多功能按钮
        //需要解锁显示，红色文字。点击不会进app。
        //UNNotificationActionOptionAuthenticationRequired = (1 << 0),
        //
        //黑色文字。点击不会进app。
        //UNNotificationActionOptionDestructive = (1 << 1),
        //
        //黑色文字。点击会进app。
        //UNNotificationActionOptionForeground = (1 << 2),
        UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"enterApp"
                                                                            title:@"进入应用"
                                                                          options:UNNotificationActionOptionForeground];
        UNNotificationAction *clearAction = [UNNotificationAction actionWithIdentifier:@"destructive"
                                                                                 title:@"忽略2"
                                                                               options:UNNotificationActionOptionDestructive];
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"categoryIdentifier"
                                                                                  actions:@[action, clearAction]
                                                                        intentIdentifiers:@[requestID]
                                                                                  options:UNNotificationCategoryOptionNone];
        [center setNotificationCategories:[NSSet setWithObject:category]];
        //第三步：设置推送方式(定时器触发)
        UNTimeIntervalNotificationTrigger* timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
        // 日历定时触发
        //UNCalendarNotificationTrigger* calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:[NSDateComponents alloc] com  repeats:YES];
        // 地点到达触发
        //UNLocationNotificationTrigger* locationTrigger = [UNLocationNotificationTrigger triggerWithRegion:[CLRegion alloc] repeats:NO]
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestID content:content trigger:timeTrigger];
        //第四步：添加推送request
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) [Mylog info:@"添加消息通知失败,error:%@", error];
        }];
        /*[center removePendingNotificationRequestsWithIdentifiers:@[requestID]];
        [center removeAllDeliveredNotifications];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"settings===%@",settings);
        }];*/
    }else{
        // 使用UILocalNotification发送通知消息
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
        notification.repeatInterval = NSCalendarUnitDay;
        notification.alertBody = body;
        notification.alertTitle = title;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}
@end
