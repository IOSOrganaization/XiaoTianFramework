//
//  NSNotificationCenter+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "NSNotificationCenter+XT.h"

@implementation NSNotificationCenter(XT)

+(void)defaultAddObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName{
    //SEL模式
    [NSNotificationCenter.defaultCenter addObserver:observer selector:aSelector name:aName object:nil];
    //Block模式,必须移除结果observer
    //id observer = [NSNotificationCenter.defaultCenter addObserverForName:aName object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification * _Nonnull note) {
    //    [NSThread sleepForTimeInterval:15];
    //    [Mylog info:@"addObserverForName:queue"];
    //}];
}
+(void)defaultPost:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSNotification使用的是同步操作。即如果你在程序中的A位置post了一个NSNotification，在B位置注册了一个observer，通知发出后，必须等到B位置的通知执行完以后才能返回到A处继续往下执行
        //Notification在哪个线程中post，就在哪个线程中被转发，而不一定是在注册观察者的那个线程中。 Notification的发送与接收处理都是在同一个线程中。对于同一个通知，
        //如果注册了多个观察者，则这多个观察者的执行顺序和他们的注册顺序是保持一致的。
        [NSNotificationCenter.defaultCenter postNotificationName:name object:nil userInfo:userInfo];
    });
}
+(void)defaultPost:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo delay:(NSTimeInterval)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:name object:nil userInfo:userInfo];
    });
}
+(void)defaultPostAsync:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//后台异步线程
        [NSNotificationCenter.defaultCenter postNotificationName:name object:nil userInfo:userInfo];
    });
}
+(void)defaultRemoveObserver:(id)observer{
    [NSNotificationCenter.defaultCenter removeObserver:observer];
}
+(void)defaultRemoveObserver:(id)observer name:(nullable NSNotificationName)aName{
    [NSNotificationCenter.defaultCenter removeObserver:observer name:aName object:nil];
}
+(void)defaultQueuePostWhenIdle:(NSString*)name userInfo:(NSDictionary* _Nullable) userInfo{
    dispatch_async(dispatch_get_main_queue(), ^{//主线程空闲发送(聚合)
        NSNotification* notification = [NSNotification notificationWithName:name object:nil userInfo:userInfo];
        //postingStyle: NSPostNow：多个相同的通知合并之后马上发出通知,与postNotificationName相同
        //              NSPostASAP：不立即发出通知(ASAP即as soon as possible，就是说尽可能快)，而是在runloop匹配时调用，即：runloop处理事件源时,
        //              NSPostWhenIdle：空闲时发出通知,runloop闲置的时候post，即：runloop进入睡眠时
        //coalesceMask: NSNotificationNoCoalescing不聚合(每个通知都发),NSNotificationCoalescingOnName:名称聚合(名称相同则移除不发),NSNotificationCoalescingOnSender:发送者聚合(发送者相同则移除不发)
        //forModes: 匹配线程模式(与postingStyle匹配使用)
        //[NSNotificationQueue.defaultQueue enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationNoCoalescing forModes:@[NSDefaultRunLoopMode]];
        [NSNotificationQueue.defaultQueue enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationNoCoalescing forModes:@[NSDefaultRunLoopMode]];
    });
}
@end
