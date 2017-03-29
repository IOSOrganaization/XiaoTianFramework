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
    // 定义索引
    static let INDEX_OBJECT_VALUE = 30//用于对象值
    static let INDEX_OBJECT_HOLDER = 29//用于对象视图缓存
    static let INDEX_INT_POSITION = 30//用于Int位置

    /// 关联对象到指定对象
    func setAssociatedObject(target:AnyObject?,_ value:AnyObject?,_ bindkey: UnsafePointer<Void>){
        if target == nil || value == nil{
            return
        }
        objc_setAssociatedObject(self, bindkey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /// 获取对象中关联的对象
    func getAssociatedObject(target:AnyObject?,_ bindkey: UnsafePointer<Void>) -> AnyObject!{
        if target == nil{
            return nil
        }
        return objc_getAssociatedObject(self, bindkey)
    }
    
    // ********************************** 绑定强引用属性 **********************************
    /// 通过索引关联对象到指定对象
    func bingAnyObject(target:AnyObject?,_ value:AnyObject?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setAnyObjectAssociatedObject(target, value, index)
    }
    /// 通过索引获取指定对象的关联对象
    func accessAnyObject(target:AnyObject?,_ index:Int) -> AnyObject!{
        if target == nil{
            return nil
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        return getAnyObjectAssociatedObject(target, index)
    }
    /// 绑定Int
    func bingInt(target:AnyObject?,_ value:Int?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setIntAssociatedObject(target, value, index)
    }
    /// 获取绑定Int
    func accessInt(target:AnyObject?,_ index:Int) -> Int!{
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
    func bingString(target:AnyObject?,_ value:String?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setStringAssociatedObject(target, value, index)
    }
    /// 获取绑定String
    func accessString(target:AnyObject?,_ index:Int) -> String!{
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
    func bindNumber(target:AnyObject?,_ value:NSNumber?,_ index:Int){
        if target == nil || value == nil{
            return
        }
        if index < 0 || index > 30{
            fatalError("Index must in 0~30.")
        }
        setNumberAssociatedObject(target, value, index)
    }
    /// 获取关联对象中的number
    func accessNumber(target:AnyObject?,_ index:Int) -> NSNumber!{
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
    func setAnyObjectAssociatedObject(target:AnyObject?,_ value:AnyObject?,_ index:Int){
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
    func getAnyObjectAssociatedObject(target:AnyObject?,_ index:Int) -> AnyObject?{
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
    func setNumberAssociatedObject(target:AnyObject?,_ value:NSNumber?,_ index:Int){
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
    func getNumberAssociatedObject(target:AnyObject?,_ index:Int) -> NSNumber?{
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
    func setStringAssociatedObject(target:AnyObject?,_ value:String?,_ index:Int){
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
    func getStringAssociatedObject(target:AnyObject?,_ index:Int) -> String?{
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
    func setIntAssociatedObject(target:AnyObject?,_ value:Int?,_ index:Int){
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
    func getIntAssociatedObject(target:AnyObject?,_ index:Int) -> Int?{
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
    static var POINTER_INDEX_OBJECT_0: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_1: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_2: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_3: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_4: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_5: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_6: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_7: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_8: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_9: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_10: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_11: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_12: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_13: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_14: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_15: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_16: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_17: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_18: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_19: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_20: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_21: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_22: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_23: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_24: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_25: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_26: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_27: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_28: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_29: UnsafePointer<AnyObject> = nil
    static var POINTER_INDEX_OBJECT_30: UnsafePointer<AnyObject> = nil
    //
    static var POINTER_INDEX_NUMBER_0: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_1: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_2: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_3: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_4: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_5: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_6: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_7: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_8: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_9: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_10: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_11: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_12: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_13: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_14: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_15: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_16: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_17: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_18: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_19: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_20: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_21: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_22: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_23: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_24: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_25: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_26: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_27: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_28: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_29: UnsafePointer<NSNumber> = nil
    static var POINTER_INDEX_NUMBER_30: UnsafePointer<NSNumber> = nil
    //
    static var POINTER_INDEX_STRING_0: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_1: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_2: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_3: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_4: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_5: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_6: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_7: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_8: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_9: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_10: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_11: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_12: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_13: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_14: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_15: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_16: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_17: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_18: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_19: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_20: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_21: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_22: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_23: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_24: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_25: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_26: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_27: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_28: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_29: UnsafePointer<String> = nil
    static var POINTER_INDEX_STRING_30: UnsafePointer<String> = nil
    //
    static var POINTER_INDEX_INT_0: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_1: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_2: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_3: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_4: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_5: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_6: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_7: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_8: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_9: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_10: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_11: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_12: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_13: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_14: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_15: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_16: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_17: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_18: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_19: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_20: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_21: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_22: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_23: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_24: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_25: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_26: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_27: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_28: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_29: UnsafePointer<Int> = nil
    static var POINTER_INDEX_INT_30: UnsafePointer<Int> = nil
    //
    static var POINTER_GESTURE: UnsafePointer<UITapGestureRecognizer> = nil
    static var POINTER_NIB_LOADINGVIEW: UnsafePointer<UINib> = nil
}
/// 扩展
public extension UtilAnyObject{
    /// 根据key获取target绑定的对象,如果为nil则调用构造器创建一个实例
    public class func associated<T: AnyObject>(target: AnyObject, key: UnsafePointer<UInt8>, initializer: () -> T) -> T {
        if let v: T = objc_getAssociatedObject(target, key) as? T {
            return v
        }
        
        let v: T = initializer()
        objc_setAssociatedObject(target, key, v, .OBJC_ASSOCIATION_RETAIN)
        return v
    }
    /// 根据key绑定值Value到target中
    public class func associate<T: AnyObject>(target: AnyObject, key: UnsafePointer<UInt8>, value: T) {
        objc_setAssociatedObject(target, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
}