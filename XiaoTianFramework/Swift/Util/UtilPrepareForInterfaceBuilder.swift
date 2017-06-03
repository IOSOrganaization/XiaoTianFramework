//
//  UtilPrepareForInterfaceBuilder.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2017/1/7.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
/// PrepareForInterfaceBuilder 操作类 [IB 构造预览]
open class UtilPrepareForInterfaceBuilder{
    
    /// 获取当前 Bundle 的图片
    class func loadImage(_ name: String) ->UIImage?{
        let processInfo = ProcessInfo.processInfo
        let environment = processInfo.environment
        let projectSourceDirectories : AnyObject = environment["IB_PROJECT_SOURCE_DIRECTORIES"]! as AnyObject
        let directories = projectSourceDirectories.components(separatedBy: ":")
        
        if directories.count != 0 {
            let firstPath = directories[0] as String
            let imagePath = firstPath + name
            let image = UIImage(contentsOfFile: imagePath)
            return image
        }
        return nil
    }
    ///
    class func loadImage(_ name:String,_ clazz: AnyClass,_ traitCollection:UITraitCollection)-> UIImage?{
        // self.classForCoder
        // self.traitCollection
        return UIImage(named: name, in: Bundle(for: clazz), compatibleWith:traitCollection)
    }
    /// 获取当前 Bundle 的渲染图片
    class func loadImageThint(_ name:String,_ color:UIColor,_ clazz: AnyClass,_ traitCollection:UITraitCollection) -> UIImage?{
        if let image = UtilPrepareForInterfaceBuilder.loadImage(name,clazz,traitCollection){
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            color.setFill()
            let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            UIRectFill(bounds)
            image.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tintedImage
        }else{
            return nil
        }
    }
    /// 编程时用的 Bundle 资源管理器
    class func bundleCoder(_ clazz: AnyClass) -> Bundle{
        return Bundle(for: clazz)
    }
    class func loadPlist(_ clazz: AnyClass) -> [String:AnyObject]?{
        let bundle = Bundle(for: clazz)
        if let plist = bundle.path(forResource: "Styles", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: plist) as? [String:AnyObject] {
            return dict
        }
        return nil
    }
    /// 编程时用的 Bundle 加载 Xib
    class func loadNib(_ clazz: AnyClass,_ nibName:String) -> [AnyObject]?{
        return Bundle(for: clazz).loadNibNamed(nibName, owner: nil, options: nil) as! [AnyObject]
    }
    
    /// 是否是 InterfaceBuilder
    class func isInterfaceBuilder() -> Bool{
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }
}
