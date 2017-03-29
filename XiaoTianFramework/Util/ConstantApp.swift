//
//  ConstantApp.swift
//  DriftBook
//  配置常量
//  Created by XiaoTian on 16/6/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
//  XCode Quickly Key

//  快速帮助上下文: Command-Control-Shift-?
//  快速帮助窗口: Command-Option-2
//  文档过滤输入: Command-Option-J
//  控件过滤输入: Command-Option-L
//  以协助窗口打开变量相关声明: Command-Option-Click[变量]
//  以协助窗口打开变量相关声明: Command-Control-Option-J [跳转到当前指针所在变量]
//  以协助窗口打开文件:Option-Click[文件]
//  以当前窗口打开变量相关声明: Command-Click[变量]
//  以新窗口打开变量相关声明: Command-Double-Click[变量]
//  快速打开/搜索文件: Command-Shift-O[输入要打开的文件名]
//  以新 Tab 打开文件: Command-T
//  选择内容右缩进: Command-[
//  选择内容左缩进: Command-]
//  对齐所选/当前代码 Re-Indent: Control-I
//  跳转到文件首行: Command-上箭头
//  跳转到文件尾行: Command-下箭头
//  跳转到当前行头: Command- 左箭头
//  跳转到当前行未: Command- 右箭头
//  选择光标到文件头内容: Command-Shift- 上箭头
//  选择光标到文件未内容: Command-Shift- 下箭头
//  选择光标到行头: Command-Shift- 左箭头
//  选择光标到行未: Command-Shift- 右箭头
//  收起所有方法代码: Command-Option-Shift- 左箭头
//  展开所有方法代码: Command-Option-Shift- 右箭头
//  收起当前光标所在方法代码: Command-Option- 左箭头
//  展开当前光标所在方法代码: Command-Option- 右箭头
//  选中代码/当前光标行上移一行: Command-Option-[
//  选中代码/当前光标行下移一行: Command-Option-]
//  快速帮助注解: /** ... */: *:声明段落,:param::输入变量,:returns::返回值[/// :简单模式快速帮助注解]
//  Object-C打开头文件/实现文件[Swift 无]: Command-Control-上/下箭头
//  SVN 提交选中/当前文件: Command-Option-C
//  手动调用代码提示: Esc
//  代码提示后跳转到下一个占位符: Tab/Control-/
//  自动完成占位符代码: 占位符双击[针对匿名函数自动完成匿名函数声明]
//  文件导航打开上一个文件: Command-Control- 左箭头
//  文件导航打开下一个文件: Command-Control- 右箭头
//  当前文件查找内容: Command-F
//  项目中查找文件内容: Command-Shift-F
//  全屏显示: Command-Control-F
//  删除当前光标所在行: Control-A[光标到行首],Control-K[删除光标前内容],Control-K[删除光标前空行]
//  AutoLayout Update Frame 更新约束: Command-Option-=
//
//  Window Tab 窗口快捷建:
//      1.项目导航窗口[隐藏/显示] Command-0
//          a.属性窗口内部 Tab: Command-[1,2,3,4,5,6,7,8,9]
//      2.工具/属性窗口[隐藏/显示] Command-Option-0
//          a.属性窗口内部 Tab: Command-Option-[1,2,3,4,5,6,7,8,9]
//          b.组件窗口过滤器 Filter: Command-Option-L
//      2.调试 Debug 窗口显示: Command-Shift-C
//        调试 Debug 窗口隐藏: Command-Shift-Y
//      3.窗口导航栏[隐藏/显示]: Command-Option-T
//  VC 打开当前文件列表 Command-5 [快速找到当前源码对应的 xib:: 同名]
//  Image XCAssets 图片拉伸配置说名
//      1.默认图片的 Slicing 为 None 不设置拉伸剪切区域
//      2.开启 Slicing 位于图片右下角的 Show Slicing 功能
//      2.拉伸模式为: None(无),Horizontal(横向), Vertical(纵向),Horizontal & Vertical (横向和纵向)
//      2.
//      2.
//      2.
// [weak unowned] :如果能够确定在访问时不会已被释放的话，尽量使用 unowned(引用的为内存地址) ，如果存在被释放的可能，那就选择用 weak(引用的为 Option 类型)
/**
    程序常量配置
    * RSA加密配置
    * 定义Object关联Key
    * Notification 通知标识字符串
 */
