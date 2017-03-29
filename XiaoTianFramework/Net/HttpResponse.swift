//
//  HttpResponse.swift
//  DriftBook
//  网络请求返回根类
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
class HttpResponse : NSObject {
    static let CODE_ERROR_HTTP = 4409
    static let CODE_ERROR_URL = 4408
    static let CODE_ERROR_JSON = 4407
    static let CODE_ERROR_DATA = 4406
    static let CODE_ERROR_CONTEXT = 4405
    static let TYPE_SUCCESS = 1
    static let TYPE_FAILED = 0
    static let TYPE_SELF_LOSE = -1 // self 丢失页面无效
    
    var codeXJ : NSNumber? //错误码 200:成功,400:Token错误
    var successXJ : NSNumber? //成功标志 1:成功,0:失败
    var msgXJ : String? //错误信息
    var dataXJ : NSDictionary? //返回data数据
    //
    var response : NSDictionary? // 返回的Json对象数据
    
    // 其他携带到HttpResponse的参数
    var resultExtra: AnyObject?
    var resultExtraArray: [AnyObject]?
    // 构造器
    override init(){} //必须包含无参构造器,系统实例化入口
    
    init(success:NSNumber = 0, code:NSNumber = 4409, msg:String = "请求错误.") {
        self.successXJ = success
        self.codeXJ = code
        self.msgXJ = msg
    }
    
    // 请求是否成功
    func isSuccess() -> Bool {
        return successXJ == nil ? false : successXJ?.integerValue == 1
    }
    
    // 用户Token是否错误
    func isTokenError() -> Bool {
        return codeXJ == nil ? false : codeXJ?.integerValue == 400
    }
    
    // 获取data子对象
    func getDataSubObject(key:String) -> NSDictionary?{
        if dataXJ == nil {
            return nil
        }
        return dataXJ?.objectForKey(key) as? NSDictionary
    }
    
    // 获取data子数组
    func getDataSubArray(key:String) -> [AnyObject]?{
        if dataXJ == nil {
            return nil
        }
        return dataXJ?.objectForKey(key) as? [AnyObject]
    }
    
    // 携带参数转型
    func getResultExtra<T>(clazz: T.Type) -> T?{
        if resultExtra == nil{
            return nil
        }
        return resultExtra as? T
    }
    // 携带参数组转型
    func getResultExtraArray<T>(clazz: T.Type) -> [T]?{
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
    static func genHttpResponse(responseData:NSData?) -> HttpResponse{
        if responseData == nil {
            return HttpResponse(success: TYPE_FAILED, code: CODE_ERROR_DATA, msg: "反序列化为HttpResponse错误,数据为空.")
        }
        let httpResponse = XTFSerializerJson().deSerializing(responseData, clazz: HttpResponse.self)
        if httpResponse == nil {
            return HttpResponse(success: TYPE_FAILED, code: CODE_ERROR_DATA, msg: "反序列化为HttpResponse错误,JSON数据不合法.JSON:\(String(data:responseData!, encoding:NSUTF8StringEncoding)!)")
        }
        return httpResponse as! HttpResponse
    }
    
    static func genSelfLoseResponse()-> HttpResponse{
        return HttpResponse(success: TYPE_SELF_LOSE, code: CODE_ERROR_CONTEXT, msg: "页面数据访问错误,请重新打开页面.")
    }
    
    // 生成请求错误返回Data
    static func genDataResponseFailure(code:NSNumber, msg:String) -> NSData {
        return "{\"code\":\(code),\"success\":0,\"msg\":\"\(msg)\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    static func genDataResponseFailure(msg:String) -> NSData {
        return "{\"code\":\(CODE_ERROR_HTTP),\"success\":0,\"msg\":\"\(msg)\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    static func genDataResponse(code:NSNumber, success:NSNumber, msg:String) -> NSData {
        return "{\"code\":\(CODE_ERROR_HTTP),\"success\":\(success),\"msg\":\"\(msg)\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }

}
