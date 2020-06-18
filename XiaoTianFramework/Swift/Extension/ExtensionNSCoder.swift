//
//  ExtensionNSCoder.swift
//  XiaoTianFramework
//  NSCoder
//  Created by guotianrui on 2017/6/19.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

extension NSCoder{
    /// XJ Property Encode [suppoer json property:NSString,NSNumber,NSNull,NSArray,NSDectionary]
    public func encodeXJ<T: NSObject>(_ any: T?) -> T?{
        guard let propertyList = XTFUtilRuntime.queryPropertyList(any?.classForCoder, endSupperClazz: NSObject.self) else {
            return any
        }
        for property in propertyList{
            if let property = property as? String{
                if !property.hasSuffix("XJ"){
                    continue
                }
                if let value = any?.value(forKey: property){ // KVO
                    encode(value, forKey: property)
                }
            }
        }
        return any
    }
    /// XJ Property Decode
    public func decodeXJ<T: NSObject>(_ any: T?) -> T?{
        guard let propertyList = XTFUtilRuntime.queryPropertyList(any?.classForCoder, endSupperClazz: NSObject.self) else {
            return any
        }
        for property in propertyList{
            if let property = property as? String{
                if !property.hasSuffix("XJ"){
                    continue
                }
                // KVO
                var value = decodeObject(forKey: property) as AnyObject?
                do {
                    try any?.validateValue(&value, forKey: property)
                    any?.setValue(value, forKey: property)
                }catch{
                    Mylog.log("Set Instance Property Error The Type UnMatched In:\(property),Value:\(value!)")
                }
            }
        }
        return any
    }
    /// Property Encode
    public func encodeProperty<T: NSObject>(_ any: T?) -> T?{
        guard let propertyList = XTFUtilRuntime.queryPropertyList(any?.classForCoder, endSupperClazz: NSObject.self) else {
            return any
        }
        for property in propertyList{
            if let property = property as? String{
                if let value = any?.value(forKey: property){ // KVO
                    encode(value, forKey: property)
                }
            }
        }
        return any
    }
    /// Property Decode [所有属性,当属性只读时会崩溃]
    public func decodeProperty<T: NSObject>(_ any: T?) -> T?{
        guard let propertyList = XTFUtilRuntime.queryPropertyList(any?.classForCoder, endSupperClazz: NSObject.self) else {
            return any
        }
        for property in propertyList{
            if let property = property as? String{
                var value = decodeObject(forKey: property) as AnyObject?
                do {
                    try any?.validateValue(&value, forKey: property)
                    any?.setValue(value, forKey: property)
                }catch{
                    Mylog.log("Set Instance Property Error The Type UnMatched In:\(property),Value:\(value!)")
                }
            }
        }
        return any
    }
}
