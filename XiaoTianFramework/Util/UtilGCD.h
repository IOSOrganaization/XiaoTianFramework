//
//  UtilGCD.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2016/12/5.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilGCD : NSObject
// Block Property 匿名函数属性
@property (nonatomic, weak)void (^action)(void);// 返回类型(^属性名称)(参数列表)

//Grand Central Dispatch
///后台线程调度(系统默认优先级), UI主线程调度(后台线程执行,前台线程执行)
+(void)runInThread:(void(^)(void)) asyncThreadTask on:(void(^)(void)) mainThreadTask;//匿名函数参数: 返回类型(^)(参数列表)
///主线程队列执行
+(void)post:(void (^)(void))mainThreadTask;
///主线程延时执行
+(void)postDelay:(void (^)(void))mainThreadTask delay:(NSTimeInterval) delay;
///主线程创建定时器(NSTimer默认主线程)
+(NSTimer*)careateTimerScheduler:(void (^)(void)) mainThreadTask interval:(NSTimeInterval) interval;
///主线程延时循环执行任务(结束: *stop=YES)
+(NSTimer*)scheduler:(void (^)(BOOL *stop)) mainThreadTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat;
///子线程创建定时器,使用dispatch_source_t能精确到秒调度触发
+(dispatch_source_t)careateTimerSchedulerAsync:(void (^)(void)) asyncHandlerTask interval:(NSTimeInterval) interval;
///主线程延时循环执行任务(结束: *stop=YES)
+(dispatch_source_t)schedulerSource:(void (^)(BOOL *stop)) mainThreadTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat;
///子线程延时循环执行任务(结束: *stop=YES)
+(dispatch_source_t)schedulerSourceAsync:(void (^)(BOOL *stop)) asyncHandlerTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat;
+(void)test;
@end

NS_ASSUME_NONNULL_END
