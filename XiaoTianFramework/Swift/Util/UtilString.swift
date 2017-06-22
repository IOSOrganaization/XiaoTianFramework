//
//  UtilString.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/6.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilStringXT)
open class UtilString :NSObject {
    let FILE_NAME_KEY = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
    
    /// 根据字体大小和指定宽度计算占用高度
    public func stringHeightWithFontSize(_ string: String,fontName: String,fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont(name: fontName, size: fontSize)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [NSFontAttributeName:font!, NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = string as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    /// 格式化就;距离
    public func formatDistance(_ distance: NSNumber?) -> String? {
        if (distance == nil) {
            return nil
        }
        let numberFormatter = NumberFormatter()
        // 填充
        //numberFormatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        //numberFormatter.paddingCharacter = "0"
        //numberFormatter.minimumIntegerDigits = 10
        //
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.paddingPosition = NumberFormatter.PadPosition.afterSuffix // 后缀
        numberFormatter.maximumFractionDigits = 1 // 小数点后最大位数
        //numberFormatter.maximumIntegerDigits = 2 // 整数位最大位数
        numberFormatter.roundingMode = NumberFormatter.RoundingMode.floor // 取数模式,
        // Double 值
        var valueDouble = distance?.doubleValue
        if valueDouble != nil{
            valueDouble = valueDouble! / 1000.0
        }
        if valueDouble != nil {
            return "\(numberFormatter.string(from: NSNumber(value:valueDouble!))!)km"
        }
        // Int 值
        let valueInt = distance?.intValue
        if valueInt != nil{
            valueDouble = Double(valueInt!) / 1000.0
        }
        if valueDouble != nil {
            return "\(numberFormatter.string(from: NSNumber(value:valueDouble!))!)km"
        }
        return nil
    }
    /// 格式化金额(xx元)
    public func formatPrice(_ price: NSNumber?) -> String?{
        if (price == nil) {
            return nil
        }
        let priceNumber = formatPriceNumber(price)
        return priceNumber == nil ? nil : "\(priceNumber!)元"
    }
    /// 格式化金额
    public func formatPriceNumber(_ price: NSNumber?) ->String?{
        if (price == nil) {
            return nil
        }
        // NSDecimalNumber,NSDecimal,NumberFormatter
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.paddingPosition = NumberFormatter.PadPosition.afterSuffix // 后缀
        numberFormatter.roundingMode = NumberFormatter.RoundingMode.floor // 取数模式,
        // Double 值
        let valueDouble = price?.doubleValue
        if valueDouble != nil {
            return "\(numberFormatter.string(from: NSNumber(value:valueDouble!))!)"
        }
        // Int 值
        let valueInt = price?.intValue
        if valueInt != nil{
            return "\(numberFormatter.string(from: NSNumber(value:valueInt!))!)"
        }
        return nil
    }
    /// 返回字符串值
    public func valueString(_ value:AnyObject?) -> String?{
        if value == nil{
            return ""
        }
        return value?.description
    }
    /// 区域化字符串
    public func localized(_ key:String) -> String{
        return NSLocalizedString(key, comment:"");
    }
    /// 生成随机文件名称
    open func genFileName(_ minLength:Int,_ maxLength:Int,_ ext:String) -> String{
        var name = ""
        let charcount = FILE_NAME_KEY.characters.count
        let length = minLength + Int(arc4random_uniform(UInt32(maxLength - minLength)))
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(charcount)))
            let char = FILE_NAME_KEY[FILE_NAME_KEY.characters.index(FILE_NAME_KEY.startIndex, offsetBy: index)]
            name = "\(name)\(char)"
        }
        return "\(name).\(ext)"
        
    }
    /// 是否是中文
    public func isChinese(_ tag:String) -> Bool{
        let match = "(^[\\u4e00-\\u9fa5]+$)";
        let predicate = NSPredicate(format: "SELF matches \(match)")
        return predicate.evaluate(with: tag)
    }
    /// Int8,Int16,Int32 -> Character
    public func codeToCharacter(_ code:Int) -> Character{
        return Character(UnicodeScalar(code)!)
    }
    /// Character -> Int8,Int16,UnicodeScalar(Int32)
    public func characterToInt8(_ character: Character) -> UInt8{
        for i in String(character).utf8{
            return i
        }
        return 0
    }
    /// 进程中唯一字符串
    public func processUniqueString() -> String{
        return ProcessInfo.processInfo.globallyUniqueString
    }
    public func characterToInt16(_ character: Character) -> UInt16{
        for i in String(character).utf16{
            return i
        }
        return 0
    }
    public func characterToUnicodeScalar(_ character: Character) -> UnicodeScalar{
        for i in String(character).unicodeScalars{
            return i
        }
        return UnicodeScalar(0)
    }
    public func urlHost(url: String) -> String?{
        do{
            let regex = try NSRegularExpression(pattern: ".*?//(.*?)/.*", options: [])
            let match = regex.firstMatch(in: url, options: .reportCompletion, range: NSMakeRange(0, url.characters.count))
            if match != nil{
                if let range = match?.rangeAt(1){
                    let start = url.index(url.startIndex, offsetBy: range.location)
                    let end = url.index(start, offsetBy: range.length)
                    return url.substring(with: start..<end)
                }
            }
        }catch{
            Mylog.log(error)
        }
        return nil
    }
    public func subString(_ data:String,_ start:Int,_ count:Int) -> String{
        if start < 0 || start + count >= data.characters.count || start > count {
            return data
        }
        //data.index(after: data.startIndex)
        //data.index(before: data.startIndex)
        let startIndex = data.index(data.startIndex, offsetBy: start)
        let endIndex = data.index(startIndex, offsetBy: count)
        return data.substring(with: startIndex..<endIndex)
    }
    func test(){
        
    }
    
}
