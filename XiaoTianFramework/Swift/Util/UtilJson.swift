//
//  UtilJson.swift
//  XiaoTianFramework
//  Json 工具
//  Created by guotianrui on 2017/5/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilJson:NSObject{
    // Type Support
    //  JSONObject -> NSDictionary
    //  JSONArray -> NSArray
    //  NSString, NSNumber, NSArray, NSDictionary, or NSNull
    //
    // 1.mutableContainers: JSONSerialization.ReadingOptions
    //  Specifies that arrays and dictionaries are created as mutable objects.
    // 2.mutableLeaves: JSONSerialization.ReadingOptions
    //  Specifies that leaf strings in the JSON object graph are created as instances of NSMutableString.
    // 3.allowFragments: JSONSerialization.ReadingOptions
    //  Specifies that the parser should allow top-level objects that are not an instance of NSArray or NSDictionary.
    //
    @objc(formatJSONString:)
    public func formatJSON(_ data: String?) -> String?{
        guard let unPackagData = data?.data(using: .utf8) else {
            return nil
        }
        do{
            let jsonAny = try JSONSerialization.jsonObject(with: unPackagData, options: JSONSerialization.ReadingOptions.mutableContainers)
            let data = try JSONSerialization.data(withJSONObject: jsonAny, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }catch{
            Mylog.log("UtilJson formatJSON Error.\(error)");
        }
        return nil
    }
    @objc(formatJSONData:)
    public func formatJSON(_ data: Data?) -> String?{
        guard let unPackagData = data else {
            return nil
        }
        do{
            let jsonAny = try JSONSerialization.jsonObject(with: unPackagData, options: JSONSerialization.ReadingOptions.mutableContainers)
            let data = try JSONSerialization.data(withJSONObject: jsonAny, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }catch{
            Mylog.log("UtilJson formatJSON Error.\(error)");
        }
        return nil
    }
    // Property Serializing/DeSerializing
    /// 反序列化[Data -> NSArray,NSDictionary]
    public func deSerializing(_ data: Data?) -> Any?{
        guard let unPackagData = data else {
            return nil
        }
        do{
            return try JSONSerialization.jsonObject(with: unPackagData, options: JSONSerialization.ReadingOptions.mutableContainers)
        }catch{
            Mylog.log("NSJSONSerialization deSerializing Error.\(error)");
        }
        return nil
    }
    /// 序列化一个对象
    public func serializing<T: NSObject>(_ any: T?) -> String?{
        guard let unPackageAny = any else {
            return nil
        }
        var jsonAny:Any?
        if unPackageAny is NSArray{
            var resultArray:[Any] = []
            guard let unPackageArray = (unPackageAny as? NSArray) else{
                return nil
            }
            for data in unPackageArray{
                if data is NSObject {
                    if let data = serializingObject(data as? NSObject) {
                        resultArray.append(data)
                    }
                }
            }
            jsonAny = resultArray
        }else if unPackageAny is NSDictionary{
            guard let propertyList = (unPackageAny as? NSDictionary)?.allKeys else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for property in propertyList{
                if let property = property as? String{
                    guard let value = any?.value(forKey: property) else{ // KVO
                        continue
                    }
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObject(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            jsonAny = resultDictionary
        }else{
            // Entity -> Dictionary[NSString,NSNumber,NSNull]
            guard let propertyList = XTFUtilRuntime.queryPropertyList(unPackageAny.classForCoder, endSupperClazz: NSObject.self) else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for property in propertyList{
                if let property = property as? String{
                    guard let value = any?.value(forKey: property) else{ // KVO
                        continue
                    }
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObject(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            jsonAny = resultDictionary
        }
        if let jsonAny = jsonAny {
            do{
                let data = try JSONSerialization.data(withJSONObject: jsonAny, options: .prettyPrinted)
                return String(data: data, encoding: .utf8)
            }catch{
                Mylog.log("NSJSONSerialization deSerializing Error.\(error)");
            }
        }
        return nil
    }
    @nonobjc
    private func serializingObject<T: NSObject>(_ any: T?) -> Any?{
        guard let unPackageAny = any else {
            return nil
        }
        if unPackageAny is NSArray{
            var resultArray:[Any] = []
            guard let unPackageArray = (unPackageAny as? NSArray) else{
                return nil
            }
            for data in unPackageArray{
                if data is NSObject {
                    if let data = serializingObject(data as? NSObject) {
                        resultArray.append(data)
                    }
                }
            }
            return resultArray
        }else if unPackageAny is NSDictionary{
            guard let propertyList = (unPackageAny as? NSDictionary)?.allKeys else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for property in propertyList{
                if let property = property as? String{
                    guard let value = any?.value(forKey: property) else{ // KVO
                        continue
                    }
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObject(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            return resultDictionary
        }else {
            guard let propertyList = XTFUtilRuntime.queryPropertyList(unPackageAny.classForCoder, endSupperClazz: NSObject.self) else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for property in propertyList{
                if let property = property as? String{
                    guard let value = any?.value(forKey: property) else{ // KVO
                        continue
                    }
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObject(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            return resultDictionary
        }
    }
    /// 反序列化一个对象/数组
    public func deSerializing<T: NSObject>(_ data: Data?,_ clazz:T.Type) -> Any?{
        guard let unPackagData = data else {
            return nil
        }
        do{
            let rootJson = try JSONSerialization.jsonObject(with: unPackagData, options: JSONSerialization.ReadingOptions.mutableContainers)
            if rootJson is [Any]{
                return deSerializing(rootJson as? [Any], clazz)
            } else if rootJson is [String:Any]{
                return deSerializing(rootJson as? [String:Any], clazz)
            }
        }catch{
            Mylog.log("NSJSONSerialization deSerializing Error.\(error)");
        }
        return nil
    }
    /// 反序列化一个对象
    public func deSerializing<T: NSObject>(_ dictionary: [String:Any?]?,_ clazz: T.Type) -> T?{
        guard let unPackagDictionary = dictionary else {
            return nil
        }
        let result:T = clazz.init()
        if !T.accessInstanceVariablesDirectly {
            return result
        }
        guard let propertyList = XTFUtilRuntime.queryPropertyList(clazz, endSupperClazz: NSObject.self) else {
            return result
        }
        for property in propertyList{
            if let property = property as? String{
                var value = unPackagDictionary[property] as AnyObject?
                // NSString, NSNumber, or NSNull
                if value == nil || value is NSNull{
                    continue
                }
                // KVO
                do {
                    try result.validateValue(&value, forKey: property)
                    result.setValue(value, forKey: property)
                }catch{
                    Mylog.log("尝试设置实体属性值时发生错误类型不匹配.属性名:\(property),属性值:\(value!)")
                }
            }
        }
        return result
    }
    /// 反序列化一个数组
    public func deSerializing<T: NSObject>(_ array: [Any?]?,_ clazz:T.Type) -> [T]?{
        guard let unPackagArray = array else {
            return nil
        }
        var resultArray:[T] = []
        if !T.accessInstanceVariablesDirectly {
            return resultArray
        }
        guard let propertyList = XTFUtilRuntime.queryPropertyList(clazz, endSupperClazz: NSObject.self) else {
            return resultArray
        }
        for data in unPackagArray{
            if let unPackagDictionary = data as? [String: Any?]{
                let result:T = clazz.init()
                for property in propertyList{
                    if let property = property as? String{
                        var value = unPackagDictionary[property] as AnyObject?
                        // NSString, NSNumber, or NSNull
                        if value == nil || value is NSNull{
                            continue
                        }
                        // KVO
                        do {
                            try result.validateValue(&value, forKey: property)
                            result.setValue(value, forKey: property)
                        }catch{
                            Mylog.log("尝试设置实体属性值时发生错误类型不匹配.属性名:\(property),属性值:\(value!)")
                        }
                    }
                }
                resultArray.append(result)
            }
        }
        return resultArray
    }
    //
    // XJ Suffix Property Serializing/DeSerializing
    /// 序列化一个XJ属性的对象
    public func serializingXJ<T: NSObject>(_ any: T?) -> String?{
        guard let unPackageAny = any else {
            return nil
        }
        var jsonAny:Any?
        if unPackageAny is NSArray{
            var resultArray:[Any] = []
            guard let unPackageArray = (unPackageAny as? NSArray) else{
                return nil
            }
            for data in unPackageArray{
                if data is NSObject {
                    if let data = serializingObjectXJ(data as? NSObject) {
                        resultArray.append(data)
                    }
                }
            }
            jsonAny = resultArray
        }else if unPackageAny is NSDictionary{
            guard let propertyList = (unPackageAny as? NSDictionary)?.allKeys else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for propertyXJ in propertyList{
                if let propertyXJ = propertyXJ as? String{
                    if !propertyXJ.hasSuffix("XJ"){
                        continue
                    }
                    guard let value = any?.value(forKey: propertyXJ) else{ // KVO
                        continue
                    }
                    let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObjectXJ(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            jsonAny = resultDictionary
        }else{
            // Entity -> Dictionary[NSString,NSNumber,NSNull]
            guard let propertyList = XTFUtilRuntime.queryPropertyList(unPackageAny.classForCoder, endSupperClazz: NSObject.self) else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for propertyXJ in propertyList{
                if let propertyXJ = propertyXJ as? String{
                    if !propertyXJ.hasSuffix("XJ"){
                        continue
                    }
                    guard let value = any?.value(forKey: propertyXJ) else{ // KVO
                        continue
                    }
                    let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                    if value is NSString{
                         resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                         resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObjectXJ(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            jsonAny = resultDictionary
        }
        if let jsonAny = jsonAny {
            do{
                let data = try JSONSerialization.data(withJSONObject: jsonAny, options: .prettyPrinted)
                return String(data: data, encoding: .utf8)
            }catch{
                Mylog.log("NSJSONSerialization deSerializing Error.\(error)");
            }
        }
        return nil
    }
    @nonobjc
    private func serializingObjectXJ<T: NSObject>(_ any: T?) -> Any?{
        guard let unPackageAny = any else {
            return nil
        }
        if unPackageAny is NSArray{
            var resultArray:[Any] = []
            guard let unPackageArray = (unPackageAny as? NSArray) else{
                return nil
            }
            for data in unPackageArray{
                if data is NSObject {
                    if let data = serializingObjectXJ(data as? NSObject) {
                        resultArray.append(data)
                    }
                }
            }
            return resultArray
        }else if unPackageAny is NSDictionary{
            guard let propertyList = (unPackageAny as? NSDictionary)?.allKeys else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for propertyXJ in propertyList{
                if let propertyXJ = propertyXJ as? String{
                    if !propertyXJ.hasSuffix("XJ"){
                        continue
                    }
                    guard let value = any?.value(forKey: propertyXJ) else{ // KVO
                        continue
                    }
                    let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObjectXJ(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            return resultDictionary
        }else {
            guard let propertyList = XTFUtilRuntime.queryPropertyList(unPackageAny.classForCoder, endSupperClazz: NSObject.self) else{
                return nil
            }
            var resultDictionary:[String:Any] = [:]
            for propertyXJ in propertyList{
                if let propertyXJ = propertyXJ as? String{
                    if !propertyXJ.hasSuffix("XJ"){
                        continue
                    }
                    guard let value = any?.value(forKey: propertyXJ) else{ // KVO
                        continue
                    }
                    let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                    if value is NSString{
                        resultDictionary[property] = value as! String
                    }else if value is NSNumber{
                        resultDictionary[property] = value as! NSNumber
                    }else if value is NSObject {
                        if let value = serializingObjectXJ(value as? NSObject){
                            resultDictionary[property] = value
                        }
                    }
                }
            }
            return resultDictionary
        }
    }
    /// 反序列化一个XJ属性的对象/数组
    public func deSerializingXJ<T: NSObject>(_ data: Data?,_ clazz:T.Type) -> Any?{
        guard let unPackagData = data else {
            return nil
        }
        do{
            let rootJson = try JSONSerialization.jsonObject(with: unPackagData, options: JSONSerialization.ReadingOptions.mutableContainers)
            if rootJson is [Any]{
                return deSerializingXJ(rootJson as? [Any], clazz)
            } else if rootJson is [String:Any]{
                return deSerializingXJ(rootJson as? [String:Any], clazz)
            }
        }catch{
            Mylog.log("NSJSONSerialization deSerializing Error.\(error)");
        }
        return nil
    }
    /// 反序列化一个XJ属性的对象
    public func deSerializingXJ<T: NSObject>(_ dictionary: [String:Any?]?,_ clazz: T.Type) -> T?{
        guard let unPackagDictionary = dictionary else {
            return nil
        }
        let result:T = clazz.init()
        if !T.accessInstanceVariablesDirectly {
            return result
        }
        guard let propertyList = XTFUtilRuntime.queryPropertyList(clazz, endSupperClazz: NSObject.self) else {
            return result
        }
        for propertyXJ in propertyList{
            if let propertyXJ = propertyXJ as? String{
                if !propertyXJ.hasSuffix("XJ"){
                    continue
                }
                let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                var value = unPackagDictionary[property] as AnyObject?
                // NSString, NSNumber, or NSNull
                if value == nil || value is NSNull{
                    continue
                }
                // KVO
                do {
                    try result.validateValue(&value, forKey: propertyXJ)
                    result.setValue(value, forKey: propertyXJ)
                }catch{
                    Mylog.log("尝试设置实体属性值时发生错误类型不匹配.属性名:\(propertyXJ),属性值:\(value!)")
                }
            }
        }
        return result
    }
    /// 反序列化一个XJ属性的数组
    public func deSerializingXJ<T: NSObject>(_ array: [Any?]?,_ clazz:T.Type) -> [T]?{
        guard let unPackagArray = array else {
            return nil
        }
        var resultArray:[T] = []
        if !T.accessInstanceVariablesDirectly {
            return resultArray
        }
        guard let propertyList = XTFUtilRuntime.queryPropertyList(clazz, endSupperClazz: NSObject.self) else {
            return resultArray
        }
        for data in unPackagArray{
            if let unPackagDictionary = data as? [String: Any?]{
                let result:T = clazz.init()
                for propertyXJ in propertyList{
                    if let propertyXJ = propertyXJ as? String{
                        if !propertyXJ.hasSuffix("XJ"){
                            continue
                        }
                        let property = propertyXJ.substring(to: propertyXJ.index(propertyXJ.endIndex, offsetBy: -2))
                        var value = unPackagDictionary[property] as AnyObject?
                        // NSString, NSNumber, or NSNull
                        if value == nil || value is NSNull{
                            continue
                        }
                        // KVO
                        do {
                            try result.validateValue(&value, forKey: propertyXJ)
                            result.setValue(value, forKey: propertyXJ)
                        }catch{
                            Mylog.log("尝试设置实体属性值时发生错误类型不匹配.属性名:\(propertyXJ),属性值:\(value!)")
                        }
                    }
                }
                resultArray.append(result)
            }
        }
        return resultArray
    }
}
