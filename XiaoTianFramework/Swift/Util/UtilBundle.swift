//
//  UtilBundle.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilBundle{
    /// Main Bundle
    open static var main: Bundle{
        return Bundle.main
    }
    /// 根据localName地区名称获取该地区的Key对应的字符串
    open static func localizedString(key:String,value:String? = nil,localName:String? = nil) -> String?{
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
    open static var xiaotian: Bundle?{
        let bundleDomain = Bundle(for: UtilBundle.self)
        guard let bundleURL = bundleDomain.url(forResource: "BundleXiaoTian", withExtension: "bundle") else {
            return nil
        }
        return Bundle(url: bundleURL)
    }
    /// 当前项目的Bundle图片
    open static func imageInBundle(_ name:String) -> UIImage?{
        return UIImage(named: name, in: main, compatibleWith: nil)
    }
    /// XiaoTianFramework的Bundle图片
    open static func imageInBundleXiaoTian(_ name:String) -> UIImage?{
        return UIImage(named: name, in: xiaotian, compatibleWith: nil)
    }
    /// 项目的文件
    open static func fileInBundle(_ name:String,_ type:String)-> String?{
        //Bundle.main.bundlePath.appendingFormat("/%1@", "001.gif")
        return main.path(forResource: name, ofType: type)
    }
    /// 加载Nib
    open static func loadNibNamed(_ name:String,_ owner: Any?,_ option: [AnyHashable : Any]?) -> [Any]?{
        // UINib(nibName: name, bundle: Bundle.main)
        return Bundle.main.loadNibNamed(name, owner: owner, options: option)
    }
}
