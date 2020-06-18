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
    /// 可序列化接口初始化[是否继承协议: if let _ = classType as? JsonSerializable.Type, 永远拷贝代码模式,防止静态方法并发]
    @inline(__always) public static func createSerializableObject<T: JsonSerializable>(_ properties:[String: Any]?,_ classType:T.Type)-> T?{
        return properties == nil ? nil : classType.init(properties)
    }
    /// 可序列化接口数组初始化
    @inline(__always) public static func createSerializableArray<T: JsonSerializable>(_ arrayProperties:[Any]?,_ classType:T.Type)-> [T]?{
        if let arrayProperties = arrayProperties{
            var array:[T] = []
            for properties in arrayProperties{
                if let properties = properties as? [String:Any]{
                    if let t = UtilJson.createSerializableObject(properties, classType){
                        array.append(t)
                    }
                }
            }
            return array
        }
        return nil
    }
    /// KVC编程模式赋属性值(必须类型匹配,注意: NSNull匹配错误)
    @inline(__always) public static func setupSerializableProperties(_ properties:[String: Any]?, target:AnyObject?){
        if let target = target{
            if let properties = properties{
                for (key,value) in properties{
                    target.setValue(value, forKeyPath: key)
                }
            }
        }
    }
}

/// 可序列化接口
public protocol JsonSerializable {
    // JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
    // 初始化一个对象, 系统JSON结果,只支持NSString,NSNumber,NSArray,NSDictionary,NSNull
    init?(_ properties:[String:Any]?) //key:value Dictionary init return nil enable
    // init?(_ dic:[String:Any]?){ return nil }
}

