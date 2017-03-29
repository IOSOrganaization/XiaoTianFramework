//
//  HttpRequestXT.swift
//  DriftBook
//  网络请求
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class HttpRequest : NSObject{
    /// You can use NSURL, NSURLRequest and NSURLSession or NSURLConnection ,NSURLSession is preferred
    func request(url:String, method:String, params:NSDictionary){
        
    }
    
    /// 普通Get请求
    func getRequest(url:String, parameters:NSDictionary?) -> NSData{
        let sem:dispatch_semaphore_t = dispatch_semaphore_create(0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        var nsurl:NSURL?
        if (parameters != nil){
            var urlParams:[String] = []
            let enumerator = parameters?.keyEnumerator()
            while let key = enumerator?.nextObject() {
                let value = parameters?.objectForKey(key)
                if value != nil {
                    urlParams.append("\(key)=\(value!)")
                }
            }
            // 构造
            if urlParams.count > 0 {
                nsurl = NSURL(string: "\(url)\(url.containsString("?") ? "/" : "?" )\(urlParams.joinWithSeparator("&"))")
            }
        }
        if nsurl == nil {
            nsurl = NSURL(string: url)
        }
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        //
        var resultData: NSData!
        let defaultConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
        let urlSession = NSURLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(URL: nsurl!)
        // 请求的 Method
        requestUrl.HTTPMethod = HttpProperty.Method.GET
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
        let requestTask = urlSession.dataTaskWithRequest(requestUrl){
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
            dispatch_semaphore_signal(sem) // 发信号,解锁
        }
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: NSUTF8StringEncoding))
        return resultData
    }
    
    /// 普通Post请求
    func postRequest(url:String, parameters:NSDictionary?) -> NSData{
        let sem:dispatch_semaphore_t = dispatch_semaphore_create(0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        let nsurl:NSURL? = NSURL(string: url)
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        // 构造请求参数Body
        var requestString: String! = nil
        var requestData: NSData? = nil
        if parameters != nil {
            let enumerator = parameters?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = parameters?.objectForKey(key)
                if value == nil {
                    continue
                }
                requestString = requestString == nil ? "\(key)=\(value!)" : "\(requestString)&\(key)=\(value!)"
            }
            // 常量参数
            requestData = requestString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        var resultData: NSData!
        let defaultConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
        let urlSession = NSURLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(URL: nsurl!)
        // 请求的 Method
        requestUrl.HTTPMethod = HttpProperty.Method.POST
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
            requestUrl.addValue(String(requestData?.length), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求参数
        requestUrl.HTTPBody = requestData
        // 构造请求
        let requestTask = urlSession.dataTaskWithRequest(requestUrl){
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
            dispatch_semaphore_signal(sem) // 发信号,解锁
        }
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        Mylog.log(requestString)
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: NSUTF8StringEncoding))
        return resultData
    }
    
    /// Post表单请求
    func postFormRequest(url:String, parameters:NSDictionary?, parameterFiles:NSDictionary?) -> NSData{
        let sem:dispatch_semaphore_t = dispatch_semaphore_create(0) // 创建调度线程锁,锁定线程[调度信号]
        // 构造请求URL
        let nsurl:NSURL? = NSURL(string: url)
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
                let value = wrapParams.objectForKey(key)
                if value == nil {
                    continue
                }
                if requestData == nil {
                    requestData = NSMutableData()
                }
                requestData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestData.appendData("Content-Type: text/plain; charset=UTF-8\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestData.appendData("Content-Transfer-Encoding: 8bit\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                requestData.appendData(("\(value!)".dataUsingEncoding(NSUTF8StringEncoding))!)
                requestData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        if parameterFiles != nil {
            // form表单文件
            let enumerator = parameterFiles?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = parameterFiles?.objectForKey(key)
                if value == nil {
                    continue
                }
                if requestData == nil {
                    requestData = NSMutableData()
                }
                // Translate File Stream Boundary
                func writeFileStream(filePath: String){
                    if NSFileManager.defaultManager().fileExistsAtPath(filePath){
                        do {
                            let fileData = try NSData(contentsOfFile: filePath, options: NSDataReadingOptions())
                            requestData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                            requestData.appendData("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(getFileName(filePath))\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                            requestData.appendData("Content-Type: application/octet-stream; charset=UTF-8\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                            requestData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                            requestData.appendData(fileData)
                            requestData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
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
        requestData.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        //
        var resultData: NSData!
        let defaultConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
        let urlSession = NSURLSession(configuration: defaultConfigObject)
        // 请求配置
        let requestUrl = NSMutableURLRequest(URL: nsurl!)
        // 请求的 Method
        requestUrl.HTTPMethod = HttpProperty.Method.POST
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
            requestUrl.addValue(String(requestData?.length), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求Body数据体
        requestUrl.HTTPBody = requestData
        // 构造请求
        let requestTask = urlSession.dataTaskWithRequest(requestUrl){
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
            dispatch_semaphore_signal(sem) // 发信号,解锁
        }
        // 发送请求
        requestTask.resume()
        
        Mylog.log(nsurl)
        Mylog.log(formatRequestParams(parameters, parameterFiles))
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); // 锁定,等待解锁
        
        Mylog.log(String(data: XTFSerializerJson().formatJSONData(resultData), encoding: NSUTF8StringEncoding))
        return resultData
    }
    
    /// 生成Form表单Boundary边界标识
    func genBoundary() -> String{
        let date = String(Int64(NSDate().timeIntervalSince1970 * 1000))
        return "---------------------------\(date)---------------------------"
    }
    
    /// 获取文件名
    func getFileName(filePath:String) -> String{
        let paths = filePath.characters.split("/").map(String.init)
        return paths[paths.count - 1]
    }
    
    /// 请求参数格式化为String
    func formatRequestParams(params:NSDictionary?...) -> String{
        var result:String! = nil;
        for param in params {
            let enumerator = param?.keyEnumerator()
            while let key = enumerator?.nextObject(){
                let value = param?.objectForKey(key)
                result = result == nil ? "\(key)=\(value == nil ? "nil" : value!)" : "\(result),\(key)=\(value == nil ? "nil" : value!)"
            }
        }
        return result
    }
    /// 过滤空值的Dictionary [过滤掉 nil 值对]
    func filterParamsNilValue(params:[String: AnyObject?]) -> NSDictionary{
        let resultDic = NSMutableDictionary()
        let unnilParams = params.filter(){ return $0.1 != nil } // filter nil value
        for (key, value) in unnilParams{
            resultDic.setValue(value!, forKey: key) // Un Option Value
        }
        return resultDic
    }
    /// Array String 提交前格式化为[xxx,xxx,xxx]字符串
    func formatArrayToString(arrrayString:[String]?) -> String? {
        if arrrayString == nil || arrrayString!.isEmpty{
            return nil
        }
        var result = "["
        for (index,value) in arrrayString!.enumerate() {
            result.appendContentsOf(index == 0 ? "\(value)" : ",\(value)")
        }
        result.appendContentsOf("]")
        return result
    }
}