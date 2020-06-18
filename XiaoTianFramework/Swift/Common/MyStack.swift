//
//  MyStack.swift
//  XiaoTianFramework
//  堆栈
//  Created by guotianrui on 2017/8/9.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

// 自定义堆栈模式
public struct MyStack<T>{
    fileprivate var items = [T]()
    
    mutating public func push(_ itemToPush:T){
        self.items.append(itemToPush)
    }
    
    mutating public func pop() -> T{
        return self.items.removeLast()
    }
}

// 基本方法
extension MyStack{
    public var count:Int{
        return self.items.count
    }
    public var isEmpty:Bool{ 
        return self.count == 0
    }
    public var last: T?{
        return self.isEmpty ? nil : self.items.last
    }
}
