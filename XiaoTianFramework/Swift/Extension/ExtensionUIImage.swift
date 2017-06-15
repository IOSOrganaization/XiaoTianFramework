//
//  ExtensionUIImage.swift
//  XiaoTianFramework
//  扩展UIImage,添加UIImage实例常用方法,非存储属性(Method, non store property)
//  Created by guotianrui on 2017/6/7.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

// 避免命名冲突所有扩展的方法都以xt开头
extension UIImage{
    
    /// non store property
    public var xtHalfSizeImage: UIImage?{
        let halfWidth = self.size.width / 2
        let halfHeight = self.size.height / 2
        //  创建一半大小的画布
        UIGraphicsBeginImageContext(CGSize(width: halfWidth, height: halfHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public var xtCircleImage: UIImage?{
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        // 添加椭圆剪裁区域
        context?.addEllipse(in: rect)
        context?.clip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// method
    public func xtScaleUIImage(_ size:CGSize) -> UIImage?{
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    public func xtAlphaImage(_ alpha: CGFloat) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.size.height)
        context?.setBlendMode(.multiply)
        context?.setAlpha(alpha)
        context?.draw(self.cgImage!, in: area)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
