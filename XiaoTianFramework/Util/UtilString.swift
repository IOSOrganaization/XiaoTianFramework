//
//  UtilString.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/6.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilStringXT)
class UtilString :NSObject {
    let FILE_NAME_KEY = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
    
    /// 根据字体大小和指定宽度计算占用高度
    func stringHeightWithFontSize(string: String,fontName: String,fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont(name: fontName, size: fontSize)
        let size = CGSizeMake(width, CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let attributes = [NSFontAttributeName:font!, NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = string as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    /// 格式化就;距离
    func formatDistance(distance: NSNumber?) -> String? {
        if (distance == nil) {
            return nil
        }
        let numberFormatter = NSNumberFormatter()
        // 填充
        //numberFormatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        //numberFormatter.paddingCharacter = "0"
        //numberFormatter.minimumIntegerDigits = 10
        //
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.paddingPosition = NSNumberFormatterPadPosition.AfterSuffix // 后缀
        numberFormatter.maximumFractionDigits = 1 // 小数点后最大位数
        //numberFormatter.maximumIntegerDigits = 2 // 整数位最大位数
        numberFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundFloor // 取数模式,
        // Double 值
        var valueDouble = distance?.doubleValue
        if valueDouble != nil{
            valueDouble = valueDouble! / 1000.0
        }
        if valueDouble != nil {
            return "\(numberFormatter.stringFromNumber(valueDouble!)!)km"
        }
        // Int 值
        let valueInt = distance?.integerValue
        if valueInt != nil{
            valueDouble = Double(valueInt!) / 1000.0
        }
        if valueDouble != nil {
            return "\(numberFormatter.stringFromNumber(valueDouble!)!)km"
        }
        return nil
    }
    /// 格式化金额(xx元)
    func formatPrice(price: NSNumber?) -> String?{
        if (price == nil) {
            return nil
        }
        let priceNumber = formatPriceNumber(price)
        return priceNumber == nil ? nil : "\(priceNumber!)元"
    }
    /// 格式化金额
    func formatPriceNumber(price: NSNumber?) ->String?{
        if (price == nil) {
            return nil
        }
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.paddingPosition = NSNumberFormatterPadPosition.AfterSuffix // 后缀
        numberFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundFloor // 取数模式,
        // Double 值
        let valueDouble = price?.doubleValue
        if valueDouble != nil {
            return "\(numberFormatter.stringFromNumber(valueDouble!)!)"
        }
        // Int 值
        let valueInt = price?.integerValue
        if valueInt != nil{
            return "\(numberFormatter.stringFromNumber(valueInt!)!)"
        }
        return nil
    }
    /// 返回字符串值
    func valueString(value:AnyObject?) -> String?{
        if value == nil{
            return ""
        }
        return value?.description
    }
    /// 区域化字符串
    func localized(key:String) -> String{
        return NSLocalizedString(key, comment:"");
    }
    /// 生成随机文件名称
    func genFileName(minLength:Int,_ maxLength:Int,_ ext:String) -> String{
        var name = ""
        let charcount = FILE_NAME_KEY.characters.count
        let length = minLength + Int(arc4random_uniform(UInt32(maxLength - minLength)))
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(charcount)))
            let char = FILE_NAME_KEY[FILE_NAME_KEY.startIndex.advancedBy(index)]
            name = "\(name)\(char)"
        }
        return "\(name).\(ext)"
        
    }
    
    func isChinese(tag:String) -> Bool{
        let match = "(^[\\u4e00-\\u9fa5]+$)";
        let predicate = NSPredicate(format: "SELF matches \(match)")
        return predicate.evaluateWithObject(tag)
    }
    /// Int8,Int16,Int32 -> Character
    func codeToCharacter(code:Int) -> Character{
        return Character(UnicodeScalar(code))
    }
    /// Character -> Int8,Int16,UnicodeScalar(Int32)
    func characterToInt8(character: Character) -> UInt8{
        for i in String(character).utf8{
            return i
        }
        return 0
    }
    func characterToInt16(character: Character) -> UInt16{
        for i in String(character).utf16{
            return i
        }
        return 0
    }
    func characterToUnicodeScalar(character: Character) -> UnicodeScalar{
        for i in String(character).unicodeScalars{
            return i
        }
        return UnicodeScalar(0)
    }
    func test(){
        
    }
}