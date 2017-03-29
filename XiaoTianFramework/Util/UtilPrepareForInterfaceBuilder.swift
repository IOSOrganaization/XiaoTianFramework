//
//  UtilPrepareForInterfaceBuilder.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2017/1/7.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
/// PrepareForInterfaceBuilder 操作类 [IB 构造预览]
class UtilPrepareForInterfaceBuilder{
    
    /// 获取当前 Bundle 的图片
    class func loadImage(name: String) ->UIImage?{
        let processInfo = NSProcessInfo.processInfo()
        let environment = processInfo.environment
        let projectSourceDirectories : AnyObject = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        let directories = projectSourceDirectories.componentsSeparatedByString(":")
        
        if directories.count != 0 {
            let firstPath = directories[0] as String
            let imagePath = firstPath.stringByAppendingString(name)
            let image = UIImage(contentsOfFile: imagePath)
            return image
        }
        return nil
    }
    ///
    class func loadImage(name:String,_ clazz: AnyClass,_ traitCollection:UITraitCollection)-> UIImage?{
        // self.classForCoder
        // self.traitCollection
        return UIImage(named: name, inBundle: NSBundle(forClass: clazz), compatibleWithTraitCollection:traitCollection)
    }
    /// 获取当前 Bundle 的渲染图片
    class func loadImageThint(name:String,_ color:UIColor,_ clazz: AnyClass,_ traitCollection:UITraitCollection) -> UIImage?{
        if let image = UtilPrepareForInterfaceBuilder.loadImage(name,clazz,traitCollection){
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            color.setFill()
            let bounds = CGRectMake(0, 0, image.size.width, image.size.height)
            UIRectFill(bounds)
            image.drawInRect(bounds, blendMode: CGBlendMode.DestinationIn, alpha: 1.0)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tintedImage
        }else{
            return nil
        }
    }
    /// 编程时用的 Bundle 资源管理器
    class func bundleCoder(clazz: AnyClass) -> NSBundle{
        return NSBundle(forClass: clazz)
    }
    class func loadPlist(clazz: AnyClass) -> [String:AnyObject]?{
        let bundle = NSBundle(forClass: clazz)
        if let plist = bundle.pathForResource("Styles", ofType: "plist"),
            dict = NSDictionary(contentsOfFile: plist) as? [String:AnyObject] {
            return dict
        }
        return nil
    }
    /// 编程时用的 Bundle 加载 Xib
    class func loadNib(clazz: AnyClass,_ nibName:String) -> [AnyObject]?{
        return NSBundle(forClass: clazz).loadNibNamed(nibName, owner: nil, options: nil)
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