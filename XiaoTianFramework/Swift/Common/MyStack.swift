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
    
    // 入栈
    mutating public func push(_ itemToPush:T){
        self.items.append(itemToPush)
    }
    
    // 出栈
    mutating public func pop() -> T{
        return self.items.removeLast()
    }
    
    // 清空
    mutating public func clean(){
        self.items.removeAll()
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
    public var values: [T]{
        return self.items
    }
}
