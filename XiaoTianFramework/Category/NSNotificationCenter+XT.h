//
//  NSNotificationCenter+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter(XT)

///同步默认通知中心添加观察者
+(void)defaultAddObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName;
///同步默认通知中心发通知(主线程)
+(void)defaultPost:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo;
///同步默认通知中心延时发通知(主线程)
+(void)defaultPost:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo delay:(NSTimeInterval)delay;
///异步默认通知中心延时发通知(异步后台线程,默认Notification的发送与接收处理都是在同一个线程中同步执行)
+(void)defaultPostAsync:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo;
///同步默认通知中心移除所有观察者
+(void)defaultRemoveObserver:(id)observer;
///同步默认通知中心移除指定观察者
+(void)defaultRemoveObserver:(id)observer name:(nullable NSNotificationName)aName;

///同步默认通知中心发通知(主线程空闲时才发送, [聚合,匹配线程状态], 消息发送队列可配置)
+(void)defaultQueuePostWhenIdle:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo;
@end

NS_ASSUME_NONNULL_END
