//
//  UtilImage.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/7.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//
import Foundation
import UIKit

@objc(MyUtilImage)
open class UtilImage: NSObject {
    // XCode显示图片,返回UIImage(删掉空格): # imageLiteral(resourceName: "imageName")
    /// 普通渲染
    public func renderingImageWithTintColor(_ image: UIImage?,_ tintColor: UIColor) -> UIImage?{
        return renderingImageWithThintColor(image, tintColor, CGBlendMode.destinationIn)
    }
    /// 渐变渲染
    public func renderingImageWithGradientThintColor(_ image: UIImage?,_ tintColor: UIColor) -> UIImage?{
        return renderingImageWithThintColor(image, tintColor, CGBlendMode.overlay)
    }
    /// 渲染(图片UIImage,渲染颜色,渲染模式)
    public func renderingImageWithThintColor(_ image: UIImage?,_ tintColor: UIColor,_ blendMode: CGBlendMode) -> UIImage?{
        if image == nil{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)//初始化绘图上下文[绘图大小,不透明性,缩放比]
        tintColor.setFill()//设置填充颜色到绘图上下文
        let bounds = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)//绘图边界
        UIRectFill(bounds)//填充颜色
        image!.draw(in: bounds, blendMode: blendMode, alpha: 1.0)//绘制图片
        if blendMode != CGBlendMode.destinationIn {//渐变绘制
            image!.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()//取回上下文图片
        UIGraphicsEndImageContext()//结束绘图上下文
        return tintedImage
    }
    /// 渲染后的图片还有可能被系统上下文渲染器自动渲染,所以要根据不同情况进行是否取消系统自动渲染
    public func translateRenderingModeImage(_ image:UIImage?,_ renderingMode:UIImageRenderingMode) -> UIImage?{
        if image == nil{
            return nil
        }
        //UIImageRenderingMode.Automatic 设置根据系统上下文自动判断是否被系统渲染,可能原色/可能被渲染[默认]
        //UIImageRenderingMode.AlwaysOriginal 一直保持原来的颜色,不被系统自动渲染[不作为渲染模板]
        //UIImageRenderingMode.AlwaysTemplate 一直保持为渲染模板色被渲染
        return image?.withRenderingMode(renderingMode)
    }
    /// 普通渲染原色模式
    public func renderingImageForNavigation(_ image: UIImage,_ color:UIColor) -> UIImage{
        return translateRenderingModeImage(renderingImageWithTintColor(image, color), UIImageRenderingMode.alwaysOriginal)!
    }
    /// 颜色渲染
    public func maskImageWithColor(_ image:UIImage?,_ color:UIColor) -> UIImage?{
        guard let uiImage = image else{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(uiImage.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context!.translateBy(x: 0, y: uiImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0, y: 0, width: uiImage.size.width, height: uiImage.size.height)
        context!.draw(uiImage.cgImage!, in: rect)
        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.addRect(rect)
        context!.drawPath(using: CGPathDrawingMode.fill)
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return coloredImage
    }
    /// 对图片设置渲染模式
    public func renderingImage(_ image: UIImage?,_ renderingMode: UIImageRenderingMode) -> UIImage?{
        // .automatic :有系统自动根据上下文颜色渲染
        // .alwaysOriginal :永远保持原图,不执行颜色渲染
        // .alwaysTemplate :永远作为模板,忽略颜色
        return image?.withRenderingMode(renderingMode)
    }
    /// 设置UIImageView圆角(xib:layer.cornerRadius,layer.masksToBounds)
    public func setImageViewCornerRadius(_ imageView:UIImageView?, radio:Int){
        imageView?.layer.cornerRadius = CGFloat(radio)
        imageView?.layer.masksToBounds = true
    }
    /// 拉伸图片
    public func scaleUIImage(_ image:UIImage?, size:CGSize) -> UIImage?{
        guard let uiImage = image else {
            return nil
        }
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
            context.concatenate(flipVertical)
            context.draw(uiImage.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    /// 在图片插入边缘
    public func imageWithInsets(_ image:UIImage?,_ insets:UIEdgeInsets) -> UIImage?{
        if let image = image{
            //let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let size = CGSize(width: image.size.width + insets.left + insets.right, height: image.size.height + insets.top + insets.bottom)
            UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
            let origin = CGPoint(x: insets.left, y: insets.top) //起点
            image.draw(at: origin) //在起点画图片
            let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return imageWithInsets
        }
        return image
    }
    /// 生成指定颜色,大小的UIImage
    public func genImageFromColor(_ color:UIColor?,_ size:CGSize) -> UIImage?{
        if let color = color{
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(color.cgColor)
            context?.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    /// View生成UIImage
    public func genImageFromView(_ view:UIView?) -> UIImage?{
        if let view = view{
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    /// UILabel生成UIImage
    public func genImageFromUILabel(_ uiLabel:UILabel?) -> UIImage?{
        guard let label = uiLabel else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    // 指定图片位置内容拉伸
    
    /// UImage -> Data
    public func imageJPEGRepresentation(_ image: UIImage?) -> Data?{
        if let image = image {
            UIImageJPEGRepresentation(image, 90)
        }
        return nil
    }
    /// UIImage -> Data
    public func imagePNGRepresentation(_ image: UIImage?) -> Data?{
        if let image = image {
            UIImagePNGRepresentation(image)
        }
        return nil
    }
}
