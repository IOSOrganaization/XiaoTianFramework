//
//  UtilAnyObject.swift
//  DriftBook
//  AnyObject 对象工具类
//  Created by XiaoTian on 16/7/21.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilAnyObjectXT)
/// 调用对象关联绑定是必须要用同一个工具实例,因为变量key每一次都会新建实例都会创建key的地址不一致
public class UtilAnyObject: NSObject{
    // Associated Keys
    private struct AssociatedKeys{
        // creates the static associated object key we need but doesn’t muck up the global namespace
        static var lastDate = "UtilAnyObject_AssociatedKeys_lastDate"
    }
    // 定义索引
    static let INDEX_OBJECT_VALUE = 30//用于对象值
    static let INDEX_OBJECT_HOLDER = 29//用于对象视图缓存
    static let INDEX_INT_POSITION = 30//用于Int位置
    //
    var lastDate: String? {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.lastDate) as? String
        }
        set{
            if let newValue = newValue{
                objc_setAssociatedObject(self, &AssociatedKeys.lastDate, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    /// 关联对象到指定对象(func传递的时地址拷贝)
    public func setAssociatedObject(_ target:AnyObject?,_ value:AnyObject?,_ bindkey: UnsafeRawPointer){
        if target == nil || value == nil{
            return
        }
        objc_setAssociatedObject(self, bindkey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /// 获取对象中关联的对象
    public func getAssociatedObject(_ target:AnyObject?,_ bindkey: UnsafeRawPointer) -> Any!{
        if target == nil{
            return nil
        }
        return objc_getAssociatedObject(self, bindkey)
    }
    
    // ********************************** 绑定强引用属性 **********************************
    /// 通过索引关联对象到指定对象
    public func bingAnyObject(_ target:AnyObject?,_ value:AnyObject?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setAnyObjectAssociatedObject(target, value, index)
    }
    /// 通过索引获取指定对象的关联对象
    public func accessAnyObject(_ target:AnyObject?,_ index:Int) -> Any?{
        if target == nil{
            return nil
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        return getAnyObjectAssociatedObject(target, index)
    }
    /// 绑定Int
    public func bingInt(_ target:AnyObject?,_ value:Int?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setIntAssociatedObject(target, value, index)
    }
    /// 获取绑定Int
    public func accessInt(_ target:AnyObject?,_ index:Int) -> Int!{
        if target == nil{
            return nil
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        let value = getIntAssociatedObject(target, index)
        return value == nil ? nil : value!
    }
    /// 绑定String
    public func bingString(_ target:AnyObject?,_ value:String?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setStringAssociatedObject(target, value, index)
    }
    /// 获取绑定String
    public func accessString(_ target:AnyObject?,_ index:Int) -> String!{
        if target == nil{
            return nil
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        let value = getStringAssociatedObject(target, index)
        return value == nil ? nil : value!
    }
    /// 绑定number
    public func bindNumber(_ target:AnyObject?,_ value:NSNumber?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setNumberAssociatedObject(target, value, index)
    }
    /// 获取关联对象中的number
    public func accessNumber(_ target:AnyObject?,_ index:Int) -> NSNumber!{
        if target == nil{
            return nil
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        let value = getNumberAssociatedObject(target, index)
        return value == nil ? nil : value!
    }
    /// 设置AnyObject关联到对象中
    public func setAnyObjectAssociatedObject(_ target:AnyObject?,_ value:AnyObject?,_ index:Int){
        switch(index){
            case 0:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_0, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 1:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_1, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 2:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_2, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 3:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_3, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 4:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_4, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 5:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_5, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 6:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_6, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 7:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_7, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 8:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_8, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 9:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_9, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 10:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_10, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 11:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_11, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 12:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_12, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 13:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_13, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 14:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_14, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 15:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_15, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 16:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_16, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 17:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_17, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 18:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_18, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 19:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_19, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 20:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_20, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 21:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_21, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 22:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_22, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 23:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_23, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 24:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_24, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 25:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_25, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 26:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_26, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 27:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_27, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 28:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_28, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 29:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_29, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            case 30:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_30, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);break
            default:return
        }
    }
    /// 获取关联对象中的AnyObject
    public func getAnyObjectAssociatedObject(_ target:AnyObject?,_ index:Int) -> Any!{
        switch(index){
            case 0:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_0)
            case 1:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_1)
            case 2:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_2)
            case 3:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_3)
            case 4:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_4)
            case 5:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_5)
            case 6:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_6)
            case 7:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_7)
            case 8:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_8)
            case 9:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_9)
            case 10:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_10)
            case 11:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_11)
            case 12:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_12)
            case 13:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_13)
            case 14:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_14)
            case 15:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_15)
            case 16:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_16)
            case 17:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_17)
            case 18:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_18)
            case 19:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_19)
            case 20:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_20)
            case 21:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_21)
            case 22:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_22)
            case 23:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_23)
            case 24:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_24)
            case 25:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_25)
            case 26:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_26)
            case 27:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_27)
            case 28:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_28)
            case 29:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_29)
            case 30:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_OBJECT_30)
            default:return nil
        }
    }
    /// 设置Number关联到对象中
    public func setNumberAssociatedObject(_ target:AnyObject?,_ value:NSNumber?,_ index:Int){
        switch(index){
            case 0:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_0, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 1:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_1, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 2:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_2, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 3:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_3, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 4:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_4, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 5:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_5, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 6:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_6, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 7:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_7, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 8:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_8, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 9:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_9, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 10:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_10, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 11:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_11, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 12:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_12, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 13:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_13, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 14:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_14, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 15:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_15, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 16:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_16, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 17:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_17, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 18:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_18, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 19:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_19, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 20:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_20, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 21:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_21, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 22:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_22, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 23:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_23, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 24:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_24, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 25:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_25, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 26:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_26, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 27:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_27, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 28:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_28, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 29:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_29, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 30:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_30, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            default:return
        }
    }
    /// 获取关联对象中的Number
    public func getNumberAssociatedObject(_ target:AnyObject?,_ index:Int) -> NSNumber?{
        switch(index){
            case 0:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_0) as? NSNumber
            case 1:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_1) as? NSNumber
            case 2:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_2) as? NSNumber
            case 3:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_3) as? NSNumber
            case 4:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_4) as? NSNumber
            case 5:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_5) as? NSNumber
            case 6:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_6) as? NSNumber
            case 7:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_7) as? NSNumber
            case 8:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_8) as? NSNumber
            case 9:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_9) as? NSNumber
            case 10:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_10) as? NSNumber
            case 11:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_11) as? NSNumber
            case 12:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_12) as? NSNumber
            case 13:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_13) as? NSNumber
            case 14:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_14) as? NSNumber
            case 15:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_15) as? NSNumber
            case 16:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_16) as? NSNumber
            case 17:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_17) as? NSNumber
            case 18:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_18) as? NSNumber
            case 19:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_19) as? NSNumber
            case 20:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_20) as? NSNumber
            case 21:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_21) as? NSNumber
            case 22:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_22) as? NSNumber
            case 23:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_23) as? NSNumber
            case 24:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_24) as? NSNumber
            case 25:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_25) as? NSNumber
            case 26:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_26) as? NSNumber
            case 27:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_27) as? NSNumber
            case 28:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_28) as? NSNumber
            case 29:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_29) as? NSNumber
            case 30:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_NUMBER_30) as? NSNumber
            default: return nil
        }
    }
    /// 设置String关联到对象中
    public func setStringAssociatedObject(_ target:AnyObject?,_ value:String?,_ index:Int){
        switch(index){
            case 0:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_0, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 1:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_1, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 2:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_2, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 3:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_3, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 4:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_4, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 5:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_5, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 6:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_6, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 7:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_7, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 8:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_8, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 9:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_9, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 10:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_10, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 11:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_11, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 12:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_12, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 13:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_13, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 14:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_14, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 15:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_15, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 16:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_16, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 17:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_17, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 18:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_18, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 19:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_19, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 20:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_20, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 21:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_21, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 22:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_22, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 23:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_23, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 24:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_24, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 25:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_25, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 26:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_26, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 27:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_27, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 28:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_28, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 29:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_29, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            case 30:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_30, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);break
            default:return
        }
    }
    /// 获取关联对象中的String
    public func getStringAssociatedObject(_ target:AnyObject?,_ index:Int) -> String?{
        switch(index){
            case 0:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_0) as? String
            case 1:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_1) as? String
            case 2:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_2) as? String
            case 3:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_3) as? String
            case 4:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_4) as? String
            case 5:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_5) as? String
            case 6:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_6) as? String
            case 7:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_7) as? String
            case 8:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_8) as? String
            case 9:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_9) as? String
            case 10:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_10) as? String
            case 11:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_11) as? String
            case 12:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_12) as? String
            case 13:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_13) as? String
            case 14:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_14) as? String
            case 15:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_15) as? String
            case 16:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_16) as? String
            case 17:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_17) as? String
            case 18:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_18) as? String
            case 19:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_19) as? String
            case 20:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_20) as? String
            case 21:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_21) as? String
            case 22:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_22) as? String
            case 23:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_23) as? String
            case 24:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_24) as? String
            case 25:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_25) as? String
            case 26:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_26) as? String
            case 27:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_27) as? String
            case 28:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_28) as? String
            case 29:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_29) as? String
            case 30:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_STRING_30) as? String
            default:return nil
        }
    }
    /// 设置Int关联到对象中
    public func setIntAssociatedObject(_ target:AnyObject?,_ value:Int?,_ index:Int){
        switch(index){
            case 0:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_0, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 1:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_1, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 2:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_2, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 3:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_3, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 4:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_4, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 5:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_5, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 6:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_6, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 7:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_7, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 8:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_8, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 9:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_9, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 10:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_10, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 11:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_11, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 12:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_12, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 13:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_13, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 14:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_14, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 15:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_15, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 16:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_16, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 17:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_17, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 18:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_18, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 19:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_19, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 20:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_20, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 21:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_21, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 22:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_22, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 23:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_23, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 24:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_24, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 25:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_25, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 26:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_26, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 27:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_27, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 28:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_28, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 29:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_29, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            case 30:objc_setAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_30, value!, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);break
            default:return
        }
    }
    /// 获取关联对象中的Int
    public func getIntAssociatedObject(_ target:AnyObject?,_ index:Int) -> Int?{
        switch(index){
            case 0:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_0) as? Int
            case 1:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_1) as? Int
            case 2:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_2) as? Int
            case 3:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_3) as? Int
            case 4:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_4) as? Int
            case 5:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_5) as? Int
            case 6:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_6) as? Int
            case 7:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_7) as? Int
            case 8:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_8) as? Int
            case 9:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_9) as? Int
            case 10:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_10) as? Int
            case 11:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_11) as? Int
            case 12:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_12) as? Int
            case 13:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_13) as? Int
            case 14:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_14) as? Int
            case 15:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_15) as? Int
            case 16:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_16) as? Int
            case 17:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_17) as? Int
            case 18:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_18) as? Int
            case 19:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_19) as? Int
            case 20:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_20) as? Int
            case 21:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_21) as? Int
            case 22:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_22) as? Int
            case 23:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_23) as? Int
            case 24:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_24) as? Int
            case 25:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_25) as? Int
            case 26:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_26) as? Int
            case 27:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_27) as? Int
            case 28:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_28) as? Int
            case 29:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_29) as? Int
            case 30:return objc_getAssociatedObject(target, &UtilAnyObject.POINTER_INDEX_INT_30) as? Int
            default:return nil
        }
    }
    
    // Pointer Key 必须声明为全局变量,唯一引用地址不变[全局属性/静态类内部属性]
    static var POINTER_INDEX_OBJECT_0: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_1: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_2: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_3: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_4: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_5: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_6: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_7: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_8: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_9: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_10: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_11: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_12: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_13: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_14: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_15: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_16: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_17: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_18: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_19: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_20: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_21: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_22: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_23: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_24: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_25: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_26: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_27: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_28: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_29: UnsafePointer<AnyObject>? = nil
    static var POINTER_INDEX_OBJECT_30: UnsafePointer<AnyObject>? = nil
    //
    static var POINTER_INDEX_NUMBER_0: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_1: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_2: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_3: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_4: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_5: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_6: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_7: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_8: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_9: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_10: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_11: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_12: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_13: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_14: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_15: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_16: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_17: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_18: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_19: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_20: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_21: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_22: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_23: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_24: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_25: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_26: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_27: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_28: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_29: UnsafePointer<NSNumber>? = nil
    static var POINTER_INDEX_NUMBER_30: UnsafePointer<NSNumber>? = nil
    //
    static var POINTER_INDEX_STRING_0: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_1: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_2: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_3: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_4: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_5: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_6: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_7: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_8: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_9: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_10: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_11: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_12: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_13: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_14: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_15: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_16: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_17: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_18: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_19: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_20: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_21: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_22: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_23: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_24: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_25: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_26: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_27: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_28: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_29: UnsafePointer<String>? = nil
    static var POINTER_INDEX_STRING_30: UnsafePointer<String>? = nil
    //
    static var POINTER_INDEX_INT_0: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_1: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_2: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_3: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_4: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_5: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_6: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_7: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_8: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_9: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_10: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_11: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_12: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_13: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_14: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_15: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_16: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_17: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_18: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_19: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_20: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_21: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_22: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_23: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_24: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_25: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_26: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_27: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_28: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_29: UnsafePointer<Int>? = nil
    static var POINTER_INDEX_INT_30: UnsafePointer<Int>? = nil
    //
    static var POINTER_GESTURE: UnsafePointer<UITapGestureRecognizer>? = nil
    static var POINTER_NIB_LOADINGVIEW: UnsafePointer<UINib>? = nil
}
/// 扩展
public extension UtilAnyObject{
    /// 根据key获取target绑定的对象,如果为nil则调用构造器创建一个实例
    public class func associated<T: AnyObject>(_ target: AnyObject, key: UnsafePointer<UInt8>, initializer: () -> T) -> T {
        if let v: T = objc_getAssociatedObject(target, key) as? T {
            return v
        }
        
