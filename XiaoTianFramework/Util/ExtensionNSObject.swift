//
//  ExtensionAnyObject.swift
//  DriftBook
//  便捷工具类全局单例
//  Created by XiaoTian on 16/10/29.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

extension NSObject {
    /// 工具单例 [全局模式]
    var utilShared: Util{
        get {
            return Util.shared
        }
    }
    /// 单例实例
    public class Util {
        // 全局单例
        static let shared = Util()
        private init(){
            // private 声明,防止实例化
        }
        // Util 延时实例化
        /// NSUserDefaults管理工具
        var preference: UtilPreference{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_PREFERENCE)
                if object != nil {
                    return object as! UtilPreference
                }
                let value = UtilPreference()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_PREFERENCE, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// Swift语法常用工具
        var swift: UtilSwift{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_SWIFT)
                if object != nil {
                    return object as! UtilSwift
                }
                let value = UtilSwift()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_SWIFT, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 字符串常用工具
        var string: UtilString{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_STRING)
                if object != nil {
                    return object as! UtilString
                }
                let value = UtilString()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_STRING, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 时间日期常用工具
        var dateTime: UtilDateTime{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_DATETIME)
                if object != nil {
                    return object as! UtilDateTime
                }
                let value = UtilDateTime()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_DATETIME, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 图片常用工具
        var image: UtilImage{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_IMAGE)
                if object != nil {
                    return object as! UtilImage
                }
                let value = UtilImage()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_IMAGE, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 颜色常用工具
        var color: UtilColor{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_COLOR)
                if object != nil {
                    return object as! UtilColor
                }
                let value = UtilColor()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_COLOR, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 视图UIView常用工具
        var uiView: UtilUIView{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_UIVIEW)
                if object != nil {
                    return object as! UtilUIView
                }
                let value = UtilUIView()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_UIVIEW, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// 视图UILabel常用工具
        var label: UtilLabel{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_LABEL)
                if object != nil {
                    return object as! UtilLabel
                }
                let value = UtilLabel()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_LABEL, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// AnyObject对象工具
        var anyObject: UtilAnyObject{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ANYOBJECT)
                if object != nil {
                    return object as! UtilAnyObject
                }
                let value = UtilAnyObject()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ANYOBJECT, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// Font 字体工具
        var font: UtilFont{
            get { // 上下文单例
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_FONT)
                if object != nil {
                    return object as! UtilFont
                }
                let value = UtilFont()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_FONT, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// Environment 环境工具
        var environment: UtilEnvironment{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ENVIRONMENT)
                if object != nil {
                    return object as! UtilEnvironment
                }
                let value = UtilEnvironment()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ENVIRONMENT, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// RegularExpression 正则匹配
        var regularExpression: UtilRegularExpression{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_REGULAREXPRESSION)
                if object != nil {
                    return object as! UtilRegularExpression
                }
                let value = UtilRegularExpression()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_REGULAREXPRESSION, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// AttributeString 属性字符串
        var attributeString: UtilAttributedString{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ATTRIBUTESTRING)
                if object != nil {
                    return object as! UtilAttributedString
                }
                let value = UtilAttributedString()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_ATTRIBUTESTRING, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
        /// NSNotificationCenter DefaultCenter 默认通知中心
        var notification: UtilNSNotificationDefaultCenter{
            get {
                let object = objc_getAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_DEFAULT_NOTIFICATION)
                if object != nil {
                    return object as! UtilNSNotificationDefaultCenter
                }
                let value = UtilNSNotificationDefaultCenter()
                objc_setAssociatedObject(self, &ConstantApp.ASSOCIATED_KEY_UTIL_DEFAULT_NOTIFICATION, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
        }
    }
}
