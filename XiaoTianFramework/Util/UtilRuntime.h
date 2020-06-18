//
//  UtilRuntime.h
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//
#include "UtilEnvironment.h"

@interface UtilRuntime : NSObject
+(void) test;

/// Method,交换方法的实现体
+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) originalSelector;

/// Property name list to supper class is NSObject,获取NSObject的对象属性Property Name
+(NSMutableArray<NSString*> *) queryPropertyList: (Class) clazz;
/// Property name list to endWithClazz type,获取NSObject的对象属性,向上迭代到endSupperClazz为止
+(NSMutableArray<NSString*> *) queryPropertyList: (Class) clazz endSupperClazz: (Class) supperClazz;
/// 获取类的实体变量名称Ivar
+(NSMutableArray<NSString*>*)queryIvarList:(Class) clazz;
/// Property Type By Property Name,检索属性类型
+(NSString *) queryPropertyType: (Class) clazz propertyName:(NSString *) propertyName;
/// 获取Protocol接口协议所有方法
+(NSMutableArray<NSString*> *) queryProtocolMethodList:(Protocol*) protocol isInstanceMethod:(BOOL) isInstanceMethod isRequiredMethod:(BOOL)isRequiredMethod;

//
+(Mylog*) testClassMethod:(CGFloat) weight name:(NSString*) name util:(UtilEnvironment*) util frame:(CGRect) frame;
@end
