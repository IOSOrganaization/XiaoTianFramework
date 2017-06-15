//
//  UtilNSNotificationDefaultCenter.swift
//  DriftBook
//  NSNotificationDefaultCenter Util
//  Created by XiaoTian on 2016/11/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilNotificationDefaultCenter: NSObject{
    // 消息传递: Delegation,Notification,KeyValueObserve
    
    /// Post Notification
    open class func postNotificationName(_ notificationName:String,_ userInfo:[AnyHashable: Any]? = nil){
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
    }
    /// 注册通知侦听器/观察者
    open class func addObserver(_ observer:AnyObject,_ selector:Selector,_ name:String){
        // addObserver:selector:name:object: Selector方法添加通知侦听器
        // addObserverForName:object:queue:usingBlock: Block方法添加通知侦听器
        // observer:通知接收器,selector:接收器的方法[必须是Objc-C的方法],name:通知名称(nil为接收所有通知)字符串常量,object:对象过滤(nil接收所有,不对对象拦截)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    /// 注册通知侦听器/观察者,通过Block接收
    open class func addObserver(_ notificationName:String,_ usingBlock:@escaping (Notification)->Void){
        // 在usingBlock中使用self的话必须要弱引用,否则会造成死锁[匿名函数中引用self必须要弱引用]
        let ab = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:notificationName), object: nil, queue: nil, using: usingBlock)
        //NotificationCenter.default.removeObserver(ab) // 异常Block添加的侦听器,不异常会造成通知系统下发通知错乱,影响通知下发效率[在block中必须self要弱引用]
        //var observers = Set<NSObject>()
    }
    /// 移除通知侦听器/观察者
    open class func removeAllObserve(_ observer:AnyObject){
        //1. The observer token returned from the call to add Observer For Name:  object: queue: usingBlock: is retained by the notification center until you unregister it.
        //2. The observer token may also be retaining you (self) through the block (a function, probably anonymous)
        //3. In addition, if you also retain the observer token, then if the observer token is retaining you, you have a retain cycle on your hands.
        NotificationCenter.default.removeObserver(observer)
    }
    /// 注册侦听器
    open class func addObserver(_ observer: NSObject) {
        // 默认获取指定回调的 function
        if observer.responds(to: Selector("addObserver")){
            
        }
    }
    /// 发送通知/推播通知
    //func postNotification(observer: NSObject){
    
    //}
    /******************************* System Notification Message *******************************/
    /// 添加键盘弹出侦听器
    open class func addObserverKeyboardWillShow(_ observer: NSObject,_ selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    /// 添加键盘收起侦听器
    open class func addObserverKeyboardDidHide(_ observer: NSObject,_ selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    /// 移除键盘弹出侦听器
    open class func removeObserverKeyboardWillShow(_ observer: NSObject){
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    /// 移除键盘收起侦听器
    open class func removeObserverKeyboardDidHide(_ observer: NSObject){
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        /*let _: Void = "Hello".withCString {
            var cs = $0
            while cs.pointee != 0{
                print(cs.pointee)
                cs = cs.successor()
            }
        }*/
    }
    // Communication Between Objects:
    //1.直接引用[Delegate sent the message],最普通的方式[可能会造成循环引用]
    //2.Notifications[broadcast mechanism]
    //3.KVO
    // a Swift CBool is a C bool, a Swift CChar is a C char (a Swift Int8), a Swift CInt is a C int (a Swift Int32), a Swift CFloat is a C float (a Swift Float), and so on. Swift Int interchanges with NSInteger; Swift UInt interchanges with NSUInteger. Swift Bool interchanges with Swift ObjCBool
    // C String: UnsafePointer<Int8> (recall that Int8 is CChar)
    // A C pointer arrives into Swift as an UnsafePointer or, if writable, an UnsafeMutablePointer;(A pointer is “unsafe” because Swift isn’t managing the memory for, and can’t even guarantee the integrity of, what is pointed to.)[&params]
    // BOOL* Obje-c 布尔指针: UnsafeMutablePointer<ObjCBool>
    // void* C无类型指针: UnsafeMutablePointer<Void> 或 UnsafeMutablePointer<()>
    //  let c = UIGraphicsGetCurrentContext()!
    //  let arr = UnsafeMutablePointer<CGPoint>.alloc(4)
    //  arr[0] = CGPoint(x:0,y:0)
    //  arr[1] = CGPoint(x:50,y:50)
    //  arr[2] = CGPoint(x:50,y:50)
    //  arr[3] = CGPoint(x:0,y:100)
    //  CGContextStrokeLineSegments(c, arr, 4)[CG: Core Graphics,NS: NeXTStep]
    // id: Obje-c的对象指针(任何对象都可以): AnyObject
    // C -> Obje-c -> Swift
    // String to NSString, String
    // Int, UInt, Double, Float, and Bool to NSNumber 
    // Array to NSArray, Array<AnyObject>
    // Dictionary to NSDictionary, Dictionary<AnyObject>
    // Set to NSSet, Set<AnyObject>
    // Obje-c Initializers :  is just an instance method like any other in Objective-C.
    // SEL: Selector
    // Obje-c Selector String, Swift->Obje-C Selector String(Swift转为Obje-C会在第一个参数后面加With) :
    //  func sayHello() -> String // "sayHello","sayHello"
    //  func say(s:String) // "say:","sayWithS:"
    //  func say(s:String, times n:Int) // "say:times:","sayWithS:times"
    //  Swift的方法必须声明为Obje-C方法才可以被Selector[1.subclass of NSObject,2.with the @obc func,3.with the dynamic keyword func]
    // Block:
    //  Obje-c: typedef NSComparisonResult (^NSComparator)(id obj1, id obj2); 声明Block
    //  Swift: typealias NSComparator = (AnyObject, AnyObject) -> NSComparisonResult 声明Block
    //  Obje-c: + (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;
    //  Swift: class func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: ((Bool) -> Void)?)
    //  Obje-C: a block can be cast to an id 代码块可以转为id
    //  Swift: supplying a Swift function where an AnyObject is expected,func is property 代码块可以转为别名
    //  let lay = CALayer(); lay.setValue(holder, forKey:"myFunction")
    //  let holder2 = lay.valueForKey("myFunction") as! StringExpecterHolder[typealias name]; holder2.f("testing")
    //  声明传入变量为C语言的函数[pointer-to-function]: func functionTaker(f:@convention(c)() -> ()) {}
    //  Obje-C 转Swift 标注: nonnull or nullable
    //  C 转Swift 标注: __nonnull or __nullable
    //  NSArray<NSString *>: Array<String!>, NSArray; Array<AnyObject>
    // Objective-C cannot sub class a Swift class
}
