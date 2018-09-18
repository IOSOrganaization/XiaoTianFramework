//
//  HttpResponse.swift
//  DriftBook
//  网络请求返回根类
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(HttpResponseXT)
open class HttpResponse : NSObject {
    public static let CODE_ERROR_HTTP: Int = 4409
    public static let CODE_ERROR_URL: Int = 4408
    public static let CODE_ERROR_JSON: Int = 4407
    public static let CODE_ERROR_DATA: Int = 4406
    public static let CODE_ERROR_CONTEXT: Int = 4405
    public static let TYPE_SUCCESS: Int = 1
    public static let TYPE_FAILED: Int = 0
    public static let TYPE_SELF_LOSE: Int = -1 // self 丢失页面无效
    //
    public var codeXJ : Int? //错误码 200:成功,400:Token错误
    public var successXJ : Int? //成功标志 1:成功,0:失败
    public var msgXJ : String? //错误信息
    public var dataXJ : NSDictionary? //返回data数据
    //
    public var response : NSDictionary? // 返回的Json对象数据
    
    // 其他携带到HttpResponse的参数
    public var resultExtra: AnyObject?
    public var resultExtraArray: [AnyObject]?
    // 构造器
    public override init(){} //必须包含无参构造器,系统实例化入口
    
    public init(success:Int = 0, code:Int = 4409, msg:String = "请求错误.") {
        self.successXJ = success
        self.codeXJ = code
        self.msgXJ = msg
    }
    
    // 请求是否成功
    public func isSuccess() -> Bool {
        return successXJ == nil ? false : successXJ == 1
    }
    
    // 用户Token是否错误
    public func isTokenError() -> Bool {
        return codeXJ == nil ? false : codeXJ == 400
    }
    
    // 获取data子对象
    public func getDataSubObject(_ key:String) -> NSDictionary?{
        if dataXJ == nil {
            return nil
        }
        return dataXJ?.object(forKey: key) as? NSDictionary
    }
    
    // 获取data子数组
    public func getDataSubArray(_ key:String) -> [AnyObject]?{
        if dataXJ == nil {
            return nil
        }
        return dataXJ?.object(forKey: key) as? [AnyObject]
    }
    
    // 携带参数转型
    public func getResultExtra<T>(_ clazz: T.Type) -> T?{
        if resultExtra == nil{
            return nil
        }
        return resultExtra as? T
    }
    // 携带参数组转型
    public func getResultExtraArray<T>(_ clazz: T.Type) -> [T]?{
        if resultExtraArray == nil{
            return nil
        }
        let array: [T]? = resultExtraArray?.map({ (value) -> T in
            return value as! T
        })
        return array
        
    }
    
    /************************ Static Method ************************/
    // NSData 转化为HttpResponse
    public static func genHttpResponse(_ responseData:Data?) -> HttpResponse{
        if responseData == nil {
            return HttpResponse(success: TYPE_FAILED, code: CODE_ERROR_DATA, msg: "反序列化为HttpResponse错误,数据为空.")
        }
        let httpResponse = XTFSerializerJson().deSerializing(responseData, clazz: HttpResponse.self)
        if httpResponse == nil {
            return HttpResponse(success: TYPE_FAILED, code: CODE_ERROR_DATA, msg: "反序列化为HttpResponse错误,JSON数据不合法.JSON:\(String(data:responseData!, encoding:String.Encoding.utf8)!)")
        }
        return httpResponse as! HttpResponse
    }
    
    public static func genSelfLoseResponse()-> HttpResponse{
        return HttpResponse(success: TYPE_SELF_LOSE, code: CODE_ERROR_CONTEXT, msg: "页面数据访问错误,请重新打开页面.")
    }
    
    // 生成请求错误返回Data
    public static func genDataResponseFailure(_ code:Int, msg:String) -> Data {
        return "{\"code\":\(code),\"success\":0,\"msg\":\"\(msg)\"}".data(using: String.Encoding.utf8)!
    }
    public static func genDataResponseFailure(_ msg:String) -> Data {
        return "{\"code\":\(CODE_ERROR_HTTP),\"success\":0,\"msg\":\"\(msg)\"}".data(using: String.Encoding.utf8)!
    }
    public static func genDataResponse(_ code:Int, success:Int, msg:String) -> Data {
        return "{\"code\":\(CODE_ERROR_HTTP),\"success\":\(success),\"msg\":\"\(msg)\"}".data(using: String.Encoding.utf8)!
    }
    
}
