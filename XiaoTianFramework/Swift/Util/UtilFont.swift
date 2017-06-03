//
//  UtilFont.swift
//  DriftBook
//
//  Created by XiaoTian on 16/8/6.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilFontXT)
open class UtilFont: NSObject{
    // 添加字体
    // 1.拷贝字体文件driftbook_font.ttf到项目中
    // 2.设置该字体文件被拷贝到app中 Copy Resource bundle
    // 3.在info.plist中声明app加载的字体文件
    // 4.UIFon(name:) 通过字体名称加载[注意不是字体文件名]
    
    /// 默认字体
    var textNormal: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 13){
            return font
        }
        return UIFont.systemFont(ofSize: 13)
    }
    /// 列表头字体大小
    var textItem: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 15){
            return font
        }
        return UIFont.systemFont(ofSize: 15)
    }
    /// 列表标题字体大小
    var textTitle: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 14){
            return font
        }
        return UIFont.systemFont(ofSize: 14)
    }
    /// 列表内容字体大小
    var textLabel: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 13){
            return font
        }
        return UIFont.systemFont(ofSize: 13)
    }
    /// 消息提示字体大小
    var textNewTip: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 10){
            return font
        }
        return UIFont.systemFont(ofSize: 10)
    }
    /// 分享文本字体大小
    var textShare: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 10){
            return font
        }
        return UIFont.systemFont(ofSize: 10)
    }
    /// 输入框文字大小
    var textInput: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 15){
            return font
        }
        return UIFont.systemFont(ofSize: 15)
    }
    var textButton: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 14){
            return font
        }
        return UIFont.systemFont(ofSize: 14)
    }
    /// 工具栏
    var textBar: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 15){
            return font
        }
        return UIFont.systemFont(ofSize: 15)
    }
    /// 指定字体大小
    func withSize(_ size: CGFloat) -> UIFont{
        if let font = UIFont(name: "HYQiHei", size: size){
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    var dialogTitle: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 13){
            return font
        }
        return UIFont.systemFont(ofSize: 13)
    }
    
    var dialogContent: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 13){
            return font
        }
        return UIFont.systemFont(ofSize: 13)
    }
    
    var dialogButton: UIFont{
        if let font = UIFont(name: "HYQiHei", size: 14){
            return font
        }
        return UIFont.systemFont(ofSize: 14)
    }
    
}
