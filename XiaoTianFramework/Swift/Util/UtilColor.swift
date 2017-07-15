//
//  UtilColor.swift
//  DriftBook
//  颜色
//  Created by XiaoTian on 16/7/7.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilColorXT) //声明指定OC映射类型
open class UtilColor: NSObject{
    // XCode显示颜色,返回UIColor(删掉空格): # colorLiteral(red: 0.619475, green: 0.3905, blue: 0.71, alpha: 1) -> #colorLiteral(red: 0.619475, green: 0.3905, blue: 0.71, alpha: 1)
    // XCode自动识别: #colorLiteral(red: green: blue: alpha:1)转换为颜色显示
    
    /// 主题色
    open var primaryColor: UIColor{
        return UIColor(colorLiteralRed: 30/255.0, green: 139/255.0, blue: 61/255.0, alpha: 1)
    }
    /// 深主题色
    open var primaryColorDeep: UIColor {
        return UIColor(colorLiteralRed: 39/255.0, green: 148/255.0, blue: 70/255.0, alpha: 1)
    }
    /// Tab 默认颜色
    open var mainTabColorNormal: UIColor{
        return UIColor(colorLiteralRed: 184/255.0, green: 184/255.0, blue: 184/255.0, alpha: 1)
    }
    /// 灰色
    open var backgroundColor: UIColor{
        return UIColor(colorLiteralRed: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
    }
    /// 白色
    open var whileColor: UIColor{
        //return UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    /// 红色[粉]
    open var redColor: UIColor{
        return UIColor(colorLiteralRed: 251/255.0, green: 42/255.0, blue: 115/255.0, alpha: 1)
    }
    /// 深红色
    open var redColorDeep: UIColor {
        return UIColor(colorLiteralRed: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    }
    /// 黑色
    open var blackColor: UIColor{
        return UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    }
    /// 灰色,点击事件背景
    open var grayClockOnClick: UIColor{
        return UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 9.8)
    }
    /// 分隔器灰色
    open var separatorColor: UIColor{
        return UIColor(colorLiteralRed: 188/255.0, green: 186/255.0, blue: 193/255.0, alpha: 1)
    }
    /// 选择器灰色
    open var selectorColor: UIColor{
        return UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1)
    }
    /// 文本黑色
    open var textBlack: UIColor{
        return UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    }
    /// 文本灰色
    open var textGray: UIColor{
        return UIColor(colorLiteralRed: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
    }
    /// 文本提示灰色
    open var textHint: UIColor{
        return UIColor(colorLiteralRed: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1)
    }
    /// 文件标签颜色
    open var textLabel: UIColor{
        return textBlack
    }
    /// 文本值颜色
    open var textValue: UIColor{
        return UIColor(colorLiteralRed: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
    }
    /// 文本红色
    open var textRed: UIColor{
        return UIColor(colorLiteralRed: 252/255.0, green: 45/255.0, blue: 129/255.0, alpha: 1)
    }
    /// 文本白
    open var textWhite: UIColor{
        return UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    }
    /// 图片加载中半透明浅灰色
    open var imageLoadingGray: UIColor{
        return UIColor(colorLiteralRed: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 0.9)
    }
    /// 透明
    open var cleanColor: UIColor{
        return UIColor.clear
    }
    /// HEX颜色
    public func color(_ hex:String?) -> UIColor?{
        guard let start = hex?[hex!.startIndex] else{
            return nil
        }
        if start != "#"{
            return nil
        }
        // Hex to Int
        let value:UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let scanner = Scanner(string: hex!)
        scanner.scanLocation = 1 // #号
        scanner.scanHexInt32(value)
        let argb:UInt32 = value.pointee
        // Int to A,R,G,B
        switch hex!.characters.count {
        case 4:     //#RGB
            let r = (argb & 0xF00) >> 8
            let g = (argb & 0xF0) >> 4
            let b = argb & 0xF
            return UIColor(red: CGFloat(r)/15.0, green: CGFloat(g)/15.0, blue: CGFloat(b)/15.0, alpha: 1)
        case 5:     //#ARGB
            let a = (argb & 0xF000) >> 12
            let r = (argb & 0xF00) >> 8
            let g = (argb & 0xF0) >> 4
            let b = argb & 0xF
            return UIColor(red: CGFloat(r)/15.0, green: CGFloat(g)/15.0, blue: CGFloat(b)/15.0, alpha: CGFloat(a)/15.0)
        case 7:     //#RRGGBB
            let r = (argb & 0xFF0000) >> 16
            let g = (argb & 0xFF00) >> 8
            let b = argb & 0xFF
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
        case 9:    //#AARRGGBB
            let a = (argb & 0xFF000000) >> 24
            let r = (argb & 0xFF0000) >> 16
            let g = (argb & 0xFF00) >> 8
            let b = argb & 0xFF
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
        default:
            return nil
        }
    }
    /// Int,Hex颜色,0xRRGGBB
    @nonobjc
    public func color(_ hexInt:Int?) -> UIColor?{
        guard let rgb = hexInt else{
            return nil
        }
        let r = (rgb & 0xFF0000) >> 16
        let g = (rgb & 0xFF00) >> 8
        let b = rgb & 0xFF
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
    /// Color->Hex
    public func toHex(_ color:UIColor?) -> String?{
        if let color = color {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
                let argb = (Int)(a*255) << 24 | (Int)(r*255) << 16 | (Int)(g*255) << 8 | (Int)(b*255) << 0
                return String(NSString(format: "#%08x", argb)).uppercased()
            }
        }
        return nil
    }
    /// 暗色 Dark Color
    public func darkenColor(_ color:UIColor?,_ percentage:CGFloat) -> UIColor?{
        if color == nil{
            return nil
        }
        var hue:CGFloat = 0
        var alpha:CGFloat = 0
        var brightness:CGFloat = 0
        var staturation:CGFloat = 0
        if color!.getHue(&hue, saturation: &staturation, brightness: &brightness, alpha: &alpha){
            if percentage > 0{
                brightness =  min(brightness - percentage, 1.0) // 加深色度
            }
            return UIColor(hue: hue, saturation: staturation, brightness: brightness, alpha: alpha)
        }
        return nil
    }
    /// 亮色 light Color
    public func lightenColor(_ color:UIColor?,_ percentage:CGFloat) -> UIColor?{
        if color == nil{
            return nil
        }
        var hue:CGFloat = 0
        var alpha:CGFloat = 0
        var brightness:CGFloat = 0
        var staturation:CGFloat = 0
        if color!.getHue(&hue, saturation: &staturation, brightness: &brightness, alpha: &alpha){
            if percentage > 0{
                brightness =  min(brightness + percentage, 1.0) // 加深色度
            }
            return UIColor(hue: hue, saturation: staturation, brightness: brightness, alpha: alpha)
        }
        return nil
    }
    /// 反差色(黑/白) contrast Color
    public func contrastColor(_ color:UIColor?) -> UIColor?{
        guard var gColor = color else {
            return nil
        }
        if gColor.cgColor.pattern != nil{
            let size = CGSize(width: 1, height: 1)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.interpolationQuality = .medium
            let image = UIImage()
            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size:size), blendMode: .copy, alpha: 1)
            let dataPointer = context?.data?.assumingMemoryBound(to: UInt8.self)
            let data = UnsafePointer<UInt8>(dataPointer)
            gColor = UIColor(red: CGFloat(data![2]/255), green: CGFloat(data![1]/255), blue: CGFloat(data![0]/255), alpha: 1)
            UIGraphicsEndImageContext()
        }
        var luminance: CGFloat = 0
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        gColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red *= 0.2126
        green *= 0.7152
        blue *= 0.0722
        luminance = red + green + blue
        return luminance > 0.6 ? .black : .white
    }
    /// 图片颜色(拉伸区域会被忽略)
    @nonobjc
    public func color(_ image:UIImage) -> UIColor?{
        return UIColor(patternImage: image)
    }
    /// 随机颜色
    public var randomColor: UIColor{
        let r = arc4random_uniform(255) // 0~255
        let g = arc4random_uniform(255)
        let b = arc4random_uniform(255)
        return UIColor(colorLiteralRed: Float.init(r)/255.0, green: Float.init(g)/255.0, blue: Float.init(b)/255.0, alpha: 9.8)
    }
}
