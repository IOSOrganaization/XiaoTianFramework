//
//  ExtensionAnyObject.swift
//  DriftBook
//  便捷工具类全局单例扩展
//  Created by XiaoTian on 16/10/29.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

public extension NSObject {
    // Associated TAG Keys
    private struct AssociatedKeys{
        // creates the static associated object key we need but doesn’t muck up the global namespace
        static var TAG = "XiaoTian_NSObject_AssociatedKeys_TAG"
    }
    // tag Object
    public var xiaoTianTag: Any? {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.TAG)
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.TAG, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 工具单例 [全局单例模式]
    public var utilShared: Util{
        return Util.share
    }
    /// 单例实例
    public class Util {
        /// Associate Key
        private struct AssociatedKeys{
            static var xml = "XiaoTian_NSObject_Util_AssociatedKeys_xml"
            static var kvc = "XiaoTian_NSObject_Util_AssociatedKeys_kvc"
            static var json = "XiaoTian_NSObject_Util_AssociatedKeys_json"
            static var file = "XiaoTian_NSObject_Util_AssociatedKeys_file"
            static var font = "XiaoTian_NSObject_Util_AssociatedKeys_font"
            static var label = "XiaoTian_NSObject_Util_AssociatedKeys_label"
            static var swift = "XiaoTian_NSObject_Util_AssociatedKeys_swift"
            static var image = "XiaoTian_NSObject_Util_AssociatedKeys_image"
            static var color = "XiaoTian_NSObject_Util_AssociatedKeys_color"
            static var sqlite = "XiaoTian_NSObject_Util_AssociatedKeys_sqlite"
            static var string = "XiaoTian_NSObject_Util_AssociatedKeys_string"
            static var uiView = "XiaoTian_NSObject_Util_AssociatedKeys_uiView"
            static var bundle = "XiaoTian_NSObject_Util_AssociatedKeys_bundle"
            static var coreData = "XiaoTian_NSObject_Util_AssociatedKeys_coreData"
            static var dateTime = "XiaoTian_NSObject_Util_AssociatedKeys_dateTime"
            static var security = "XiaoTian_NSObject_Util_AssociatedKeys_security"
            static var anyObject = "XiaoTian_NSObject_Util_AssociatedKeys_anyObject"
            static var uiControl = "XiaoTian_NSObject_Util_AssociatedKeys_uiControl"
            static var animation = "XiaoTian_NSObject_Util_AssociatedKeys_animation"
            static var preference = "XiaoTian_NSObject_Util_AssociatedKeys_preference"
            static var environment = "XiaoTian_NSObject_Util_AssociatedKeys_environment"
            static var uiTableView = "XiaoTian_NSObject_Util_AssociatedKeys_uiTableView"
            static var notification = "XiaoTian_NSObject_Util_AssociatedKeys_notification"
            static var runtimeSwift = "XiaoTian_NSObject_Util_AssociatedKeys_runtimeSwift"
            static var attributeString = "XiaoTian_NSObject_Util_AssociatedKeys_attributeString"
            static var interfaceBuilder = "XiaoTian_NSObject_Util_AssociatedKeys_interfaceBuilder"
            static var regularExpression = "XiaoTian_NSObject_Util_AssociatedKeys_regularExpression"
            static var notificationCenter = "XiaoTian_NSObject_Util_AssociatedKeys_notificationCenter"
        }
        // 全局单例
        fileprivate static let share = Util()
        fileprivate init(){
            // private 声明,防止实例化
        }
        // Util 延时实例化
        /// NSUserDefaults管理工具
        public var preference: UtilPreference{
            return objc_getAssociatedObject(self, &AssociatedKeys.preference) as? UtilPreference ?? {
                    let util = UtilPreference()
                    objc_setAssociatedObject(self, &AssociatedKeys.preference, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// Swift语法常用工具
        public var swift: UtilSwift{
            return objc_getAssociatedObject(self, &AssociatedKeys.swift) as? UtilSwift ?? {
                    let util = UtilSwift()
                    objc_setAssociatedObject(self, &AssociatedKeys.swift, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 字符串常用工具
        public var string: UtilString{
            return objc_getAssociatedObject(self, &AssociatedKeys.string) as? UtilString ?? {
                    let util = UtilString()
                    objc_setAssociatedObject(self, &AssociatedKeys.string, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 时间日期常用工具
        public var dateTime: UtilDateTime{
            return objc_getAssociatedObject(self, &AssociatedKeys.dateTime) as? UtilDateTime ?? {
                    let util = UtilDateTime()
                    objc_setAssociatedObject(self, &AssociatedKeys.dateTime, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 图片常用工具
        public var image: UtilImage{
            return objc_getAssociatedObject(self, &AssociatedKeys.dateTime) as? UtilImage ?? {
                    let util = UtilImage()
                    objc_setAssociatedObject(self, &AssociatedKeys.dateTime, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 颜色常用工具
        public var color: UtilColor{
            return objc_getAssociatedObject(self, &AssociatedKeys.color) as? UtilColor ?? {
                    let util = UtilColor()
                    objc_setAssociatedObject(self, &AssociatedKeys.color, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 视图UIView常用工具
        public var uiView: UtilUIView{
            return objc_getAssociatedObject(self, &AssociatedKeys.uiView) as? UtilUIView ?? {
                    let util = UtilUIView()
                    objc_setAssociatedObject(self, &AssociatedKeys.uiView, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 视图UILabel常用工具
        public var label: UtilLabel{
            return objc_getAssociatedObject(self, &AssociatedKeys.label) as? UtilLabel ?? {
                    let util = UtilLabel()
                    objc_setAssociatedObject(self, &AssociatedKeys.label, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// AnyObject对象工具
        public var anyObject: UtilAnyObject{
            return objc_getAssociatedObject(self, &AssociatedKeys.anyObject) as? UtilAnyObject ?? {
                    let util = UtilAnyObject()
                    objc_setAssociatedObject(self, &AssociatedKeys.anyObject, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// Font 字体工具
        public var font: UtilFont{
            return objc_getAssociatedObject(self, &AssociatedKeys.font) as? UtilFont ?? {
                    let util = UtilFont()
                    objc_setAssociatedObject(self, &AssociatedKeys.font, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// Environment 环境工具
        public var environment: UtilEnvironment{
            return objc_getAssociatedObject(self, &AssociatedKeys.environment) as? UtilEnvironment ?? {
                    let util = UtilEnvironment()
                    objc_setAssociatedObject(self, &AssociatedKeys.environment, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// RegularExpression 正则匹配
        public var regularExpression: UtilRegularExpression{
            return objc_getAssociatedObject(self, &AssociatedKeys.regularExpression) as? UtilRegularExpression ?? {
                    let util = UtilRegularExpression()
                    objc_setAssociatedObject(self, &AssociatedKeys.regularExpression, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// AttributeString 属性字符串
        public var attributeString: UtilAttributedString{
            return objc_getAssociatedObject(self, &AssociatedKeys.attributeString) as? UtilAttributedString ?? {
                    let util = UtilAttributedString()
                    objc_setAssociatedObject(self, &AssociatedKeys.attributeString, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// NSNotificationCenter DefaultCenter 默认通知中心
        public var notificationCenter: UtilNotificationDefaultCenter{
            return objc_getAssociatedObject(self, &AssociatedKeys.notification) as? UtilNotificationDefaultCenter ?? {
                    let util = UtilNotificationDefaultCenter()
                    objc_setAssociatedObject(self, &AssociatedKeys.notification, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        /// 动画
        public var animation:UtilAnimation{
            return objc_getAssociatedObject(self, &AssociatedKeys.animation) as? UtilAnimation ?? {
                    let util = UtilAnimation()
                    objc_setAssociatedObject(self, &AssociatedKeys.animation, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        ///
        public var bundle:UtilBundle{
            return objc_getAssociatedObject(self, &AssociatedKeys.bundle) as? UtilBundle ?? {
                    let util = UtilBundle()
                    objc_setAssociatedObject(self, &AssociatedKeys.bundle, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var coreData:UtilCoreData{
            return objc_getAssociatedObject(self, &AssociatedKeys.coreData) as? UtilCoreData ?? {
                    let util = UtilCoreData()
                    objc_setAssociatedObject(self, &AssociatedKeys.coreData, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var file:UtilFile{
            return objc_getAssociatedObject(self, &AssociatedKeys.file) as? UtilFile ?? {
                    let util = UtilFile()
                    objc_setAssociatedObject(self, &AssociatedKeys.file, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var interfaceBuilder:UtilInterfaceBuilder{
            return objc_getAssociatedObject(self, &AssociatedKeys.interfaceBuilder) as? UtilInterfaceBuilder ?? {
                    let util = UtilInterfaceBuilder()
                    objc_setAssociatedObject(self, &AssociatedKeys.interfaceBuilder, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var json:UtilJson{
            return objc_getAssociatedObject(self, &AssociatedKeys.json) as? UtilJson ?? {
                    let util = UtilJson()
                    objc_setAssociatedObject(self, &AssociatedKeys.json, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var kvc:UtilKVC{
            return objc_getAssociatedObject(self, &AssociatedKeys.kvc) as? UtilKVC ?? {
                    let util = UtilKVC()
                    objc_setAssociatedObject(self, &AssociatedKeys.kvc, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var notification:UtilNotification{
            return objc_getAssociatedObject(self, &AssociatedKeys.notification) as? UtilNotification ?? {
                    let util = UtilNotification()
                    objc_setAssociatedObject(self, &AssociatedKeys.notification, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var runtimeSwift:UtilRuntimeSwift{
            return objc_getAssociatedObject(self, &AssociatedKeys.runtimeSwift) as? UtilRuntimeSwift ?? {
                    let util = UtilRuntimeSwift()
                    objc_setAssociatedObject(self, &AssociatedKeys.runtimeSwift, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var security:UtilSecurity{
            return objc_getAssociatedObject(self, &AssociatedKeys.security) as? UtilSecurity ?? {
                    let util = UtilSecurity()
                    objc_setAssociatedObject(self, &AssociatedKeys.security, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var sqlite:UtilSqlite{
            return objc_getAssociatedObject(self, &AssociatedKeys.sqlite) as? UtilSqlite ?? {
                    let util = UtilSqlite()
                    objc_setAssociatedObject(self, &AssociatedKeys.sqlite, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var uiControl:UtilUIControl{
            return objc_getAssociatedObject(self, &AssociatedKeys.uiControl) as? UtilUIControl ?? {
                    let util = UtilUIControl()
                    objc_setAssociatedObject(self, &AssociatedKeys.uiControl, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var uiTableView:UtilUITableView{
            return objc_getAssociatedObject(self, &AssociatedKeys.uiTableView) as? UtilUITableView ?? {
                    let util = UtilUITableView()
                    objc_setAssociatedObject(self, &AssociatedKeys.uiTableView, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    return util
                }()
        }
        public var xml:UtilXML{
            return objc_getAssociatedObject(self, &AssociatedKeys.xml) as? UtilXML ?? {
                let util = UtilXML()
                objc_setAssociatedObject(self, &AssociatedKeys.xml, util, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return util
                }()
        }
        deinit {
            Mylog.log("Util Shared deinit")
        }
    }
}
