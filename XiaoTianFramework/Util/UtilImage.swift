//
//  UtilImage.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/7.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

@objc(MyUtilImage)
class UtilImage: NSObject {

    /// 普通渲染
    func renderingImageWithTintColor(_ image: UIImage?,_ tintColor: UIColor) -> UIImage?{
        return renderingImageWithThintColor(image, tintColor, CGBlendMode.destinationIn)
    }
    /// 渐变渲染
    func renderingImageWithGradientThintColor(_ image: UIImage?,_ tintColor: UIColor) -> UIImage?{
        return renderingImageWithThintColor(image, tintColor, CGBlendMode.overlay)
    }
    /// 渲染(图片UIImage,渲染颜色,渲染模式)
    func renderingImageWithThintColor(_ image: UIImage?,_ tintColor: UIColor,_ blendMode: CGBlendMode) -> UIImage?{
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
    func translateRenderingModeImage(_ image:UIImage?,_ renderingMode:UIImageRenderingMode) -> UIImage?{
        if image == nil{
            return nil
        }
        //UIImageRenderingMode.Automatic 设置根据系统上下文自动判断是否被系统渲染,可能原色/可能被渲染[默认]
        //UIImageRenderingMode.AlwaysOriginal 一直保持原来的颜色,不被系统自动渲染[不作为渲染模板]
        //UIImageRenderingMode.AlwaysTemplate 一直保持为渲染模板色被渲染
        return image?.withRenderingMode(renderingMode)
    }
    /// 普通渲染原色模式
    func renderingImageForNavigation(_ image: UIImage,_ color:UIColor) -> UIImage{
        return translateRenderingModeImage(renderingImageWithTintColor(image, color), UIImageRenderingMode.alwaysOriginal)!
    }
    /// 设置UIImageView圆角
    func setImageViewCornerRadius(_ imageView:UIImageView?, radio:Int){
        imageView?.layer.cornerRadius = CGFloat(radio)
        imageView?.layer.masksToBounds = true
    }
    /// 拉伸图片
    func scaleUIImage(_ image:UIImage, size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    // 指定图片位置内容拉伸
    
}
