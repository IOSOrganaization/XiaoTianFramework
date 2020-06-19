//
//  HttpRequestXT.swift
//  DriftBook
//  同步网络请求,必须在异步中调用
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(HttpRequestXT)
public class HttpRequest : NSObject{
    fileprivate var requestTaskHandler:URLSessionDataTask?
    fileprivate var requestDispatchSemaphore:DispatchSemaphore?
    fileprivate var requestCallBackHasSent: ((Int64,Int64,CGFloat) -> Void)? // sent,total,percent
    fileprivate var requestCallBackHasReceive: ((Int64,Int64,CGFloat) -> Void)? // receive,total,percent
    fileprivate var requestCacheFileURL: URL?
    fileprivate var responseCacheData: Data?
    fileprivate var requestExpectedContentLength: Int64?
    
    /// You can use NSURL, NSURLRequest and NSURLSession or NSURLConnection ,NSURLSession is preferred
    func request(_ url:String, method:String, params:NSDictionary?) -> Data{
        switch method.uppercased(){
        case "GET":
            return getRequest(url, parameters: params)
        case "POST":
            return postRequest(url, parameters: params)
        default:
            return Data()
        }
    }
    /// 普通Get请求
    open func getRequest(_ url:String, parameters:NSDictionary?) -> Data{
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
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
                nsurl = URL(string: "\(url)\(url.contains("?") ? "&" : "?" )\(urlParams.joined(separator: "&"))")
            }
        }
        if nsurl == nil {
            nsurl = URL(string: url)
        }
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        //
        let startDate = CACurrentMediaTime()
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl!)
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
        requestTaskHandler = urlSession.dataTask(with: requestUrl, completionHandler: {
            [weak self](data, urlResponse, error) in
            guard let wSelf = self else {
                return
            }
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                wSelf.responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                wSelf.responseCacheData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            self?.requestDispatchSemaphore?.signal() // 发信号,解锁
        })
        // 发送请求
        Mylog.log(nsurl)
        requestTaskHandler?.resume()
         // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求结果
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// 普通Get请求, 包含进度回调
    open func getRequest(_ url:String, parameters:NSDictionary?, hasReceive: ((Int64,Int64,CGFloat) -> Void)? = nil) -> Data{
        self.requestCallBackHasReceive = hasReceive
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
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
                nsurl = URL(string: "\(url)\(url.contains("?") ? "&" : "?" )\(urlParams.joined(separator: "&"))")
            }
        }
        if nsurl == nil {
            nsurl = URL(string: url)
        }
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        //
        let startDate = CACurrentMediaTime()
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: nil)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl!)
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
        requestTaskHandler = urlSession.dataTask(with: requestUrl)
        // 发送请求
        requestTaskHandler?.resume()
        Mylog.log(nsurl)
        // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求结果
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// 普通Post请求
    open func postRequest(_ url:String, parameters:NSDictionary?) -> Data{
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        let nsurl:URL? = URL(string: url)
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        let startDate = CACurrentMediaTime()
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
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl!)
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
            requestUrl.addValue(String(describing: requestData!.count), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求参数
        requestUrl.httpBody = requestData
        // 构造请求
        requestTaskHandler = urlSession.dataTask(with: requestUrl, completionHandler: {
            [weak self](data, urlResponse, error) in
            guard let wSelf = self else {
                return
            }
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                wSelf.responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                wSelf.responseCacheData = data ?? HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //wSelf.responseCacheData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            wSelf.requestDispatchSemaphore?.signal() // 发信号,解锁
        })
        // 发送请求
        Mylog.log(nsurl)
        requestTaskHandler?.resume()
        // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求结果
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData ?? HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
        //return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// Post Form表单请求
    open func postFormRequest(_ url:String, parameters:NSDictionary? = nil, parameterFiles:NSDictionary? = nil) -> Data{
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程[调度信号]
        // 构造请求URL
        let nsurl:URL? = URL(string: url)
        if nsurl == nil {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        let startDate = CACurrentMediaTime()
        // 构造Form请求参数Body
        let boundary = genBoundary()
        var requestData: Data! = nil
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
                    requestData = Data()
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
                    requestData = Data()
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
        if parameters != nil{
            requestData.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        }
        let defaultConfigObject = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: defaultConfigObject)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl!)
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
            requestUrl.addValue(String(describing: requestData.count), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求Body数据体
        requestUrl.httpBody = requestData
        // 构造请求
        requestTaskHandler = urlSession.dataTask(with: requestUrl, completionHandler: {
            [weak self](data, urlResponse, error) in
            guard let wSelf = self else{
                return
            }
            if error != nil {
                // 请求失败
                Mylog.log(error.debugDescription)
                wSelf.responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:(error?.localizedDescription)!)
            } else {
                // 请求成功
                wSelf.responseCacheData = data != nil ? data : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"返回数据为空.")
                //Mylog.log("执行完成,请求结束")
            }
            wSelf.requestDispatchSemaphore?.signal() // 发信号,解锁
        })
        // 发送请求
        Mylog.log(nsurl)
        requestTaskHandler?.resume()
        // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求完成
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// 普通Post请求, 包含进度回调
    open func postRequest(_ url:String, parameters:NSDictionary? = nil, hasSent: ((Int64,Int64,CGFloat) -> Void)? = nil,hasReceive: ((Int64,Int64,CGFloat) -> Void)? = nil) -> Data{
        requestCallBackHasSent = hasSent
        requestCallBackHasReceive = hasReceive
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程
        // 构造请求URL
        guard let nsurl = URL(string: url) else {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        let startDate = CACurrentMediaTime()
        // 构造请求参数Body
        var requestString: String? = nil
        var requestData: Data? = nil
        if let enumerator = parameters?.keyEnumerator() {
            while let key = enumerator.nextObject(){
                if let value = parameters?.object(forKey: key){
                    requestString = requestString == nil ? "\(key)=\(value)" : "\(requestString!)&\(key)=\(value)"
                }
            }
            // 常量参数
            requestData = requestString?.data(using: String.Encoding.utf8)
        }
        var defaultConfigObject = URLSessionConfiguration.default
        if #available(iOS 8.0, *) {
            defaultConfigObject = URLSessionConfiguration.background(withIdentifier: ProcessInfo.processInfo.globallyUniqueString)
        }else{
            defaultConfigObject = URLSessionConfiguration.ephemeral
        }
        let urlSession = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: nil)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl)
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
        if let requestData = requestData{
            requestUrl.addValue(String(describing: requestData.count), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
            // From 上传缓冲
            requestCacheFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(ProcessInfo.processInfo.globallyUniqueString), isDirectory: false)
            if let requestCacheFileURL = requestCacheFileURL{
                do{
                    try requestData.write(to: requestCacheFileURL, options: .atomic)
                }catch{
                    self.requestCacheFileURL = nil
                }
            }
        }else{
            requestUrl.addValue("0", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求参数
        requestUrl.httpBody = requestData
        // 构造请求
        if let requestCacheFileURL = requestCacheFileURL{
            requestTaskHandler = urlSession.uploadTask(with: requestUrl, fromFile: requestCacheFileURL)
        }else{
            requestTaskHandler = urlSession.dataTask(with: requestUrl)
        }
        // 发送请求
        Mylog.log(nsurl)
        requestTaskHandler?.resume()
        // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求结果
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// Post Form表单请求, 包含进度回调
    open func postFormRequest(_ url:String, parameters:NSDictionary? = nil, parameterFiles:NSDictionary? = nil, hasSent: ((Int64,Int64,CGFloat) -> Void)? = nil,hasReceive: ((Int64,Int64,CGFloat) -> Void)? = nil) -> Data{
        requestCallBackHasSent = hasSent
        requestCallBackHasReceive = hasReceive
        requestDispatchSemaphore = DispatchSemaphore(value: 0) // 创建调度线程锁,锁定线程[调度信号]
        // 构造请求URL
        guard let nsurl = URL(string: url) else {
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_URL, msg:"构造请求URL失败,请检测URL合法性.")
        }
        let startDate = CACurrentMediaTime()
        // 构造Form请求参数Body
        let boundary = genBoundary()
        var requestData: Data! = nil
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
                    requestData = Data()
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
                    requestData = Data()
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
        if requestData != nil{
            requestData.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        }
        var defaultConfigObject:URLSessionConfiguration = URLSessionConfiguration.default
        if #available(iOS 8.0, *) {
            defaultConfigObject = URLSessionConfiguration.background(withIdentifier: ProcessInfo.processInfo.globallyUniqueString)
        }else{
            defaultConfigObject = URLSessionConfiguration.ephemeral
        }
        let urlSession = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: nil)
        // 请求配置
        var requestUrl = URLRequest(url: nsurl)
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
        if let requestData = requestData{
            requestUrl.addValue(String(describing: requestData.count), forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
            requestCacheFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(ProcessInfo.processInfo.globallyUniqueString), isDirectory: false)
            if let requestCacheFileURL = requestCacheFileURL{
                do{
                    try requestData.write(to: requestCacheFileURL, options: .atomic)
                }catch{
                    self.requestCacheFileURL = nil
                }
            }
        }else{
            requestUrl.addValue("0", forHTTPHeaderField: HttpProperty.HeaderProperty.CONTENT_LENGTH)
        }
        // 请求Body数据体
        requestUrl.httpBody = requestData
        // 构造请求
        if let requestCacheFileURL = requestCacheFileURL{
            requestTaskHandler = urlSession.uploadTask(with: requestUrl, fromFile: requestCacheFileURL)
        }else{
            requestTaskHandler = urlSession.dataTask(with: requestUrl)
        }
        // 发送请求
        Mylog.log(nsurl)
        requestTaskHandler?.resume()
        // 锁定,等待解锁
        guard let _ = requestDispatchSemaphore?.wait(timeout: DispatchTime.distantFuture) else {
            cancel()
            return HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_CONTEXT, msg:"请求网络失败.")
        }
        // 请求完成
        Mylog.log(formatResultLogMessage(requestUrl, startDate, responseCacheData))
        return responseCacheData != nil ? responseCacheData! : HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求网络失败.")
    }
    /// 取消当前请求
    open func cancel(){
        requestTaskHandler?.cancel()
        requestDispatchSemaphore?.signal()
    }
    /// 生成Form表单Boundary边界标识
    open func genBoundary() -> String{
        let date = String(Int64(Date().timeIntervalSince1970 * 1000))
        return "---------------------------\(date)---------------------------"
    }
    /// 获取文件名
    open func getFileName(_ filePath:String) -> String{
        let paths = filePath.split(separator: "/").map(String.init)
        return paths[paths.count - 1]
    }
    /// 请求参数格式化为String
    open func formatRequestParams(_ params:NSDictionary?...) -> String{
        var result:String! = nil;
        for param in params {
            if let enumerator = param?.keyEnumerator(){
                while let key = enumerator.nextObject(){
                    if let value = param?.object(forKey: key){
                        result = result == nil ? "\(key)=\(value)" : "\(result)&\(key)=\(value)"
                    }
                }
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
    /// Share下的Cookie
    open func cookieInStorage(_ url: URL?) -> [HTTPCookie]?{
        if let url = url{
            //return HTTPCookieStorage.shared.cookies // 所有
            return HTTPCookieStorage.shared.cookies(for: url) // 指定URL下的
        }else{
            return nil
        }
    }
    /// Share下的Host的Cookie
    @nonobjc
    open func cookieInStorage(_ host: String?) -> [HTTPCookie]?{
        if let host = host{
            return HTTPCookieStorage.shared.cookies?.filter{ // 所有过滤
                $0.domain == host
            }
        }else{
            return nil
        }
    }
    /// Share的所有Session Cookie
    open func sessionCookieStore() -> [HTTPCookie]?{
        return HTTPCookieStorage.shared.cookies?.filter({ (httpCookie) -> Bool in
            httpCookie.isSessionOnly
        })
    }
    /// 创建一个Cookie(名称,值,对应的 url)
    open func createCookie(_ name:String?,_ value:Any,_ url:URL?) -> HTTPCookie?{
        if url == nil || name == nil{
            return nil
        }
        return HTTPCookie(properties: [.name: name!,.value: value,.originURL: url!,.discard: false,.path: "/",.version: 0,.expires:Date().addingTimeInterval(3600*24*30)])
    }
    /// 添加自身份验证到URL[http://xiaotian:4409@www.baidu.com]
    open func addCredentials(_ credentialsName:String?,_ credentialsPassword:String?,_ url:String?) -> String?{
        guard let userName = credentialsName else {
            return url
        }
        guard let password = credentialsPassword else {
            return url
        }
        guard let unPackagedURL = url else {
            return url
        }
        if unPackagedURL.contains("@"){
            return url // 已添加
        }
        if unPackagedURL.contains("//"){
            return unPackagedURL.replacingOccurrences(of: "//", with: "//\(userName):\(password)@")
        }
        return url
    }
    /// encode
    open func encodeURLParams(params: String?) -> String?{
        if let params = params{
            return params.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        return params
    }
    /// 计算百分比
    open class func calculatePercentage(_ current: Int64?,_ total:Int64?) -> CGFloat{
        guard let c = current else{
            return 0.0
        }
        guard let t = total else{
            return 0.0
        }
        return CGFloat(c)/CGFloat(t) * 100
    }
    /// Dictionary Sort By Key
    open func sortByKey(_ data: [String:Any]?) -> [String: Any]?{
        if let data = data{
            var sort:[String: Any] = [:]
            //let result = data.sorted{$0.0 < $1.0}
            for (k,v) in data.sorted(by: { $0.0 < $1.0 }) {
                sort[k] = v
            }
            return sort
        }
        return nil
    }
    /// 请求完成输出格式化
    open func formatResultLogMessage(_ url: URLRequest,_ startDate:CFTimeInterval,_ result:Data?) -> String{
        var message = ""
        if let method = url.httpMethod{
            message.append("(")
            message.append(method)
            message.append(")")
        }
        let time = String(Int(CACurrentMediaTime() - startDate * 1000.0)) // ms
        message.append("[")
        message.append(time)
        message.append("ms]")
        if let url = url.url?.absoluteString{
            message.append(url)
        }
        if let httpBody = url.httpBody{
            if let params = String(data:httpBody, encoding:.utf8){
                message.append("\nRequestParams:")
                message.append(params)
                message.append("\n")
            }
        }
        if let result = String(data: XTFSerializerJson().formatJSONData(result), encoding: String.Encoding.utf8){
            message.append("Response:")
            message.append(result)
        }
        return message
    }
    /// 创建百分号转码的URL
    open func createEncodeUrl(_ url:String?) -> URL?{
        if let url = url{
            // 正则匹配结果Range,如果包含%23,%1F,...百分比转码符号(表面已经转过码了,否则要转码)
            if let _ = url.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil){
                return Foundation.URL(string: url)
            }else{
                if let encodedString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
                    return Foundation.URL(string: encodedString)
                }
            }
        }
        return nil
    }
}
extension HttpRequest: URLSessionDataDelegate{ // Session Delegate
    /// NSURLSessionDelegate
    /// Session URL 身份校验[http://username:password@www.google.com]
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // accept self-signed SSL certificates
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }else{
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        }
    }
    /// Session 请求完成
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        /// POST 文件缓冲上传模式,删除缓冲文件
        if let requestCacheFileURL = self.requestCacheFileURL {
            do{
                try FileManager.default.removeItem(at: requestCacheFileURL)
            }catch{
                Mylog.log("HttpRequest Remove File(\(requestCacheFileURL.absoluteString)) Error:\(error)")
            }
        }
        requestDispatchSemaphore?.signal() // 发信号,解锁
    }
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Mylog.log("Session 完成转入后台.func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)")
    }
    /// NSURLSessionTaskDelegate
    /// Http 重定向是否继续
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        //Mylog.log("执行Http重定向.willPerformHTTPRedirection")
        completionHandler(request)
    }
    /// 发送数据回调
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        //Mylog.log("正在发送Body.didSendBodyData \(bytesSent),\(totalBytesSent),\(totalBytesExpectedToSend)")
        UtilDispatch.asyncTaskMain {
            [weak self] in
            self?.requestCallBackHasSent?(totalBytesSent, totalBytesExpectedToSend, CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend) * 100)
        }
    }
    /*@available(iOS 10.0, *)
     func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
     <#code#>
     }
     func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
     <#code#>
     }
     func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
     <#code#>
     }*/
    /// 请求执行完成
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil{
            responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求发生错误.")
            session.finishTasksAndInvalidate()
            return
        }
        guard let response = task.response else {
            responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"请求发生错误.")
            session.finishTasksAndInvalidate()
            return
        }
        let httpURLResponse = response as? HTTPURLResponse
        if httpURLResponse != nil{
            self.requestExpectedContentLength = httpURLResponse?.expectedContentLength
            //
            //let responseHeaders = httpURLResponse?.allHeaderFields
            //let responseStatus = httpURLResponse?.statusCode
            //let responseStringEncodingName = httpURLResponse?.textEncodingName
            //let responseContentLength = httpURLResponse?.expectedContentLength
            //Mylog.log("HTTPURLResponse:",responseHeaders,responseStatus,responseStringEncodingName,responseContentLength)
            // 保存 URL Cookie
        }else{
            responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"Bad response class:\(String(describing: task.response.self))")
            session.finishTasksAndInvalidate()
            return
        }
        // 网络错误
        if httpURLResponse!.statusCode >= 400{
            responseCacheData = HttpResponse.genDataResponseFailure(HttpResponse.CODE_ERROR_HTTP, msg:"\(httpURLResponse!.statusCode):\(HttpProperty.webErrorDescription(httpURLResponse!.statusCode))")
            session.finishTasksAndInvalidate()
            return
        }
        // 请求成功
        session.finishTasksAndInvalidate()
    }
    /// NSURLSessionDataDelegate
    /// 是否开始接收返回[可以校验返回头合法性]
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpURLResponse = dataTask.response as? HTTPURLResponse {
            self.requestExpectedContentLength = httpURLResponse.expectedContentLength
            //
            //let responseHeaders = httpURLResponse.allHeaderFields
            //let responseStatus = httpURLResponse.statusCode
            //let responseStringEncodingName = httpURLResponse.textEncodingName
            //let responseContentLength = httpURLResponse.expectedContentLength
            //Mylog.log("HTTPURLResponse:",responseHeaders,responseStatus,responseStringEncodingName,responseContentLength)
            // 保存 URL Cookie
        }
        //Mylog.log("是否开始接收返回值回调:dataTask:didReceive:completionHandler")
        completionHandler(URLSession.ResponseDisposition.allow) // 允许接收数据
    }
    /// 接收数据回调
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //Mylog.log("接收到返回值:dataTask:didReceive,\(data.count)")
        if responseCacheData == nil {
            responseCacheData = Data()
        }
        responseCacheData?.append(data)
        UtilDispatch.asyncTaskMain {
            [weak self] in
            if let callback = self?.requestCallBackHasReceive{
                if let totalBytesReceive = self?.responseCacheData?.count{
                    if let requestExpectedContentLength = self?.requestExpectedContentLength{
                        callback(Int64(totalBytesReceive), requestExpectedContentLength, CGFloat(totalBytesReceive) / CGFloat(requestExpectedContentLength) * 100)
                    }
                }
            }
        }
    }
    /// 执行缓冲回调
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        //Mylog.log("缓冲回调:dataTask:willCacheResponse:completionHandler")
        completionHandler(proposedResponse) // 执行结果缓冲
    }
    /*
     func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
     <#code#>
     }
     @available(iOS 9.0, *)
     func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
     <#code#>
     }*/
    // Big File Test
    //http://speedtest.ftp.otenet.gr/files/test100k.db
    //http://speedtest.ftp.otenet.gr/files/test1Mb.db
    //http://speedtest.ftp.otenet.gr/files/test10Mb.db
    //http://speedtest.ftp.otenet.gr/files/test100Mb.db
    //http://speedtest.ftp.otenet.gr/files/test1Gb.db
}
