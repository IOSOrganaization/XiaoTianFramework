//
//  ConstantNet.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/3.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(ConstantNetXT)
class ConstantNet : NSObject{
    // 开发环境
//    static let HTTP_SERVER = "http://120.25.202.228";
//    static let HTTP_PORT = "8081"
//    static let HTTP_PORT_IMAGE = "81"
    // 正式环境
    static let HTTP_SERVER = "http://www.piaoliusu.com";
    static let HTTP_PORT = "80"
    static let HTTP_PORT_IMAGE = "81"
    // 分享的链接
    static let SHARE_WEB = "http://www.piaoliusu.com"
    // 梁子: 18898323244
    // 魏子: 13826675378
    // 设置环信应用的授权
    //  APP Key
    //   测试环境: 583899461#driftbook
    //   正式环境: piaoliushu#driftbook
    //  APNS 推送证书配置
    //   测试环境: DriftBookDev
    //   正式环境: DriftBook
    static let EASE_CHAT_APPKEY = "piaoliushu#driftbook"
    static let EASE_CHAT_APNS_NAME = "DriftBook"
}