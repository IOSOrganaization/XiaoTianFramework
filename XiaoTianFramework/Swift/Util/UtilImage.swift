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
    /// 图片颜色渲染
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
    /// 传入View生成UIImage
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
    /// 剪裁指定图片位置内容
    public func clippedImageInRect(_ inImage: UIImage?, _ rect:CGRect)->UIImage?{
        guard let image = inImage else {
            return nil
        }
        let imageRect = CGRect(origin: CGPoint.zero, size: image.size)
        if rect.contains(imageRect){
            // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
            return inImage
        }
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        // Create bitmap image from context using the rect
        let imageRef = contextImage.cgImage?.cropping(to: rect)
        // Create a new image based on the imageRef and rotate back to the original orientation
        return UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
    }
    /// 自动处理图片旋转
    public func fixOrientation(_ inImage:UIImage?)->UIImage?{
        guard let image = inImage else {
            return nil
        }
        guard let cgImage = inImage?.cgImage else {
            return nil
        }
        if image.imageOrientation == UIImageOrientation.up {
            return image
        }
        let width  = image.size.width
        let height = image.size.height
        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)
            
        case .up, .upMirrored:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break;
        }
        // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        guard let context = CGContext(data: nil,width: Int(width),height: Int(height),bitsPerComponent: cgImage.bitsPerComponent,bytesPerRow: 0,space: colorSpace,bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)) else {
                return nil
        }
        context.concatenate(transform);
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
            
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: newCGImg)
    }
    /// UImage -> JPEG Data
    public func imageJPEGRepresentation(_ image: UIImage?, scaled:CGFloat = 1.0) -> Data?{
        if let image = image {
            UIImageJPEGRepresentation(image, scaled)
        }
        return nil
    }
    /// UIImage -> PNG Data
    public func imagePNGRepresentation(_ image: UIImage?) -> Data?{
        if let image = image {
            UIImagePNGRepresentation(image)
        }
        return nil
    }
    /// Data -> UIImage
    public func imageFromData(_ data:Data?)-> UIImage?{
        if let data = data{
            return UIImage(data: data)
        }
        return nil
    }
    /// 图片的平均颜色
    public func averageColor(_ image:UIImage?)->UIColor?{
        if let image = image{
            var bitmap = [UInt8](repeating: 0, count: 4)
            if #available(iOS 9.0, *) {
                // Get average color.
                let context = CIContext()
                let inputImage: CIImage = image.ciImage ?? CoreImage.CIImage(cgImage: image.cgImage!)
                let extent = inputImage.extent
                let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
                let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
                let outputImage = filter.outputImage!
                let outputExtent = outputImage.extent
                assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
                // Render to bitmap.
                context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            } else {
                // Create 1x1 context that interpolates pixels when drawing to it.
                let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
                let inputImage = image.cgImage ?? CIContext().createCGImage(image.ciImage!, from: image.ciImage!.extent)
                // Render to bitmap.
                context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            // Compute result.
            let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
            return result
        }
        return nil
    }
    /// 常用图形
    public func imageWithShape(_ shape:Int,_ size:CGSize,_ tintColor:UIColor?) -> UIImage?{
        var lineWidth:CGFloat = 0
        switch (shape) {
        case 0://返回按钮的箭头: <
            lineWidth = 2.0
        case 1://列表 cell 右边的箭头: >
            lineWidth = 1.5
        case 2://列表 cell 右边的checkmark: √
            lineWidth = 1.5
        case 3://列表 cell 右边的 i 按钮图片:
            lineWidth = 1.0
        case 4://导航栏的关闭icon: x
            lineWidth = 1.2
        case 5,6: //5: 椭圆/圆,6: 三角形
            break
        default://其他默认
            break;
        }
        let scale = UIScreen.main.scale
        let sizeCeil = CGSize(width: ceil(size.width*scale)/scale, height: ceil(size.height*scale)/scale)
        let color = tintColor ?? UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        UIGraphicsBeginImageContextWithOptions(sizeCeil, false, 0)
        let context = UIGraphicsGetCurrentContext()
        var path: UIBezierPath!
        var drawByStroke = false
        let drawOffset = lineWidth / 2
        switch shape {
        case 0:
            drawByStroke = true
            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: sizeCeil.width - drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: 0 + drawOffset, y: sizeCeil.height / 2))
            path.addLine(to: CGPoint(x: sizeCeil.width - drawOffset, y: sizeCeil.height - drawOffset))
        case 1:
            drawByStroke = true
            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: sizeCeil.width - drawOffset, y: sizeCeil.height / 2))
            path.addLine(to: CGPoint(x: drawOffset, y: sizeCeil.height - drawOffset))
        case 2:
            let lineAngle = Double.pi/4
            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: 0, y: sizeCeil.height/2))
            path.addLine(to: CGPoint(x: sizeCeil.width/3, y: sizeCeil.height))
            path.addLine(to: CGPoint(x: sizeCeil.width, y: lineWidth*CGFloat(sin(lineAngle))))
            path.addLine(to: CGPoint(x: sizeCeil.width - lineWidth*CGFloat(cos(lineAngle)), y: 0))
            path.addLine(to: CGPoint(x: sizeCeil.width/3, y: sizeCeil.height-lineWidth/CGFloat(sin(lineAngle))))
            path.addLine(to: CGPoint(x: lineWidth*CGFloat(sin(lineAngle)), y: sizeCeil.height/2-lineWidth*CGFloat(sin(lineAngle))))
        case 3:
            drawByStroke = true
            path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: sizeCeil).insetBy(dx: drawOffset, dy: drawOffset))
            path.lineWidth = lineWidth
        case 4:
            drawByStroke = true
            path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: sizeCeil.width, y: sizeCeil.height))
            path.close()
            path.move(to: CGPoint(x: sizeCeil.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: sizeCeil.height))
            path.close()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
        case 5:
            path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: sizeCeil))
        case 6:
            path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: sizeCeil.height))
            path.addLine(to: CGPoint(x: sizeCeil.width/2, y: 0))
            path.addLine(to: CGPoint(x: sizeCeil.width, y: sizeCeil.height))
            path.close()
        default:
            break
        }
        if drawByStroke{
            context?.setStrokeColor(color.cgColor)
            path.stroke()
        }else{
            context?.setFillColor(color.cgColor)
            path.fill()
        }
        if shape == 3{ // i 字符
            let fontPointSize = CGFloat(ceil(size.height*0.8*scale) / scale)
            let font = UIFont(name: "Georgia", size: fontPointSize)
            let string = NSAttributedString(string: "i", attributes: [NSAttributedStringKey.font: font!,NSAttributedStringKey.foregroundColor: color])
            let stringSize = string.boundingRect(with: sizeCeil, options: .usesFontLeading, context: nil).size
            let startX = CGFloat(ceil((sizeCeil.width-stringSize.width)/2*scale)/scale)//左右间隔
            let startY = CGFloat(ceil((sizeCeil.height-stringSize.height)/2*scale)/scale)//上下间隔
            string.draw(at: CGPoint(x: startX, y: startY))
        }
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}
