//
//  UtilRuntime.m
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

#import "XTFUtilRuntime.h"
@import ObjectiveC.runtime;

@implementation XTFUtilRuntime

// 交换方法的实现体
+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) swizzledSelector{
    struct objc_method* originalMethod = class_getInstanceMethod(clazz, originalSelector);
    struct objc_method* swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    // 添加自定义的方法到指定的类里面,如果添加成功则返回true,否则false[已经存在]
    BOOL didAddMethod = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        // 添加成功,替换原方法
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        // 交换两个方法的实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// 获取NSObject的对象属性Property Name
+(NSMutableArray *) queryPropertyList: (Class) clazz{
    return [XTFUtilRuntime queryPropertyList:clazz endSupperClazz:nil];
}
+(NSMutableArray *) queryPropertyList: (Class) clazz endSupperClazz: (Class) supperClazz {
    if (!clazz) return nil;
    NSMutableArray* propertyList = [[NSMutableArray alloc] init];
    unsigned int outCount, i;
    do{
        if (clazz && supperClazz && clazz == supperClazz) {
            clazz = nil;
        }else{
            objc_property_t *properties = class_copyPropertyList(clazz, &outCount);
            for(i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                const char *propName = property_getName(property);
                if(propName) {
                    size_t propNameLength = strlen(propName);
                    if (propNameLength < 1) continue;
                    //const char *propType = getPropertyType(property);
                    char* simpleName = (char*) malloc(propNameLength + 1);
                    strncpy(simpleName, propName, propNameLength);
                    simpleName[propNameLength] = '\0';
                    NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                    if (propertyName && ![propertyList containsObject:propertyName]){
                        [propertyList addObject:propertyName];
                    }
                }
            }
            free(properties);
            clazz = [self superclass];
        }
    }while (clazz);
    return propertyList;
}
//
+(NSString *) queryPropertyType: (Class) clazz propertyName:(NSString *) propertyName{
    const char* propType = getPropertyType(class_getProperty(clazz, [propertyName cStringUsingEncoding:NSASCIIStringEncoding]));
    return [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //[XTFMylog info:@"Attributes=%s\n", attributes];
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) { // T@""
                if (strlen(attribute) > 1){
                    // Tf,N,V_workingXJ
                    return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
                }
                break;
            }
            // T@"NSString",&,N,V_sexXJ
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}
@end
