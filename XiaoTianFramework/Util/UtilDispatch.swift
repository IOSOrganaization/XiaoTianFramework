//
//  UtilDispatch.swift
//  DriftBook
//  系统任务调度器 (Grand Central Dispatch) GCD
//  Created by 郭天蕊 on 2016/12/22.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
class UtilDispatch{
    private init(){}
    
    /// 异步任务[系统默认调度队列]
    class func asyncTask(task: ()->()){
        dispatch_async(DISPATCH_TARGET_QUEUE_DEFAULT, task)
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), task)
    }
    /// 延时任务
    class func after(second: Int, task: ()->()){
        // 延时时间: 当前系统调度器的时间 + 延时秒数 * 秒的单位
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(second) * NSEC_PER_SEC)), DISPATCH_TARGET_QUEUE_DEFAULT, task)
    }
    /// 主线程延时
    class func afterMainQueueDispatch(second: Int, task: ()->()){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(second) * NSEC_PER_SEC)), dispatch_get_main_queue(), task)
    }
    /// 当前线程休眠 xxx 秒
    class func sleepThread(second:Int){
        sleep(UInt32(second))
    }
    /// NSObject 后台线程延时执行器(NSObject系统封装的延时执行)
    class func asyncTaskNSObject(executor:NSObject,_ selector:Selector,_ withObject: AnyObject){
        executor.performSelectorInBackground(selector, withObject: withObject) // 后台线程异步执行
    }
    /// NSObject 当前线程异步延时执行
    class func afterNSObject(executor:NSObject,_ selector:Selector,_ withObject: AnyObject,_ afterDelay: NSTimeInterval,_ inModes:[String]){
        executor.performSelector(selector, withObject: withObject, afterDelay: afterDelay, inModes: inModes)// 当前线程异步执行(底层实现是通过 NSTimer 来执行)
    }
    /// NSObject 当前线程异步执行
    class func performNSObject(executor:NSObject,_ selector:Selector,_ withObject: AnyObject,_ afterDelay: NSTimeInterval,_ inModes:[String]){
        executor.performSelector(selector, withObject: withObject)// 当前线程异步执行
    }
    /// VC 异步执行 Selector
    class func asyncTask(vc: UIViewController,_ selector:Selector,_ params: AnyObject?){
        vc.performSelectorInBackground(selector, withObject: params)
    }
    /// VC 主线程执行 Selector
    class func runInMain(vc: UIViewController,_ selector:Selector,_ params: AnyObject?){
        vc.performSelectorOnMainThread(selector, withObject: params, waitUntilDone: true)
    }
    /// NSTimer 调度执行器
    class func timerScheduled(timeInterval:NSTimeInterval,_ target:AnyObject,_ selector:Selector,_ userInfo:AnyObject?,_ repeats:Bool){
        NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)// 计划执行指定的定时器(自动加入 RunLoop 执行队列中)
        //NSTimer().fire() // 触发
        //NSTimer().invalidate() //销毁,无效
    }
    /// NSTimer 调度执行器
    class func timerFire(timeInterval:NSTimeInterval,_ target:AnyObject,_ selector:Selector,_ userInfo:AnyObject?,_ repeats:Bool){
        let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)// 创建执行指定的定时器
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode) // 加入到 RunLoop 执行中
        timer.fire() // 触发
    }
}
