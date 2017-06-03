//
//  HttpRequestXT.swift
//  DriftBook
//  网络请求
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(HttpRequestXT)
open class HttpRequest : NSObject{
    /// You can use NSURL, NSURLRequest and NSURLSession or NSURLConnection ,NSURLSession is preferred
    func request(_ url:String, method:String, params:NSDictionary){
        
    }
    
    /// 普通Get请求
    open func getRequest(_ url:String, parameters:NSDictionary?) -> Data{
        let sem:DispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        var nsurl:URL?
        if (parameters != nil){
            var urlParams:[String] = []
            let enumerator = parameters?.keyEnumerator()
            while let key = enumerator?.nextObject() {
                let value = parameters?.object(forKey: key)
                if value != nil {
                    urlParams.append("\(key)=\(value!)")
                }
            }
            // 构造
            if urlParams.count > 0 {
                nsurl = URL(string: "\(url)\(url.contains("?") ? "/" : "?" )\(urlParams.joined(separator: "&"))")
            }
        }
        if nsurl == nil {
            nsurl = URL(string: url)
        }
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        //
        var resultData: Data!
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(url: nsurl!)
        // 请求的 Method
        requestUrl.httpMethod = HttpProperty.Method.GET
        // 请求的内容类型 Content_Type
        requestUrl.addValue(HttpProperty.ContentType.APPLICATION_FORM_URLENCODEED, forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_TYPE)
        // 请求持续性 Connection
        requestUrl.addValue(HttpProperty.Connection.KEEP_ALIVE, forHTTPHeaderField: HttpProperty.HeaderProperty.CONNECTION)
        // 请求代理类型名称 User-Agent
        requestUrl.addValue(HttpProperty.UserAgent.IOS, forHTTPHeaderField: HttpProperty.HeaderProperty.USER_AGENT)
        // 请求的编码 Charset
        requestUrl.addValue(HttpProperty.Charset.UTF_8, forHTTPHeaderField: HttpProperty.HeaderProperty.CHARSET)
        // 请求超时时间(单位 s/秒)
        requestUrl.timeoutInterval = 2 * 60;
        // 请求传递内容长度(get 在请求体里不传递内容,请求参数在URL上)
        requestUrl.addValue("0", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        // 构造请求
        let requestTask = urlSession.dataTask(with: requestUrl as URLRequest, completionHandler: {
            (data, urlResponse, error) in
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                resultData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                resultData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            sem.signal() // 发信号,解锁
        })
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        let _ = sem.wait(timeout: DispatchTime.distantFuture); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: String.Encoding.utf8))
        return resultData
    }
    
    /// 普通Post请求
    open func postRequest(_ url:String, parameters:NSDictionary?) -> Data{
        let sem:DispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        let nsurl:URL? = URL(string: url)
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        // 构造请求参数Body
        var requestString: String! = nil
        var requestData: Data? = nil
        if parameters != nil {
            let enumerator = parameters?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = parameters?.object(forKey: key)
                if value == nil {
                    continue
                }
                requestString = requestString == nil ? "\(key)=\(value!)" : "\(requestString)&\(key)=\(value!)"
            }
            // 常量参数
            requestData = requestString.data(using: String.Encoding.utf8)
        }
        var resultData: Data!
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(url: nsurl!)
        // 请求的 Method
        requestUrl.httpMethod = HttpProperty.Method.POST
        // 请求的内容类型 Content_Type
        requestUrl.addValue(HttpProperty.ContentType.APPLICATION_FORM_URLENCODEED, forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_TYPE)
        // 请求持续性 Connection
        requestUrl.addValue(HttpProperty.Connection.KEEP_ALIVE, forHTTPHeaderField: HttpProperty.HeaderProperty.CONNECTION)
        // 请求代理类型名称 User-Agent
        requestUrl.addValue(HttpProperty.UserAgent.IOS, forHTTPHeaderField: HttpProperty.HeaderProperty.USER_AGENT)
        // 请求的编码 Charset
        requestUrl.addValue(HttpProperty.Charset.UTF_8, forHTTPHeaderField: HttpProperty.HeaderProperty.CHARSET)
        // 请求超时时间(单位 s/秒)
        requestUrl.timeoutInterval = 2 * 60
        // 请求传递内容长度(Post 的请求参数在请求Body内容传递)
        if requestData == nil {
            requestUrl.addValue("0", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        } else {
            requestUrl.addValue(String(describing: requestData?.count), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求参数
        requestUrl.httpBody = requestData
        // 构造请求
        let requestTask = urlSession.dataTask(with: requestUrl as URLRequest, completionHandler: {
            (data, urlResponse, error) in
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                resultData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                resultData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            sem.signal() // 发信号,解锁
        })
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        Mylog.log(requestString)
        let _ = sem.wait(timeout: DispatchTime.distantFuture); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: String.Encoding.utf8))
        return resultData
    }
    
    /// Post表单请求
    open func postFormRequest(_ url:String, parameters:NSDictionary?, parameterFiles:NSDictionary?) -> Data{
        let sem:DispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程[调度信号]
        // 构造请求URL
        let nsurl:URL? = URL(string: url)
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        // 构造Form请求参数Body
        let boundary = genBoundary()
        var requestData: NSMutableData! = nil
        if parameters != nil {
            // 普通form表单参数
            let wrapParams = NSMutableDictionary(dictionary: parameters!)
            let enumerator = wrapParams.keyEnumerator()
            while let key = enumerator.nextObject(){
                let value = wrapParams.object(forKey: key)
                if value == nil {
                    continue
                }
                if requestData == nil {
                    requestData = NSMutableData()
                }
                requestData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                requestData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n".data(using: String.Encoding.utf8)!)
                requestData.append("Content-Type: text/plain; charset=UTF-8\r\n".data(using: String.Encoding.utf8)!)
                requestData.append("Content-Transfer-Encoding: 8bit\r\n".data(using: String.Encoding.utf8)!)
                requestData.append("\r\n".data(using: String.Encoding.utf8)!)
                requestData.append(("\(value!)".data(using: String.Encoding.utf8))!)
                requestData.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        if parameterFiles != nil {
            // form表单文件
            let enumerator = parameterFiles?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = parameterFiles?.object(forKey: key)
                if value == nil {
                    continue
                }
                if requestData == nil {
                    requestData = NSMutableData()
                }
                // Translate File Stream Boundary
                func writeFileStream(_ filePath: String){
                    if FileManager.default.fileExists(atPath: filePath){
                        do {
                            let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: NSData.ReadingOptions())
                            requestData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                            requestData.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(getFileName(filePath))\"\r\n".data(using: String.Encoding.utf8)!)
                            requestData.append("Content-Type: application/octet-stream; charset=UTF-8\r\n".data(using: String.Encoding.utf8)!)
                            requestData.append("\r\n".data(using: String.Encoding.utf8)!)
                            requestData.append(fileData)
                            requestData.append("\r\n".data(using: String.Encoding.utf8)!)
                        } catch {
                            Mylog.log("Translate File Stream Boundary Error")
                        }
                    }
                }
                if value is String?{
                    // 单张图片
                    let filePath :String = value as! String
                    writeFileStream(filePath)
                } else if value is [String]?{
                    // 多张图片
                    for filePath: String in value as! [String]{
                        writeFileStream(filePath)
                    }
                }
            }
        }
        // form表单数据结束标识
        requestData.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        //
        var resultData: Data!
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(url: nsurl!)
        // 请求的 Method
        requestUrl.httpMethod = HttpProperty.Method.POST
        // 请求的内容类型 Content_Type
        requestUrl.addValue("\(HttpProperty.ContentType.MULTIPART_FORM_DATA); boundary=\(boundary)", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_TYPE)
        // 请求持续性 Connection
        requestUrl.addValue(HttpProperty.Connection.KEEP_ALIVE, forHTTPHeaderField: HttpProperty.HeaderProperty.CONNECTION)
        // 请求代理类型名称 User-Agent
        requestUrl.addValue(HttpProperty.UserAgent.IOS, forHTTPHeaderField: HttpProperty.HeaderProperty.USER_AGENT)
        // 请求的编码 Charset
        requestUrl.addValue(HttpProperty.Charset.UTF_8, forHTTPHeaderField: HttpProperty.HeaderProperty.CHARSET)
        
        // 请求超时时间(单位 s/秒)
        requestUrl.timeoutInterval = 2 * 60;
        // 请求传递内容长度(Post 的请求参数在请求Body内容传递)
        if requestData == nil {
            requestUrl.addValue("0", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        } else {
            requestUrl.addValue(String(describing: requestData?.length), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求Body数据体
        requestUrl.httpBody = requestData as Data
        // 构造请求
        
        let requestTask = urlSession.dataTask(with: requestUrl as URLRequest, completionHandler: {
            (data, urlResponse, error) in
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                resultData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                resultData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            sem.signal() // 发信号,解锁
        })
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        Mylog.log(formatRequestParams(parameters, parameterFiles))
        let _ = sem.wait(timeout: DispatchTime.distantFuture); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: String.Encoding.utf8))
        return resultData
    }
    
    /// 生成Form表单Boundary边界标识
    open func genBoundary() -> String{
        let date = String(Int64(Date().timeIntervalSince1970 * 1000))
        return "---------------------------\(date)---------------------------"
    }
    
    /// 获取文件名
    open func getFileName(_ filePath:String) -> String{
        let paths = filePath.characters.split(separator: "/").map(String.init)
        return paths[paths.count - 1]
    }
    
    /// 请求参数格式化为String
    open func formatRequestParams(_ params:NSDictionary?...) -> String{
        var result:String! = nil;
        for param in params {
            let enumerator = param?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = param?.object(forKey: key)
                result = result == nil ? "\(key)=\(value == nil ? "nil" : value!)" : "\(result),\(key)=\(value == nil ? "nil" : value!)"
            }
        }
        return result
    }
    /// 过滤空值的Dictionary [过滤掉 nil 值对]
    open func filterParamsNilValue(_ params:[String: AnyObject?]) -> NSDictionary{
        let resultDic = NSMutableDictionary()
        let unnilParams = params.filter(){ return $0.1 != nil } // filter nil value
        for (key, value) in unnilParams{
            resultDic.setValue(value!, forKey: key) // Un Option Value
        }
        return resultDic
    }
    /// Array String 提交前格式化为[xxx,xxx,xxx]字符串
    open func formatArrayToString(_ arrrayString:[String]?) -> String? {
        if arrrayString == nil || arrrayString!.isEmpty{
            return nil
        }
        var result = "["
        for (index,value) in arrrayString!.enumerated() {
            result.append(index == 0 ? "\(value)" : ",\(value)")
        }
        result.append("]")
        return result
    }
}
