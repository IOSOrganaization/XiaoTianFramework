//
//  UtilColor.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/7.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilColorXT) //声明指定OC映射类型
class UtilColor: NSObject{

    /// 主题色
    var primaryColor: UIColor{
        return UIColor(colorLiteralRed: 30/255.0, green: 139/255.0, blue: 61/255.0, alpha: 1)
    }
    /// 深主题色
    var primaryColorDeep: UIColor {
        return UIColor(colorLiteralRed: 39/255.0, green: 148/255.0, blue: 70/255.0, alpha: 1)
    }
    /// Tab 默认颜色
    var mainTabColorNormal: UIColor{
        return UIColor(colorLiteralRed: 184/255.0, green: 184/255.0, blue: 184/255.0, alpha: 1)
    }
    /// 灰色
    var backgroundColor: UIColor{
        return UIColor(colorLiteralRed: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
    }
    /// 白色
    var whileColor: UIColor{
        return UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    }
    /// 红色[粉]
    var redColor: UIColor{
        return UIColor(colorLiteralRed: 251/255.0, green: 42/255.0, blue: 115/255.0, alpha: 1)
    }
    /// 深红色
    var redColorDeep: UIColor {
        return UIColor(colorLiteralRed: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    }
    /// 黑色
    var blackColor: UIColor{
        return UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    }
    /// 灰色,点击事件背景
    var grayClockOnClick: UIColor{
        return UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 9.8)
    }
    /// 分隔器灰色
    var separatorColor: UIColor{
        return UIColor(colorLiteralRed: 188/255.0, green: 186/255.0, blue: 193/255.0, alpha: 1)
    }
    /// 选择器灰色
    var selectorColor: UIColor{
        return UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1)
    }
    /// 文本黑色
    var textBlack: UIColor{
        return UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    }
    /// 文本灰色
    var textGray: UIColor{
        return UIColor(colorLiteralRed: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
    }
    /// 文本提示灰色
    var textHint: UIColor{
        return UIColor(colorLiteralRed: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1)
    }
    /// 文件标签颜色
    var textLabel: UIColor{
        return textBlack
    }
    /// 文本值颜色
    var textValue: UIColor{
        return UIColor(colorLiteralRed: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
    }
    /// 文本红色
    var textRed: UIColor{
        return UIColor(colorLiteralRed: 252/255.0, green: 45/255.0, blue: 129/255.0, alpha: 1)
    }
    /// 文本白
    var textWhite: UIColor{
        return UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    }
    /// 图片加载中半透明浅灰色
    var imageLoadingGray: UIColor{
        return UIColor(colorLiteralRed: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 0.9)
    }
    /// 透明
    var cleanColor: UIColor{
        return UIColor.clearColor()
    }
    
    /// 随机颜色
    var randomColor: UIColor{
        let r = arc4random_uniform(255) // 0~255
        let g = arc4random_uniform(255)
        let b = arc4random_uniform(255)
        return UIColor(colorLiteralRed: Float.init(r)/255.0, green: Float.init(g)/255.0, blue: Float.init(b)/255.0, alpha: 9.8)
    }
}