@objc(ConstantApp)
class ConstantApp : NSObject{
    static let RSA_MODULUS = "bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07";
    static let RSA_PUBLIC_EXPONENT = "010001";
    //
    static let XIAOTIAN_STYLE_SUB: Int = 1
    static let XIAOTIAN_STYLE_STUB: Int = 0
    // Object 对象引用关联常数Key
    // 关联UIView类型
    static var ASSOCIATED_KEY_VIEW_0 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_1 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_2 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_3 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_4 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_5 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_6 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_7 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_8 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_9 : UnsafePointer<UIView>     =   nil
    static var ASSOCIATED_KEY_VIEW_10 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_11 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_12 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_13 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_14 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_15 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_16 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_17 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_18 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_19 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_20 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_21 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_22 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_23 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_24 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_25 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_26 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_27 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_28 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_29 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_30 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_31 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_32 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_33 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_34 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_35 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_36 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_37 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_38 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_39 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_40 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_41 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_42 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_43 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_44 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_45 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_46 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_47 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_48 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_49 : UnsafePointer<UIView>    =   nil
    static var ASSOCIATED_KEY_VIEW_50 : UnsafePointer<UIView>    =   nil
    // 关联Int
    static var ASSOCIATED_KEY_INT_0 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_1 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_2 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_3 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_4 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_5 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_6 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_7 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_8 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_9 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_10 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_11 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_12 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_13 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_14 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_15 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_16 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_17 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_18 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_19 : UnsafePointer<Int>    =   nil
    static var ASSOCIATED_KEY_INT_20 : UnsafePointer<Int>    =   nil
    // 关联String
    static var ASSOCIATED_KEY_STRING_0 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_1 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_2 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_3 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_4 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_5 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_6 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_7 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_8 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_9 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_10 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_11 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_12 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_13 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_14 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_15 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_16 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_17 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_18 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_19 : UnsafePointer<String>    =   nil
    static var ASSOCIATED_KEY_STRING_20 : UnsafePointer<String>    =   nil
    // 关联AnyObject
    static var ASSOCIATED_KEY_ANYOBJECT_0 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_1 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_2 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_3 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_4 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_5 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_6 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_7 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_8 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_9 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_10 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_11 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_12 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_13 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_14 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_15 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_16 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_17 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_18 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_19 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_20 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_31 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_32 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_33 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_34 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_35 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_36 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_37 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_38 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_39 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_40 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_41 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_42 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_43 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_44 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_45 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_46 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_47 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_48 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_49 : UnsafePointer<AnyObject>    =   nil
    static var ASSOCIATED_KEY_ANYOBJECT_50 : UnsafePointer<AnyObject>    =   nil
    // 关联其他类型
    static var ASSOCIATED_KEY_UTIL_PREFERENCE : UnsafePointer<UtilPreference> = nil
    static var ASSOCIATED_KEY_UTIL_SWIFT : UnsafePointer<UtilSwift> = nil
    static var ASSOCIATED_KEY_UTIL_COLOR : UnsafePointer<UtilColor> = nil
    static var ASSOCIATED_KEY_UTIL_IMAGE : UnsafePointer<UtilImage> = nil
    static var ASSOCIATED_KEY_UTIL_JSONSERIALIZER : UnsafePointer<XTFSerializerJson> = nil
    static var ASSOCIATED_KEY_UTIL_DATETIME : UnsafePointer<UtilDateTime> = nil
    static var ASSOCIATED_KEY_UTIL_STRING : UnsafePointer<UtilString> = nil
    static var ASSOCIATED_KEY_UTIL_UIVIEW : UnsafePointer<UtilUIView> = nil
    static var ASSOCIATED_KEY_UTIL_LABEL : UnsafePointer<UtilLabel> = nil
    static var ASSOCIATED_KEY_UTIL_ANYOBJECT : UnsafePointer<UtilAnyObject> = nil
    static var ASSOCIATED_KEY_UTIL_FONT : UnsafePointer<UtilFont> = nil
    static var ASSOCIATED_KEY_UTIL_ENVIRONMENT : UnsafePointer<UtilEnvironment> = nil
    static var ASSOCIATED_KEY_UTIL_REGULAREXPRESSION : UnsafePointer<UtilRegularExpression> = nil
    static var ASSOCIATED_KEY_UTIL_ATTRIBUTESTRING : UnsafePointer<UtilAttributedString> = nil
    static var ASSOCIATED_KEY_UTIL_DEFAULT_NOTIFICATION : UnsafePointer<UtilNSNotificationDefaultCenter> = nil
    static var ASSOCIATED_KEY_SHOW_KEYBOARD : UnsafePointer<Bool> = nil
    static var ASSOCIATED_KEY_KEYBOARD_HEIGHT : UnsafePointer<CGFloat> = nil
    // Action Sheet Tag 标识
    static let TAG_ACTION_SHEET_PICK_IMAGE = 0x4409
    // View Tag 分割器标识
    static let TAG_VIEW_SEPERATOR = 5509
    // 图书列表行高
    static let HEIGHT_BOOK_LIST:CGFloat = 76
    // NSNotificationCenter Name
    static let NOTIFICATION_NAME_BOOK = "NOTIFICATION_NAME_BOOK" // 我的书房图书数据改变通知
    static let NOTIFICATION_NAME_LABEL = "NOTIFICATION_NAME_LABEL" // 我的标签信数据变通知
    static let NOTIFICATION_CURRENT_PERSON = "NOTIFICATION_CURRENT_PERSON" // 当前用户信息数据改变通知
    static let NOTIFICATION_ALIPAY_RESULT = "NOTIFICATION_ALIPAY_RESULT" // 阿里支付结果通知
    static let KNOTIFICATIONNAME_DELETEALLMESSAGE = "RemoveAllMessages"
    static let kHaveUnreadAtMessage = "kHaveAtMessage"
    static let NOTIFICATION_EASE_MESSAGE_NEW = "NOTIFICATION_EASE_MESSAGE_NEW"
    static let NOTIFICATION_EASE_MESSAGE_DELETE = "NOTIFICATION_EASE_MESSAGE_DELETE"
    static let NOTIFICATION_EASE_NETWORK_CHANGE = "NOTIFICATION_EASE_NETWORK_CHANGE"
    static let NOTIFICATION_EASE_CHAT_DELETE = "NOTIFICATION_EASE_CHAT_DELETE"
    static let NOTIFICATION_EASE_CHAT_NEW = "NOTIFICATION_EASE_CHAT_NEW"
    static let NOTIFICATION_EASE_CONVERSATION_CHANGE = "NOTIFICATION_EASE_CONVERSATION_CHANGE"
    static let NOTIFICATION_LOGIN = "NOTIFICATION_LOGIN"
    static let NOTIFICATION_LOGOUT = "NOTIFICATION_LOGOUT"
    // UserInfo Key
    static let KEY_USERINFO_ID = "KEY_USERINFO_ID" // userinfo key id
    static let KEY_USERINFO_NAME = "KEY_USERINFO_NAME"
    static let KEY_USERINFO_BOOLEAN = "KEY_USERINFO_BOOLEAN"
    static let KEY_USERINFO_INTEGER = "KEY_USERINFO_INTEGER"
    static let KEY_USERINFO_DOUBLE = "KEY_USERINFO_DOUBLE"
    static let KEY_USERINFO_NUMBER = "KEY_USERINFO_NUMBER"
    static let KEY_USERINFO_PARAM_0 = "KEY_USERINFO_PARAM_0"
    static let KEY_USERINFO_PARAM_1 = "KEY_USERINFO_PARAM_1"
    static let KEY_USERINFO_PARAM_2 = "KEY_USERINFO_PARAM_2"
    static let KEY_USERINFO_PARAM_3 = "KEY_USERINFO_PARAM_3"
    static let KEY_USERINFO_PARAM_4 = "KEY_USERINFO_PARAM_4"
    static let KEY_USERINFO_PARAM_5 = "KEY_USERINFO_PARAM_5"
    static let KEY_USERINFO_PARAM_6 = "KEY_USERINFO_PARAM_6"
    static let KEY_USERINFO_PARAM_7 = "KEY_USERINFO_PARAM_7"
    static let KEY_USERINFO_PARAM_8 = "KEY_USERINFO_PARAM_8"
    static let KEY_USERINFO_PARAM_9 = "KEY_USERINFO_PARAM_9"
    static let KEY_USERINFO_PARAM_10 = "KEY_USERINFO_PARAM_10"
    //
    private override init() {
        fatalError("Can not init.")
    }
}