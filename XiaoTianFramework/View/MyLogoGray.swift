//
//  MyLogoGray.swift
//  DriftBook
//  灰色的 Logo 图片
//  Created by 郭天蕊 on 2017/1/4.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MyLogoGray: UIImageView{

    override func awakeFromNib() {
        // 灰色的Logo 图片
        if let image = renderingImageWithThintColor(){
            contentMode = .ScaleAspectFill
            self.image = image
        }
    }
    
    // 灰色渲染
    func renderingImageWithThintColor() -> UIImage?{
        if let image = UIImage(named: "logoDefault"){
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1).setFill()
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
    // 声明 IBDesignable 创建页面预览调用
    // IB 用于显示预览调用的方法
    // 1.drawRect方法会被 IB 调用,用于绘制预览效果图[老方式]
    // 2.声明为@IBDesignable的视图,系统会自动调用里面的prepareForInterfaceBuilder方法进行绘图
    override func prepareForInterfaceBuilder() {
        self.image = UtilPrepareForInterfaceBuilder.loadImageThint("logoDefault", UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1), self.classForCoder, self.traitCollection)
    }
}