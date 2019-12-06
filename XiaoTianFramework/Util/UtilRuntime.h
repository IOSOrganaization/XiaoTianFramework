//
//  UtilRuntime.h
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//
#include "Mylog.h"
#include "UtilEnvironment.h"

@interface UtilRuntime : NSObject
+(void) test;
/// Method
+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) originalSelector;

/// Property name list to supper class is NSObject
+(NSMutableArray *) queryPropertyList: (Class) clazz;
/// Property name list to endWithClazz type
+(NSMutableArray *) queryPropertyList: (Class) clazz endSupperClazz: (Class) supperClazz;
/// Property Type By Property Name
+(NSString *) queryPropertyType: (Class) clazz propertyName:(NSString *) propertyName;
///
+(NSMutableArray *) queryProtocolMethodList:(Protocol*) protocol isInstanceMethod:(BOOL) isInstanceMethod isRequiredMethod:(BOOL)isRequiredMethod;

//
+(Mylog*) testClassMethod:(CGFloat) weight name:(NSString*) name util:(UtilEnvironment*) util frame:(CGRect) frame;
@end
