// http://xahlee.info/js/javascript_basics.html
// 全局引用
var global = this;
// 自执行函数
(function(){
 // function 顶层变量
 var _ocClass = {}
 var _jsClass = {}
 // 加入属性
 console.log("JavaScript 加入JS共享属性:");
 //global[Movie] = Movie;
 
 // 声明方法引用,直接调用方法 imported()
 console.log("JavaScript 添加JS方法");
 // 引入类到当前上下文 imported("xxx,xxx,xxx","xxx","xxx")
 imported = function(){
    // arguments: 在function内部预定义的关键字,请求的参数数组对象
    Object.values(arguments).forEach(function(value){
         value.split(",").forEach(function(className){
            if (!global[className]){
                console.log("添加类到JSContext: " + className)
                global[className] = {__clsName: className} //Object
            }
         })
    });
 }
 /// 获取
 var _methodFunc = function(instance,className,methodName,args,isSuper,isPerformSelector){
    var selectorName = methodName
    // 拼接为Native方法名格式
    if (!isPerformSelector){//是否已转换方法名
        methodName = methodName.replace(/__/g, "-")
        selectorName = methodName.replace(/_/g, ":").replace(/-/g, "_")
        var marchArr = selectorName.match(/:/g)
        var numOfArgs = marchArr ? marchArr.length : 0
        if (args.length > numOfArgs){
            selectorName += ":"
        }
    }
    console.log(className + " -> " + selectorName)
    // instance 为nil则调用类方法
    var ret = instance ? native_call_instance(instance,selectorName,args,isSuper) : native_call_class(className,selectorName,args)
    return _formatNativeToJS(ret)
 
 }
 var _formatNativeToJS = function(obj){
     if (obj == undefined || obj == null) return false
     if (typeof obj == "object"){
         if(obj.__obj) return obj
         if(obj.__isNil) return false
     }
     if (obj instanceof Array){
         var ret = []
         obj.forEach(function(o){ ret.push(_formatNativeToJS(o)) })
         return ret
     }
     if (obj instanceof Function){
         return function(){
             var args = Array.prototype.slice.call(arguments)
             var formatedArgs = native_formatJSToNative(args)
             for(var i=0; i<args.length; i++){
                 if(args[i] === null || args[i] === undefined || args[i] === false){
                     formatedArgs.splice(i, 1, undefined)
                 }else if (arg[i] == nsnull){
                     formatedArgs.splice(i, 1, null)
                 }
             }
             return native_formatNativeToJS(obj.apply(obj, formatedArgs))
         }
     }
     if(obj instanceof Object){
         var ret = {}
         for(var key in obj){
             ret[key] = _formatNativeToJS(obj[key])
         }
         return ret
     }
     return obj
 }
 // 动态添加公共方法到JavaScript Object
 // 添加属性(方法)到Object,所有Object都可以用,对象内部变量
 Object.defineProperty(Object.prototype, '__CLASS__', { get: function() { return Object.prototype.toString.call(this); }, enumerable: false /* = Default */});
 var objectMethod__c = function(methodName){
    console.log("call __c:" + methodName)
    var self = this //当前Object对象
    if (self instanceof Boolean){
        return function(){ return false }
    }

    if (self[methodName]){
        return slf[methodName].bind(slf)
    }
    if (!self.__obj && !self.__clsName){
        throw new Error(slf + "." + methodName + " is undefined")
    }
    if (self.__isSuper && self.__clsName){
        self.__clsName = native_superClsName(slf.__obj.__realClsName ? slf.__obj.__realClsName: slf.__clsName);
    }
    // _ocClass缓冲的类->缓冲的[实例/类]方法->绑定实例到返回function
    var clsName = self.__clsName
    if (clsName && _ocClass[clsName]){
        var methodType = self.__obj ? "instanceMethods" : "classMethod"
        if (_ocClass[clsName][methodType][methodName]){
            self.__isSupper = 0
            return _ocClass[className][methodType][methodName].bind(self)
        }
    }
    return function(){
        var args = Array.prototype.slice.call(arguments) // Array参数拷贝
        return _methodFunc(self.__obj, self.__clsName, methodName, args, self.__isSuper)
    }
 }
 Object.defineProperty(Object.prototype, "__c", {value: objectMethod__c, configurable:false, enumerable:false})
 // 打印Object.prototype对象原形所有属性
 console.log(Object.getOwnPropertyNames(Object.prototype).sort())
 /*for(var method in customMethodAddToObjcect){
     //customMethodToObjcect是否真的包含method这个属性
     if (customMethodAddToObjcect.hasOwnProperty(method)){
        //添加属性(方法)到Object,所有Object都可以用
        Object.defineProperty(Object.prototype, method, {value: customMethodAddToObjcect[method], configurable:false, enumerable:false})
     }
 }*/
 //
 console.log("JavaScript 添加JS变量");
 global.defineClass = function(){
 
 }
 /// 声明变量引用方法
 //global.YES = 1
 //global.NO = 0
 
 imported("UIView,UIColor,NSRect", "UITableView", "XTFMylog", "XTFUtilFile","UILabel"); //add as object {cls:xxx}
 //
 var uiview = UIView
 console.log(uiview.__c("alloc")().__c("initWithFrame")())
 
 console.log("baseCommon 执行完成");
})()

var getName = function(){
    //var uiview = UIView.alloc().init()
    return UIView
}

var getMovie = function(){
    return Movie.movieWithTitlePrice("Zhang","Li")
}

