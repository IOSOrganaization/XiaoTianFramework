//
//  UtilBundle.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilBundle{
    /// Main Bundle
    open static var main: Bundle{
        return Bundle.main
    }
    // 不使用asset catalog命名规则
    // 1.@2x,@3x 声明屏幕指定资源
    // 2.~iphone,~ipad 声明设备指定资源
    //
    // 使用asset catalog 会自动帮你重命名为@2x,@3x
    //
    open static var xiaotian: Bundle?{
        let bundleDomain = Bundle(for: UtilBundle.self)
        guard let bundleURL = bundleDomain.url(forResource: "BundleXiaoTian", withExtension: "bundle") else {
            return nil
        }
        return Bundle(url: bundleURL)
    }
    
    open static func imageInBundle(_ name:String) -> UIImage?{
        return UIImage(named: name, in: main, compatibleWith: nil)
    }
    
    open static func imageInBundleXiaoTian(_ name:String) -> UIImage?{
        return UIImage(named: name, in: xiaotian, compatibleWith: nil)
    }
}
