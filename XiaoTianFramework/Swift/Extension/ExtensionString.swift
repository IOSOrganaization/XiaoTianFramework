//
//  ExtensionString.swift
//  XiaoTianFramework
//  String 扩展
//  Created by guotianrui on 2017/6/7.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

extension String{
    public func occurrencesOfString(_ aString: String) -> Int{
        var occurrences: Int = 0
        var range: Range<String.Index>? = self.startIndex ..< self.endIndex
        while range != nil{
            range = self.range(of: aString, options: .caseInsensitive, range: range, locale: nil)
            if range != nil{
                range = range!.upperBound ..< self.endIndex
                occurrences += 1
            }
        }
        return occurrences
    }
    /// 区域化文本(扩展不能包含相同属性,方法签名,否则重定义)
    var localized:String? {
        return NSLocalizedString(self, comment:"")
    }
}
