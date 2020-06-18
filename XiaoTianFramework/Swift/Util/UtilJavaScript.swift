//
//  UtilJavaScript.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/8/12.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
// JavaScript核心框架(c语言API)
import JavaScriptCore
// JSVirtualMachine: JavaScript执行虚拟机,每个虚拟机只能执行单线程JS代码,虚拟机之间可以穿参
// JSContext: JavaScript执行上下文,不同上下文可以随便传递对象(JSVM不能直接传对象),一个上下文管理所有内部的对象生命周期
// JSValue: JavaScript数据封装类型,JSContext里面的所有数据都会封装为JSValue
// JSExport: JSValue自定义对象接口协议(向JavaScript开放访问接口)
// JavaScript 的Object对象对应于Native的Dictionary,两者模式一样{} -> Object -> @{}
public class UtilJavaScript:NSObject {
    public var mJSContext:JSContext?
    
    public override init(){
        if #available(iOS 7.0, *){}else{ return }
        if mJSContext != nil{
            return
        }
        mJSContext = JSContext()
        // 绑定异常回调(打印JavaScript异常)
        mJSContext?.exceptionHandler = { (context,exception) in
            if let exception = exception{
                Mylog.log(String(format: "JSContext执行异常: %@", exception))
            }
        }
        // 绑定Console输出(console.log(xxx))
        _ = mJSContext?.evaluateScript("var console = { log: function(message) { native_consoleLog(message) } }");
        let logFunc:@convention(block)(Any?)->() = { Mylog.log($0) } //Object-C Block
        mJSContext?.setFunctionForKey(key: "native_consoleLog", fn: logFunc)
        //
        Mylog.log("初始化完成")
    }
    static let parseJson:@convention(block)([[String:String]])->[String] = { object in //JSValue
        return object.map({ dict -> String in
            guard let title = dict["title"],let price = dict["price"] else{
                fatalError()
            }
            return "\(title),\(price)_Map"
        })
    }
    public func test(){
        //1. 执行公共JavaScript代码,添加公共属性/方法到JavaScript上下文Context中
        assert(mJSContext != nil, "JSContext un initial.")
        let _ = self.jsContextEvaluateScript(javaScriptFile: Bundle.main.path(forResource: "baseCommon", ofType: "js"))
        Mylog.log("#######")
        let _ = self.jsContextEvaluateScript(javaScriptFile: Bundle.main.path(forResource: "additions", ofType: "js"))
        Mylog.log("additions")
        //let _ = self.jsContextEvaluateScriptCatch(javaScriptFile: Bundle.main.path(forResource: "demomy", ofType: "js"))
        let native: @convention(block)()->String = {
            return "Native Name"
        }
        mJSContext?.setFunctionForKey(key: "nativeGetName", fn: native)
        let name = jsContextCall(methodKey: "getName")
        Mylog.log(name)
        mJSContext?.setObject(Movie.self, forKeyedSubscript: "Movie" as NSCopying & NSObjectProtocol)
        Mylog.log(jsContextCall(methodKey: "getMovie"))
        //2. 直接添加本地公共属性/方法到JavaScript上下文Context中
        // 添加绑定方法到JS上下文,在JS掉用
        Mylog.log(mJSContext)
        mJSContext?.setObject(unsafeBitCast(UtilJavaScript.parseJson, to: AnyObject.self), forKeyedSubscript: "parseJson" as NSCopying & NSObjectProtocol )
        // 执行JavaScript里面的方法
        let parseFunction = mJSContext?.objectForKeyedSubscript("parseJson")// 获取JS上下文的对象(OC可以直接通过subscript获取),JSValue
        if let parsed = parseFunction?.call(withArguments: [["title":"Live","price":"35.6"],["title":"Tian","price":"6.6"]]).toArray() {
            Mylog.log("parseFunction:\(parsed)")
            let filterFunction = mJSContext?.objectForKeyedSubscript("filterByLimit")// JSValue
            if let filtered = filterFunction?.call(withArguments: [parsed]).toArray(){
                Mylog.log("filterFunction:\(filtered)")
                // 执行Native Code方法(本地 Objective-C blocks(Swift block不支持)->JS Method Block),block声明为Object-C block:@convention(block)
                let moveBuilder:@convention(block)([[String:String]])->[String] = { object in //JSValue
                    return object.map({ dict -> String in
                        guard let title = dict["title"],let price = dict["dice"] else{
                            fatalError()
                        }
                        return "\(title),\(price)_Map"
                    })
                }
                // unsafeBitCast: function to cast the block to AnyObject
                let builderBlock = unsafeBitCast(moveBuilder, to: AnyObject.self)// function 转换为对象
                mJSContext?.setObject(builderBlock, forKeyedSubscript: "movieBuild" as NSCopying & NSObjectProtocol )//加入对象到JavaScript上下文中
                let builder = mJSContext?.evaluateScript("movieBuild")//执行JS,获取JavaScript中block的引用
                guard let movies = builder?.call(withArguments: [filtered]).toArray() as? [String] else{
                    fatalError()
                }
            }
        }
    }
    
