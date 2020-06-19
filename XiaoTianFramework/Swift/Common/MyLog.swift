//
//  MyLog.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/24.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

//works in DEBUG mode only
//  use swift Macros DEBUG Flag you need to set "Other Swift Flags" in your target's Build Settings:
//  1. Open Build Settings for your target
//  2. Search for "other swift flags"
//  3. Add the macros you wish to use, preceded by the -D flag
@objc(MylogSwiftXT)
open class Mylog: NSObject{
    private static let TAG = "[Mylog]"
    // Swif Any Object Methos
    @nonobjc
    public static func log(_ param:Any?){
        #if DEBUG
        print(TAG, param == nil ? "nil" : param!)
        #endif
    }
    @nonobjc
    public static func log(_ params: Any?...){
        #if DEBUG
        if params.count == 1{
            print(TAG, params[0] == nil ? "nil" :params[0]!)
        }else{
            var text = ""
            for item in params{
                if let item = item{
                    text = "\(text)\(String(describing: item))"
                }
            }
            print(TAG, text)
        }
        #endif
    }
    
    @nonobjc
    public static func log(_ params:Any...,separator: String = ",",terminator: String = ""){
        #if DEBUG
        print(TAG, params.count < 2 ? params[0] : params, separator, terminator)
        #endif
    }
    
    public static func logBundleFiles(){
        #if DEBUG
        let bundle:Bundle = Bundle.main
        let paths = bundle.paths(forResourcesOfType: nil, inDirectory: nil)
        for path in paths {
            Mylog.log(TAG, (path as NSString).lastPathComponent)
        }
        #endif
    }
    @nonobjc
    public static func logClass(_ any: AnyObject?){
        if any == nil{
            Mylog.log("nil")
            return
        }
        guard let propertyList = XTFUtilRuntime.queryPropertyList(any!.classForCoder, endSupperClazz: NSObject.self) else {
            Mylog.log("\(any!.classForCoder) has non property.")
            return
        }
        var clazz:String? = nil
        var clazzSup: AnyClass? = any!.classForCoder
        repeat {
            if clazz == nil{
                clazz = String(describing: clazzSup!)
            }else{
                clazz?.append("->")
                clazz?.append(String(describing: clazzSup!))
            }
            clazzSup = clazzSup?.superclass()
        } while (clazzSup != nil)
        Mylog.log("Class: \(clazz!) {")
        for property in propertyList{
            if let property = property as? String{
                let value = any?.value(forKey: property)
                Mylog.log("\(property) = \(value == nil ? "nil" : value!)")
            }
        }
        Mylog.log("}")
    }
    @objc(logClassConsumption:)
    public static func logClassConsumption(_ clazz: AnyClass){
        print(TAG, String(format: "%zu", class_getInstanceSize(clazz)))
        //  String("Status: %lu%%", (unsigned long)(status * 100))
    }
    public static func logClassProperties(_ data: Any){
        #if DEBUG
        let propertyNames =  Mirror(reflecting: self).children.flatMap { $0.label }
        Mylog.log(TAG, propertyNames)
        //        for c in Mirror(reflecting: data).children
        //        {
        //            if let name = c.label{
        //                Mylog.log(name)
        //            }
        //        }
        #endif
    }
    public static func logError(_ error:Error,file: String = #file,function:String = #function,line:Int = #line){
        #if DEBUG
        Mylog.log(TAG, String(format: "%@[%d:%@] %@", file, line, function, error.localizedDescription))
        #endif
    }
    public static func logLoca(_ message:String,file: String = #file,function:String = #function,line:Int = #line){
        #if DEBUG
        Mylog.log(TAG, String(format: "%@[%d:%@] %@", file, line, function, message))
        #endif
    }
    // Support OBJC Methos
    @objc(logClassField:)
    public static func logClassField(_ data: Any?){
        #if DEBUG
        XTFMylog.infoClassField(data)
        #endif
    }
    @objc(logClassProperty:)
    public static func logClassProperty(_ data: Any?){
        #if DEBUG
        XTFMylog.infoClassProperty(data)
        #endif
    }
    @objc(logClassVariable:)
    public static func logClassVariable(_ data: Any?){
        #if DEBUG
        XTFMylog.infoClassVariable(data)
        #endif
    }
    public static func test(){
        
    }
}