        let v: T = initializer()
        objc_setAssociatedObject(target, key, v, .OBJC_ASSOCIATION_RETAIN)
        return v
    }
    /// 根据key绑定值Value到target中
    public class func associate<T: AnyObject>(_ target: AnyObject, key: UnsafePointer<UInt8>, value: T) {
        objc_setAssociatedObject(target, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    /// 添加属性侦听器 KVC,KVO [NSKeyValueObserving,the property is dynamic.]
    public class func addPropertyObserve(_ target: NSObject,_ observer: NSObject,_ targetPropetyNamePath:String){
        // .new 新值 .old 旧值 .initial 初始化 .prior初始化前值
        // context:地址引用[UnsafeMutableRawPointer?]
        //  private var con = "ObserveValue" 取地址:&con,由地址取取值:let c = UnsafeMutablePointer<String>(context) let s = c.memory // "ObserveValue"]
        target.addObserver(observer, forKeyPath: targetPropetyNamePath, options: [.new,.old,.initial,.prior], context: nil)
        // 属性改变接收器,target必须要重写这个方法接收改变
        // override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
        // 注意:
        // 1.ObjC里面可以通过.赋值,setValue:forKey触发KVO侦听
        // 2.Swift只能通过setValue:forKey触发KVO侦听(KVC编程模式)
        // 3.集合Array,Dictionary,Set:Swift中如果要侦听集合的改变(添加/移除)必须要用dynamic var xxx定义(struct类型)
        // 4.手动发布改变通知必须同时调用:willChangeValueForKey,didChangeValueForKey
        // 5.所有的添加侦听必须要在销毁前移除(不移除侦听会发生崩溃: message was received but not handled)
        // 6.Array:调用setValue:forKeyPath对所有Item都有作用
        // 7.侦听Array里面的属性count: arrayAsyncTask.@count (侦听arrayAsyncTask, 返回count属性值,@:集合的属性,.:调用)
    }
    /// 移除属性侦听器 KVC[ KeyPath:属性 KeyValue:属性值,必须在deinit中移除]
    public class func removePropertyObserver(_ target: NSObject,_ observer: NSObject,_ targetPropetyNamePath:String){
        target.removeObserver(observer, forKeyPath: targetPropetyNamePath)
        //target.removeObserver(observer, forKeyPath: targetPropetyName, context: nil)
    }
    // Accessors, Properties, and Key–Value Coding
    public class func setPropertyValue(_ target:AnyObject?,_ value: Any?, forKey key: String) {
        // 设置value到属性key在target上
        target?.setValue(value, forKey: key) // target必须要有key的属性,不然保存
        //1. If you send valueForKey: to an NSArray, it sends valueForKey: to each of its elements and returns a new array consisting of the results, an elegant shorthand. NSSet behaves similarly.
        //2. NSDictionary implements valueForKey: as an alternative to objectForKey: (useful particularly if you have an NSArray of dictionaries). Similarly, NSMutableDictionary treats setValue:forKey: as a synonym for setObject:forKey:, except that value: can be nil, in which case removeObject:forKey: is called.
        //3. NSSortDescriptor sorts an NSArray by sending valueForKey: to each of its elements. This makes it easy to sort an array of dictionaries on the value of a particular dictionary key, or an array of objects on the value of a particular property.
        //4. NSManagedObject, used in conjunction with Core Data, is guaranteed to be key–value coding compliant for attributes you’ve configured in the entity model. Thus, it’s common to access those attributes with valueForKey: and setValue:forKey:.
        //5. CALayer and CAAnimation permit you to use key–value coding to define and retrieve the values for arbitrary keys, as if they were a kind of dictionary; they are, in effect, key–value coding compliant for every key. This is extremely helpful for attaching identifying and configuration information to an instance of one of these classes. That, in fact, is my own most common way of using key–value coding in Swift.
        //6. KVC and Outlets
        //7. Key Paths [object.property, Dictionary,Array的读取]
        //8. NSObject: 
        //  Creation, destruction, and memory management
        //  Class relationships[such as superclass, isKindOfClass:, and isMemberOfClass:]
        //  Object introspection and comparison[such as respondsToSelector:]
        //  Message response[such as doesNotRecognizeSelector:]
        //  Message sending[For example, performSelector:, performSelector:withObject:afterDelay:]
    }
    func autoreleasepooltest(){
        for i in 0 ..< 100{
            // func 自动包含了autoreleasepool,如果在循环中加载内存很大,可以手动声明使用一个释放池对某段代码库进行自动释放内存
            autoreleasepool {
                for j in 0 ..< 100{
                    // load large image to caculate
                    print("\(i)\(j)")
                }
            }
        }
        // Retain Cycles and Weak References: 
        //  1.weak: (takes advantage of a powerful ARC feature, must be an Optional declared with var)
        //  2.unowned: (An unowned reference is a different kettle of fish, unowned object should be some single object, assigned only once, without which the referrer cannot exist at all. Cocoa’s unowned is potentially dangerous and you need to exercise caution.除非你能确定引用是安全的,否则尽量不要用unowned)
        //  weak常用于delegate引起的循环引用问题: weak var delegate: ColorPickerDelegate?(获取销毁时设置Delegate为nil)
        //      @property(nonatomic, assign, nullable) id<AVSpeechSynthesizerDelegate> delegate; 非ARC情况下
        //      unowned(unsafe) var delegate: AVSpeechSynthesizerDelegate? (assign == unowned 非ARC管理,是unsafe不安全的)
        //1.NSNotificationCenter 典型的非ARC内存管理,注册后必须要移除[如果使用匿名函数处理通知,里面的self必须要使用弱引用]
        //2.NSTimer 启动定时器target为self后必须要invalidated才会deinit,因为定时器会强引用回调 The timer maintains a strong reference to target until it (the timer) is invalidated
        //3.Delegate 在销毁前请调用delegate = nil [声明 weak 除外],不然很容易造成循环引用(特别棘手,很难发现这种循环引用问题),特别是系统类的delegate[Eg:CAAnimation.Delegate]
        //4.这些类NSPointerArray, NSHashTable, and NSMapTable由系统管理内存进行引用,所以尽管用,不会造成循环引用问题
        //5.CFTypeRefs 是C语言的结构体,类似于Obje-c对象
        //  [CGContext[属于伪对象](CGContextRef),CGColorSpace[伪对象](CGColorSpaceRef),CGGradient(CGGradientRef)]
        //  They are all CFTypeRefs. The code is not object- oriented; it is a sequence of calls to global C functions. is pseudo-object
        //  CFTypeRefs 在Obje-C中必须要手动管理内存的引用和释放,在Swift中不需要考虑这些,因为Swift会自动处理这些伪对象的引用
        //6.检测实例内存释放: 重写deinit方法查看是否调用,如果调用则被释放(这是一个古老的检测方法)
        //7.
    }
}
/// 扩展 NSObject
public extension UtilAnyObject{
    /// 获取类的所有Objective-C兼容的属性名称(不兼容Objective-C的属性无法获取, xxx.classForCoder)
    @inline(__always) public class func getClassPropertyNames(clazz:AnyClass)-> [String]?{
        // 根据Objective-C runtime运行时获取所有属性名称
        // using Objective-C runtime functions for introspection:
        // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        var results = [String]()
        var count: UInt32 = 0
        let properties = class_copyPropertyList(clazz, &count)// Objective-C runtime get all property(不安全指针,需要手动释放: UnsafeMutablePointer<objc_property_t?>)
        for i in 0 ..< count{
            let property = properties?[Int(i)]
            if let cname = property_getName(property){ // C property name
                let name = String(cString: cname)// C String to Swift String
                results.append(name)
            }
        }
        // release objc_property_t structs
        free(properties)
        
        return results
    }
    @inline(__always) public class func getClassName(clazz:AnyClass)-> String{
       return NSStringFromClass(clazz)
    }
}


