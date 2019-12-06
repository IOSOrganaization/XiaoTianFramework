//
//  UtilGCD.m
//  XiaoTianFramework
//  GCD全局调度中心
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "UtilGCD.h"

@implementation UtilGCD

/// 后台线程(系统默认),UI线程调度(后台线程执行,前台线程执行)
+(void)runInThread:(void (^)(void))thread on:(void (^)(void))mainThread{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        thread();
        if(mainThread){
            dispatch_async(dispatch_get_main_queue(), ^{
                mainThread();
            });
        }
    });
}
+(void)post:(void (^)(void))mainThread{
    dispatch_async(dispatch_get_main_queue(), mainThread);
}
/// 主线程延时执行
+(void)postDelay:(void (^)(void))mainThread delay:(NSTimeInterval) delay{
    if(mainThread){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            mainThread();
        });
    }
}

/// 子线程创建定时器
+(dispatch_source_t)careateTimerScheduler:(void (^)(void)) secondHandler{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//所在线程,后台线程
    dispatch_source_t secondScheduler = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);//创建定时器
    dispatch_source_set_timer(secondScheduler, DISPATCH_TIME_NOW,  1* NSEC_PER_SEC,0);//设置定时器,启动时间,时间间隔,延迟
    dispatch_source_set_event_handler(secondScheduler, secondHandler);//设置定时器回调函数
    dispatch_resume(secondScheduler);//执行定时器
    //dispatch_cancel(secondScheduler);//取消定时器
    return secondScheduler;
}

/// 线程队列
+(dispatch_queue_t) createQueue{
    // 串行队列的创建方法
    dispatch_queue_t queueSerial = dispatch_queue_create("com.xiaotian.QueueSerial", DISPATCH_QUEUE_SERIAL);
    // 并发队列的创建方法
    dispatch_queue_t queueConcurrent = dispatch_queue_create("com.xiaotian.QueueConcurrent", DISPATCH_QUEUE_CONCURRENT);
    // 主队列(主线程)
    dispatch_queue_t queueMain = dispatch_get_main_queue();
    // 系统默认全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 同步执行任务创建方法(加入队列等待执行,串行队列不能使用同步导致死锁)
    dispatch_sync(queue, ^{
        // 这里放同步执行任务代码
    });
    // 异步执行任务创建方法(开启新线程执行)
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
    });
    // 延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@", [NSThread currentThread]);  // 打印当前线程
    });
    // 只执行一次
    static dispatch_once_t onceToken;//静态标识
    dispatch_once(&onceToken, ^{
        // 只执行 1 次的代码（这里面默认是线程安全的）
    });
    // 队列组
    dispatch_group_t group = dispatch_group_create();//分组信号量
    dispatch_group_enter(group);//进入组信号
    dispatch_group_leave(group);//结束组信号
    // 组信号结束完成回调触发
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //
        NSLog(@"group 执行完成");
    });
    // 组信号阻塞等待(组信号结束才继续,120秒超时)
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120.0 * NSEC_PER_SEC)));
    // 调度信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(semaphore);//释放信号量
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //信号量等待释放(无限期等待)
    return nil;
}
@end
