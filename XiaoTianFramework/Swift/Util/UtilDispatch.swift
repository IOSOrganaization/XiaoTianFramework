//
//  UtilDispatch.swift
//  DriftBook
//  系统任务调度器 (Grand Central Dispatch) GCD
//  Created by 郭天蕊 on 2016/12/22.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilDispatchXT)
open class UtilDispatch: NSObject{
    fileprivate override init(){}
    
    /// 异步任务[系统默认调度队列]
    public static func asyncTask(_ task: @escaping ()->()){
        DispatchQueue.global(qos: .userInitiated).async(execute: task)
        //DISPATCH_TARGET_QUEUE_DEFAULT.async(execute: task)
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), task)
    }
    /// 同步任务
    public static func syncTask(_ queue:DispatchQueue,_ task: @escaping ()->()){
        queue.async(execute: task) // 在队列调度器里同步执行block
    }
    /// 延时任务
    public class func after(_ second: Int, task: @escaping ()->()){
        // 延时时间: 当前系统调度器的时间 + 延时秒数 * 秒的单位
        let time: DispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(second)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline:time, execute:task)
        //DISPATCH_TARGET_QUEUE_DEFAULT.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(second) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: task)
    }
    /// 异步任务主线程
    public static func asyncTaskMain(_ task: @escaping ()->()){
        DispatchQueue.main.async(execute: task)
    }
    /// 同步任务主线程
    public static func syncTaskMain(_ task: @escaping ()->()){
        DispatchQueue.main.sync(execute: task)
    }
    /// 主线程延时
    public class func afterMainQueueDispatch(_ second: Int, task: @escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(second) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: task)
    }
    /// 当前线程休眠 xxx 秒
    public class func sleepThread(_ second:Int){
        sleep(UInt32(second))
    }
    @nonobjc
    public class func sleepThread(_ second:TimeInterval){
        Thread.sleep(forTimeInterval: second)
    }
    /// 当前线程休眠 xxx 纳秒
    public class func sleepThreadMicrosecond(_ microsecond:Int){
        let ms: Int = 1000
        // let second = 1000000
        usleep(UInt32(ms * microsecond))
    }
    /// NSObject 后台线程延时执行器(NSObject系统封装的延时执行)
    public class func asyncTaskNSObject(_ executor:NSObject,_ selector:Selector,_ withObject: AnyObject){
        executor.performSelector(inBackground: selector, with: withObject) // 后台线程异步执行
    }
    /// NSObject 当前线程异步延时执行
    public class func afterNSObject(_ executor:NSObject,_ selector:Selector,_ withObject: AnyObject,_ afterDelay: TimeInterval,_ inModes:[RunLoopMode]){
        executor.perform(selector, with: withObject, afterDelay: afterDelay, inModes: inModes)// 当前线程异步执行(底层实现是通过 NSTimer 来执行)
    }
    /// NSObject 当前线程异步执行
    public class func performNSObject(_ executor:NSObject,_ selector:Selector,_ withObject: AnyObject,_ afterDelay: TimeInterval,_ inModes:[String]){
        executor.perform(selector, with: withObject)// 当前线程异步执行
    }
    /// VC 异步执行 Selector
    public class func asyncTask(_ vc: UIViewController,_ selector:Selector,_ params: AnyObject?){
        vc.performSelector(inBackground: selector, with: params)
    }
    /// VC 主线程执行 Selector
    public class func runInMain(_ vc: UIViewController,_ selector:Selector,_ params: AnyObject?){
        vc.performSelector(onMainThread: selector, with: params, waitUntilDone: true)
    }
    /// NSTimer 调度执行器[target对象是强引用到定时器里面,必须要定时器执行完成/invalidate后,target才会被销毁deinit]
    public class func timerScheduled(_ timeIntervalSecond:TimeInterval,_ target:AnyObject,_ selector:Selector,_ userInfo:AnyObject?,_ repeats:Bool) -> Timer {
        //scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:
        return Timer.scheduledTimer(timeInterval: timeIntervalSecond, target: target, selector: selector, userInfo: userInfo, repeats: repeats)// 计划执行指定的定时器(自动加入 RunLoop 执行队列中)
        //NSTimer().fire() // 触发
        //NSTimer().invalidate() //销毁,无效
    }
    /// NSTimer 执行Block匿名函数,不会对target强引用,匿名函数要弱引用self[prevent block retain cycle]
    //@available(iOS 10.0, *)
    public class func timerScheduled(_ timeIntervalSecond:TimeInterval,_ repeats:Bool,_ block: @escaping (Timer) -> Void) -> Timer?{
        if #available(iOS 10.0, *){
            return Timer.scheduledTimer(withTimeInterval: timeIntervalSecond, repeats: repeats, block: block)// GCD
        }
        return nil
    }
    /// NSTimer 调度执行器
    public class func timerFire(_ timeIntervalSecond:TimeInterval,_ target:AnyObject,_ selector:Selector,_ userInfo:AnyObject?,_ repeats:Bool) -> Timer {
        let timer = Timer.scheduledTimer(timeInterval: timeIntervalSecond, target: target, selector: selector, userInfo: userInfo, repeats: repeats)// 创建执行指定的定时器
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode) // 加入到 RunLoop 执行中
        timer.fire() // 触发
        return timer
    }
    // GCD Customer Timer
    public class CancelableTimer: NSObject{
        private var q = DispatchQueue(label: "com.xiaotian.framework.UtilDispatch$CancelableTimer", attributes: DispatchQueue.Attributes.concurrent, target: DispatchQueue.main)
        private var timer: DispatchSourceTimer?
        private var firsttimer = true
        private var repeats: Bool
        private var handler: ()->()
        
        public init(_ repeats: Bool,_ handler:@escaping ()->()){
            self.repeats = repeats
            self.handler = handler
            super.init()
        }
        public func startWithInterval(_ intervalSecond: Double){
            self.firsttimer = true
            self.invalidate()
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: self.q)
            self.timer?.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: intervalSecond, leeway:  DispatchTimeInterval.seconds(1))
            self.timer?.setEventHandler { 
                if self.firsttimer{
                    self.firsttimer = false
                    return
                }
                self.handler()
                if !self.repeats{
                    self.invalidate()
                }
            }
            if #available(iOS 10.0, *) {
                self.timer?.activate()
            } else {
                self.timer?.resume()
            }
        }
        public func invalidate() {
            self.timer?.cancel()
        }
    }
    // Object-C 大部分都是通过通知执行
    //1. NSTimer执行:
    //2. UITableView执行:UITableViewSelectionDidChangeNotification,[should,will,did]
    //3. Data Source: UITableView, UICollectionView, UIPickerView, and UIPageViewController
}
