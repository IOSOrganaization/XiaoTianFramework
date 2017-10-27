//
//  UtilBundle.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

public class UtilBundle{
    /// Main Bundle
    public var main: Bundle{
        return Bundle.main
    }
    /// 根据localName地区名称获取该地区的Key对应的字符串
    public func localizedString(key:String,value:String? = nil,localName:String? = nil) -> String?{
        //读取localName.lproj语言文件
        guard let mainLocalFilePath = Bundle.main.path(forResource: localName, ofType: "lproj") else{
            return Bundle.main.localizedString(forKey: key, value: value, table: nil) // 创建该地区的语言文件路径失败
        }
        if let localValue = Bundle(path: mainLocalFilePath)?.localizedString(forKey: key, value: value, table: nil){
            return localValue
        }
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
    // 不使用asset catalog命名规则
    // 1.@2x,@3x 声明屏幕指定资源
    // 2.~iphone,~ipad 声明设备指定资源
    //
    // 使用asset catalog 会自动帮你重命名为@2x,@3x
    /// XiaoTianFramework 里面的Bundle
    public var xiaotian: Bundle?{
        let bundleDomain = Bundle(for: UtilBundle.self)
        guard let bundleURL = bundleDomain.url(forResource: "BundleXiaoTian", withExtension: "bundle") else {
            return nil
        }
        return Bundle(url: bundleURL)
    }
    /// 当前项目的Bundle图片
    public func imageInBundle(_ name:String) -> UIImage?{
        return UIImage(named: name, in: main, compatibleWith: nil)
    }
    /// XiaoTianFramework的Bundle图片
    public func imageInBundleXiaoTian(_ name:String) -> UIImage?{
        return UIImage(named: name, in: xiaotian, compatibleWith: nil)
    }
    /// 项目的文件
    public func fileInBundle(_ name:String,_ type:String)-> String?{
        //Bundle.main.bundlePath.appendingFormat("/%1@", "001.gif")
        return main.path(forResource: name, ofType: type)
    }
    /// 加载Nib
    public func loadNibNamed(_ name:String,_ owner: Any?,_ option: [AnyHashable : Any]?) -> [Any]?{
        // UINib(nibName: name, bundle: Bundle.main)
        return Bundle.main.loadNibNamed(name, owner: owner, options: option)
    }
    /// 加载适配Nib,xxx.@4.0
    public func loadNibNamedMatch(_ name:String,_ owner: Any?,_ option: [AnyHashable : Any]?) -> [Any]?{
        var postfix = ""
        switch UtilEnvironment.deviceHeight{
        case 480: //3.5英寸
            postfix = "@3.5"
        case 568: //4.0英寸
            postfix = "@4.0"
        case 667: //4.7英寸
            postfix = "@4.7"
        case 736: //5.5英寸
            postfix = "@5.5"
        default:
            break
        }
        return Bundle.main.loadNibNamed("\(name)\(postfix)", owner: owner, options: option)
    }
    /// 本地Bundle资源URL
    public func getResultUrl(_ name:String?,_ ext:String?)-> URL?{
        return main.url(forResource: name, withExtension: ext)
    }
}