    ///  invoke JavaScript methods from your iOS code
    public func jsContextCall(methodKey:String, methodArguments:[Any]! = nil)-> JSValue?{
        if let jsFunction = mJSContext?.objectForKeyedSubscript(methodKey){// var jsFunction = function(arguments){}
            return jsContextCall(jsValue: jsFunction, methodArguments: methodArguments)
        }else{
            Mylog.log(String(format: "JavaScript Function Key Not Found In JSContext: %@", methodKey))
        }
        return nil
    }
    public func jsContextCall(jsValue:JSValue?,methodArguments:[Any]! = nil)-> JSValue?{
        return jsValue?.call(withArguments: methodArguments)
    }
    /// access your native code from JavaScript
    func testJavaScriptString()-> String{
        return "var jsMethodKey = function(){ nativeMethodKey() }"
    }
    /// 执行JavaScript扑捉异常,返回生成的最后一个对象(如果有)
    public func jsContextEvaluateScriptCatch(javaScriptFile:String?)-> JSValue?{
        do{
            var javaScript = try String(contentsOfFile: javaScriptFile!, encoding: .utf8)
            // 加JavaScript异常
            do{// 正则匹配替换格式化
                //Mylog.log(javaScript)
                let reges = try NSRegularExpression(pattern: "(?<!\\\\)\\.\\s*(\\w+)\\s*\\(", options: .caseInsensitive)//(?<!\).s*(\w+)\s*\(
                let nativeJavaScript = reges.stringByReplacingMatches(in: javaScript, options: .reportProgress, range: NSMakeRange(0, javaScript.characters.count), withTemplate: ".__c(\"$1\")(")
                let tryCatchJavaScript = String(format: "(function(){ try{ \n %@ \n }catch(e){ console.log([e.message, e.stack]) } })()", nativeJavaScript)
                Mylog.log(tryCatchJavaScript)
                if #available(iOS 8.0, *){
                    return mJSContext?.evaluateScript(tryCatchJavaScript, withSourceURL: URL(fileURLWithPath: javaScript))
                }else{
                    return mJSContext?.evaluateScript(tryCatchJavaScript)
                }
            }catch let e{
                Mylog.logError(e)
            }
        }catch let e{
            Mylog.logError(e)
        }
        return nil
    }
    /// 执行JavaScript,返回生成的最后一个对象(如果有)
    public func jsContextEvaluateScript(javaScript:String?,javaScriptFile:String?)-> JSValue?{
        if let javaScript = javaScript{
            if #available(iOS 8.0, *){
                if let javaScriptFile = javaScriptFile{
                    return mJSContext?.evaluateScript(javaScript, withSourceURL: URL(fileURLWithPath: javaScriptFile))
                }else{
                    return mJSContext?.evaluateScript(javaScript)
                }
            }else{
                return mJSContext?.evaluateScript(javaScript)
            }
        }
        return nil
    }
    /// 执行JavaScript文件,返回生成的最后一个对象(如果有)
    public func jsContextEvaluateScript(javaScriptFile:String?)-> JSValue?{
        do{
            if let javaScriptFile = javaScriptFile{
                return jsContextEvaluateScript(javaScript: try String(contentsOfFile: javaScriptFile, encoding: .utf8), javaScriptFile:javaScriptFile)
            }
        }catch let e{
            Mylog.logError(e)
        }
        return nil
    }
    // @convention(block): Object-C Function Block Type
    // @convention(c): C Function Type
    /// Swift Function To AnyObject
    public func translateFunctionToAnyObject<T>(_ function:T)-> AnyObject{
        return unsafeBitCast(function, to: AnyObject.self)
    }
}
// 实体
class Movie: NSObject, MovieJSExports{
    dynamic var title: String
    dynamic var price: String
    
    init(title:String, price:String) {
        self.title = title
        self.price = price
    }
    
    static func movieWith(title: String, price: String)-> Movie {
        return Movie(title: title, price: price)
    }
    
    override var description: String{
        return "Title:\(title), Price:\(price)"
    }
}
// 向JavaScript开放访问的属性,方法
@objc protocol MovieJSExports: JSExport {
    var title:String{get set}
    var price:String{get set}
    static func movieWith(title:String,price:String)-> Movie
}
/// Extention
fileprivate extension JSContext{
    /// 设置Function到JavaScript上下文中(Function必须为Object-C Function)
    func setFunctionForKey<T>(key: String, fn: T) {
        // Some grossness is needed to persuade Swift to treat closures as objects.
        setObject(unsafeBitCast(fn, to: AnyObject.self), forKeyedSubscript: key as NSCopying & NSObjectProtocol)
    }
    fileprivate subscript(key:Any!)-> JSValue?{
        get{
            return objectForKeyedSubscript(key)
        }
        set{
            setObject(newValue, forKeyedSubscript: key as! NSCopying & NSObjectProtocol)
        }
    }
}
fileprivate extension JSValue {
    /// 设置Function到JSValue值中(Function必须为Object-C Function)
    func setFunctionForKey<T>(key: String, fn: T) {
        // Some grossness is needed to persuade Swift to treat closures as objects.
        setObject(unsafeBitCast(fn, to: AnyObject.self), forKeyedSubscript: key as NSCopying & NSObjectProtocol)
    }
    fileprivate subscript(key:Any!)-> JSValue?{
        get{
            return objectForKeyedSubscript(key)
        }
        set{
            setObject(newValue, forKeyedSubscript: key as! NSCopying & NSObjectProtocol)
        }
    }
}
