//
//  MyLogTag.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/8/12.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

public enum MyLogTag:Int, Error{
    case tag = 0
    
    /// 打印当前代码位置
    @discardableResult
    public init(_ message: String, function: String = #function, file: String = #file, line: Int = #line){
        self = MyLogTag(rawValue: 0)!
        // #function:调用本方法所在的函数,#file:调用本方法所在的文件,#line:调用本方法所在的行数
        Mylog.log("\(file)[\(line): \(function)] \(message)")
        //Mylog.log("\(file):\(self._domain):\(function):\(line):\(message):\(self) \(self.rawValue)")
    }
}