/// Json 对象操作
public let TAG_UtilJson = "UtilJson"
public struct Json{
    public enum TypeJson: Int {
        case string
        case number
        case array
        case dictionary
        case null
    }
    var valueArray:[Any] = []
    var valueString:String = ""
    var valueNumber:NSNumber = 0
    var valueNull:NSNull = NSNull()
    var valueDictionary:[String: Any] = [:]
    public var typeJson:TypeJson = .null
    public var error: NSError? = nil
    public static var null = { return Json(data: nil) }()
    // Json 根
    var jsonObject:Any {
        get{
            switch typeJson {
            case .string:
                return valueString
            case .number:
                return valueNumber
            case .array:
                return valueArray
            case .dictionary:
                return valueDictionary
            case .null:
                return valueNull
            }
        }
        set{
            switch newValue {
            case let string as String:
                typeJson = .string
                valueString = string
            case let number as NSNumber:
                typeJson = .number
                valueNumber = number
            case let array as [Any]:
                typeJson = .array
                valueArray = array
            case let dictionary as [String: Any]:
                typeJson = .dictionary
                valueDictionary = dictionary
            default:
                typeJson = .null
                error = NSError(domain: TAG_UtilJson, code: 0x0001, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
            }
        }
    }
    public init(data:Data?, error:NSErrorPointer = nil) {
        guard let gData = data else {
            self.jsonObject = NSNull()
            return
        }
        do{ //generate mutable NSArrays and NSDictionaries
            self.jsonObject = try JSONSerialization.jsonObject(with: gData, options: .mutableContainers)
        }catch let aError as NSError{
            if let error = error{
                error.pointee = aError
            }
            print("JSONSerialization 初始化失败.\(aError)")
            self.jsonObject = NSNull()
        }
    }
    // Subscript/Literal init
    fileprivate init(_ data:Any){
        switch data {
        case let data as [Json] where data.count > 0:
            self.init(array: data)
        case let data as [String: Json] where data.count > 0:
            self.init(dictionary: data)
        case let data as Data:
            self.init(data: data)
        default:
            self.init(data: data)
        }
    }
    private init(array:[Json]){
        self.init(array.map { $0.jsonObject }) //init(_:)
    }
    private init(dictionary:[String: Json]){
        var newDictionary = [String: Any](minimumCapacity: dictionary.count)
        for (key,value) in dictionary{
            newDictionary[key] = value.jsonObject
        }
        self.init(newDictionary) //init(_:)
    }
    private init(data:Any){
        self.jsonObject = data
    }
    // 获取数据的各种操作封装....
    // Subscript 重点[subscript的使用]
    public subscript(index: Int) -> Json{
        get{
            if typeJson != .array{
                return Json.error(error: error, message: "Array[\(index)] failure, It is not an array")
            }
            if index >= 0 && index < valueArray.count{
                return Json(valueArray[index])
            }
            return Json.error(error: error, message: "Array[\(index)] is out of bounds")
        }
        set{
            if typeJson == .array && valueArray.count > index && newValue.error == nil{
                valueArray[index] = newValue
            }
        }
    }
    public subscript(key: String) -> Json{
        get{
            if typeJson == .dictionary{
                if let data = valueDictionary[key]{
                    return Json(data)
                }
                return Json.error(error: error, message: "Dictionary[\"\(key)\"] does not exist")
            }
            return Json.error(error: error, message: "Dictionary[\"\(key)\"] failure, It is not an dictionary")
        }
        set{
            if typeJson == .dictionary && newValue.error == nil{
                valueDictionary[key] = newValue.jsonObject // Key:Value(Json value)
            }
        }
    }
    //let name = json[9,"list","person","name"]  The same as: let name = json[9]["list"]["person"]["name"] 帅
    public subscript(indexs:JsonSubscriptType...) -> Json{
        get{ return self[indexs] }
        set{ self[indexs] = newValue }
    }
    public subscript(indexs:[JsonSubscriptType]) -> Json{
        get{
            // reduce:结果跌代函数(初始化结果,结果迭代函数)
            return indexs.reduce(self, { (json, index) -> Json in
                return json[index]
            })
        }
        set{
            switch indexs.count{
            case 0:
                return
            case 1:// json[0] = "tiantian"
                self[indexs[0]].jsonObject = newValue.jsonObject //subscript(index:JsonSubscriptType)
            default:// json[0,"person","name"] = "tiantian"
                // 递归赋值
                var path = indexs
                path.remove(at: 0)
                var nextJson = self[indexs[0]]
                nextJson[path] = newValue //subscript(indexs:[JsonSubscriptType])
                self[indexs[0]] = nextJson //subscript(index:JsonSubscriptType)
            }
        }
    }
    private subscript(index:JsonSubscriptType) -> Json{
        get{
            switch index.jsonKey{
            case .index(let index):
                return self[index]
            case .key(let key):
                return self[key]
            }
        }
        set{
            switch index.jsonKey{
            case .index(let index):
                self[index] = newValue
            case .key(let key):
                self[key] = newValue
            }
        }
    }
    /// 尝试转型获取值,JSON基本类型
    public var arrayValue: [Any]?{
        if typeJson == .array{
            return valueArray
        }
        return nil
    }
    public var dictionaryValue: [String: Any]?{
        if typeJson == .dictionary{
            return valueDictionary
        }
        return nil
    }

    public var stringValue: String?{
        switch typeJson {
        case .string:
            return valueString
        case .number:
            if isBoolNumber(valueNumber){
                let bool:Bool? = valueNumber.boolValue
                return bool.map({ String($0) })
            }
            return valueNumber.stringValue
        default:
            return nil
        }
    }
    public var numberValue: NSNumber?{
        switch typeJson {
        case .number:
            return valueNumber
        case .string:
            // 字符串尝试转为NSNumber
            let decimal = NSDecimalNumber(string: valueString)
            if decimal == .notANumber{ // 转型失败
                return nil
            }
            return decimal
        default:
            return nil
        }
    }
    /// 尝试转型常用类型
    public var boolValue: Bool?{
        switch typeJson {
        case .number:
            return valueNumber.boolValue
        case .string:
            // 字符串尝试匹配为bool值
            return ["true","y","t"].contains(){ truthyString in
                return valueString.caseInsensitiveCompare(truthyString) == .orderedSame
            }
        default:
            return nil
        }
    }
    public var intValue: Int?{
        switch typeJson {
        case .number:
            return valueNumber.intValue
        case .string:
            let decimal = NSDecimalNumber(string: valueString)
            if decimal == .notANumber{ // 转型失败
                return nil
            }
            return decimal.intValue
        default:
            return nil
        }
    }
    public var doubleValue: Double?{
        switch typeJson {
        case .number:
            return valueNumber.doubleValue
        case .string:
            let decimal = NSDecimalNumber(string: valueString)
            if decimal == .notANumber{ // 转型失败
                return nil
            }
            return decimal.doubleValue
        default:
            return nil
        }
    }
    ///
    public static func error(error:NSError?, message:String) -> Json{
        var result = Json.null
        result.error = error ?? NSError(domain: TAG_UtilJson, code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        return result
    }
    func isBoolNumber(_ number:NSNumber) -> Bool{
        let objCType = String(cString: number.objCType)
        let trueNumber = NSNumber(value: true)
        let falseNumber = NSNumber(value: false)
        let trueObjTType = String(cString: trueNumber.objCType)
        let falseObjTType = String(cString: falseNumber.objCType)
        if (number.compare(trueNumber) == .orderedSame && objCType == trueObjTType) || (number.compare(falseNumber) == .orderedSame && objCType == falseObjTType) {
            return true
        }else{
           return false
        }
    }
}
public enum JsonKey{
    case index(Int)
    case key(String)
}
// 统一String,Int类型的接口
public protocol JsonSubscriptType{
    var jsonKey:JsonKey{ get } // Protocol var
}
extension Int: JsonSubscriptType{
    public var jsonKey: JsonKey {
        return JsonKey.index(self)
    }
}
extension String: JsonSubscriptType{
    public var jsonKey: JsonKey {
        return JsonKey.key(self)
    }
}
// 字面转型构造器 let json:Json = "{key:value}"
extension Json: ExpressibleByStringLiteral{
    public init(stringLiteral value: StringLiteralType) {
        self.init(data: value.data(using: .utf8))
    }
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(data: value.data(using: .utf8))
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(data: value.data(using: .utf8))
    }
}
extension Json: ExpressibleByArrayLiteral{
    public init(arrayLiteral elements: Any...) {
        self.init(elements as Any)
    }
}
extension Json: ExpressibleByDictionaryLiteral{
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dicationaryArray = elements
        self.init(dictionaryLiteral: dicationaryArray)
    }
    public init(dictionaryLiteral elements: [(String, Any)]) {
        let funcJsonFromDictionaryLiteral:([String: Any]) -> Json = {
            dictionary in
            let initElement = Array(dictionary.keys).flatMap({ (key) -> (String,Any)? in
                if let value = dictionary[key]{
                    return (key, value)
                }
                return nil
            })
            return Json(dictionaryLiteral: initElement)
        }
        var dict = [String: Any](minimumCapacity: elements.count)
        for element in elements{
            let elementToSet: Any
            if let json = element.1 as? Json{
                elementToSet = json.jsonObject
            }else if let jsonArray = element.1 as? [Json]{
                elementToSet = Json(jsonArray).jsonObject
            }else if let dictionary = element.1 as? [String: Any]{
                elementToSet = funcJsonFromDictionaryLiteral(dictionary).jsonObject
            }else if let dictArray = element.1 as? [[String: Any]]{
                let jsonArray = dictArray.map{funcJsonFromDictionaryLiteral($0)}
                elementToSet = Json(jsonArray).jsonObject
            }else{
                elementToSet = element.1
            }
            dict[element.0] = elementToSet
        }
        self.init(dict)
    }
}
// Comparable == (json == Json.null)
extension Json: Swift.Comparable{}
public func ==(lhs:Json, rhs:Json) -> Bool{
    switch (lhs.typeJson, rhs.typeJson) {
    case (.null, .null):
        return true
    case (.array, .array):
        return lhs.valueArray as NSArray == rhs.valueArray as NSArray
    case (.dictionary, .dictionary):
        return lhs.valueDictionary as NSDictionary == rhs.valueDictionary as NSDictionary
    default:
        return false
    }
}
public func <(lhs:Json, rhs:Json) -> Bool{
    return false
}
// 打印
extension Json: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
        do{
            switch typeJson {
            case .string:
                return valueString
            case .number:
                return valueNumber.description
            case .array:
                guard JSONSerialization.isValidJSONObject(valueArray) else {
                    return "Json is invalid"
                }
                return String(data: try JSONSerialization.data(withJSONObject: valueArray, options: .prettyPrinted), encoding: .utf8)!
            case .dictionary:
                guard JSONSerialization.isValidJSONObject(valueDictionary) else {
                    return "Json is invalid"
                }
                return String(data: try JSONSerialization.data(withJSONObject: valueDictionary, options: .prettyPrinted), encoding: .utf8)!
            case .null:
                return "null"
            }
        }catch{
            return "\(error)"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

