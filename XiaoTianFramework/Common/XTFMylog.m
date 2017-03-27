//
//  XTFMylog.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/25/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

@import ObjectiveC.runtime;

#import "XTFMylog.h"
#define TAG @"[XTF]"

@implementation XTFMylog

// 输出Struct结构体
+(void) infoSCGRect:(CGRect) rect key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@", key != nil ? key : @"CGRect", NSStringFromCGRect(rect));
#endif
}

+(void) infoSCGRect:(CGRect) rect{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSCGRect:rect key:nil];
#endif
}

+(void) infoSCGSize:(CGSize) size key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@", key !=nil ? key : @"CGSize", NSStringFromCGSize(size));
#endif
}


+(void) infoSCGSize:(CGSize) size{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSCGSize: size key:nil];
#endif
}

+(void) infoSCGPoint:(CGPoint) point key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@",key != nil ? key : @"CGPoint", NSStringFromCGPoint(point));
#endif
}

+(void) infoSCGPoint:(CGPoint) point{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSCGPoint:point key:nil];
#endif
}

+(void) infoSCGVector:(CGVector) vector key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@",key != nil ? key : @"CGVector", NSStringFromCGVector(vector));
#endif
}

+(void) infoSCGVector:(CGVector) vector{
    [self infoSCGVector:vector key:nil];
}

+(void) infoSCGAffineTransform:(CGAffineTransform) transform key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@",key != nil ? key : @"CGAffineTransform", NSStringFromCGAffineTransform(transform));
#endif
}

+(void) infoSCGAffineTransform:(CGAffineTransform) transform{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSCGAffineTransform:transform];
#endif
}

+(void) infoSUIEdgeInsets:(UIEdgeInsets) edge key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@",key != nil ? key : @"UIEdgeInsets", NSStringFromUIEdgeInsets(edge));
#endif
}

+(void) infoSUIEdgeInsets:(UIEdgeInsets) edge{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSUIEdgeInsets:edge key:nil];
#endif
}

+(void) infoSUIOffset:(UIOffset) offset key:(NSString*) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@:%@",key != nil ? key : @"UIOffset", NSStringFromUIOffset(offset));
#endif
}

+(void) infoSUIOffset:(UIOffset) offset{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoSUIOffset:offset key:nil];
#endif
}

+(void) infoDate{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoDate:nil];
#endif
}

+(void) infoDate:(NSString *) key{
#if defined(DEBUG)||defined(_DEBUG)
    NSDate* currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if(key == nil){
        NSLog(@"%@",[dateFormatter stringFromDate:currentDate]);
    }else{
        NSLog(@"%@:%@",key,[dateFormatter stringFromDate:currentDate]);
    }
#endif
}

+(void) info:(id) message, ...{
#if defined(DEBUG)||defined(_DEBUG)
    if(message == nil){
        [self info:@"nil"];
        return;
    }
    va_list ap;
    va_start (ap, message);
    if([message isKindOfClass: [NSString class]]){
        // 字符串
        NSLogv([NSString stringWithFormat:@"%@:%@", TAG, message], ap);
    }else if([message isKindOfClass: [NSArray class]]){
        // 数组
        NSLog(@"%@:NSArray : {", TAG);
        NSArray *array = (NSArray *)message;
        for (int i=0; i < [array count]; i++) {
            NSObject *obj = [array objectAtIndex: i];
            [self info: obj];
        }
        NSLog(@"%@:}", TAG);
    }else if([message isKindOfClass:[NSDictionary class]]){
        // Dictionary字典集合
        NSLog(@"%@:NSDictionary : {", TAG);
        NSDictionary *dictionary = (NSDictionary *)message;
        NSEnumerator *enumerator = [dictionary keyEnumerator];
        id key, value;
        while ((key = [enumerator nextObject])) {
            value = [dictionary objectForKey: key];
            NSLog(@"%@:%@ = %@", TAG, key, value);
        }
        NSLog(@"%@:}", TAG);
    }else{
        NSLogv([NSString stringWithFormat:@"%@:%@", TAG, message], ap);
    }
    //NSLogv([NSString stringWithFormat:@"%@ %@", TAG, message], ap);
    //NSString *msg = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
#endif
}

+(void) infoBool:(BOOL) value key:(NSString *)key{
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"%@: %@", key, value ? @"YES" : @"NO");
#endif
}

+(void) infoBool:(BOOL) value{
#if defined(DEBUG)||defined(_DEBUG)
    [self infoBool:value key:@"BOOL"];
#endif
}

// 必须传入Object-C 的id
+(void) infoClassField: (id<NSObject>) message{
#if defined(DEBUG)||defined(_DEBUG)
    if(message == nil){
        NSLog(@"%@:nil", TAG);
        return;
    }
    Class messageClass = [message class];
    if (class_isMetaClass(messageClass)) {
        NSLog(@"%@:%@", TAG, message);
        return;
    }
    NSMutableArray *arrayClassName = [[NSMutableArray alloc] initWithCapacity: 5];
    NSMutableDictionary *dictionaryProperties = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dictionaryVariables = [[NSMutableDictionary alloc] init];
    const char *className, *propertyName, *propertyAttributes, *variableName, *variableType; // UTF-8 Char
    unsigned int propertiesCount, i, variableCount;
    id variableValue;
    while(messageClass != nil){
        className = class_getName(messageClass);
        [arrayClassName addObject: [NSString stringWithUTF8String: className]];
        // 接口开放属性
        objc_property_t *properties =  class_copyPropertyList(messageClass, &propertiesCount); // 获取接口Protocol开放属性
        for (i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            propertyName = property_getName(property); // 属性名称
            propertyAttributes = property_getAttributes(property); // 属性参数描述
            // 添加属性
            [dictionaryProperties setObject:[NSString stringWithUTF8String:propertyAttributes]
                                     forKey:[NSString stringWithUTF8String:propertyName]];
        }
        // 实体的变量[属性连接到的变量和变量值]
        Ivar * ivars = class_copyIvarList(messageClass, &variableCount);
        for (i = 0; i < variableCount; i++) {
            // C
            Ivar ivar = ivars[i];
            if(ivar == NULL) continue;
            variableName = ivar_getName(ivar);
            if(variableName == nil) continue;
            NSString *variableNameNS = [NSString stringWithUTF8String:variableName];
            variableType = ivar_getTypeEncoding(ivar);
            NSString *type =  [NSString stringWithCString:variableType encoding:NSUTF8StringEncoding];/*Object-C类型声明*/
            //NSLog(@"%@->%@",variableNameNS,type);
            //NSLog(@"%@",[NSString stringWithUTF8String:@encode(id)]);
            if(strcmp(ivar_getTypeEncoding(ivar), @encode(id)) == 0){
                // Object-C 对象类型,whether statically typed or typed id
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strchr(ivar_getTypeEncoding(ivar), '@') != NULL){
                // Object-C 对象类型,whether statically typed or typed id
                //NSLog(@"Object-C 对象类型,whether statically typed or typed id");
                variableValue = object_getIvar(message, ivar); // 获取Object-C对象类型值,返回id,非Object-C类型报错
                if(variableValue == nil) variableValue = @"nil";
                [dictionaryVariables setObject:variableValue forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(int)) == 0){
                // int
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(long)) == 0){
                // long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(float)) == 0){
                // float
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(double)) == 0){
                // double
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(bool)) == 0){
                // bool
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(char*)) == 0){
                // char *
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(Class)) == 0){
                // Class
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(void)) == 0){
                // void
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(SEL)) == 0){
                // SEL
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(char)) == 0){
                // char
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(short)) == 0){
                // short
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(long long)) == 0){
                // long long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned char)) == 0){
                // unsigned char
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned int)) == 0){
                // unsigned int
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned long)) == 0){
                // unsigned long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned long long)) == 0){
                // unsigned long long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if([type isEqualToString:@"^type"]){
                // pointer
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if ([type hasPrefix:@"b"]){
                // bit field of num bits
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if ([type isEqualToString:@"?"]){
                // unknow
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else{
                // error
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
                continue;
            }
        }
        messageClass = class_getSuperclass(messageClass);
        if([[NSObject class] isSubclassOfClass: messageClass]) break;
    }
    NSMutableString *values = [[NSMutableString alloc] initWithCapacity: 100];
    id key, value;
    NSEnumerator *enumerator;
    // 输出类名
    for(int i = 0;i < [arrayClassName count];i++){
        value = [arrayClassName objectAtIndex:i];
        [values appendString:value];
        if(i+1 < [arrayClassName count]) [values appendString:@"->"];
    }
    NSLog(@"%@:%@ : %@", TAG, values, @"{");
    // 输出类开放属性
    enumerator = [dictionaryProperties keyEnumerator];
    while(key = [enumerator nextObject]){
        value = [dictionaryProperties objectForKey:key];
        NSLog(@"%@:%@[%@]", TAG, key, value);
    }
    NSLog(@"%@:-----------------------------", TAG);
    // 输出类变量
    enumerator = [dictionaryVariables keyEnumerator];
    while(key = [enumerator nextObject]){
        value = [dictionaryVariables objectForKey:key];
        NSLog(@"%@:%@ = %@", TAG, key, value);
    }
    NSLog(@"%@:}", TAG);
#endif
}

+(void) infoClassProperty: (id) message{
#if defined(DEBUG)||defined(_DEBUG)
    Class messageClass = [message class];
    if (class_isMetaClass(messageClass)) {
        NSLog(@"%@:%@", TAG, message);
        return;
    }
    NSMutableArray *arrayClassName = [[NSMutableArray alloc] initWithCapacity: 5];
    NSMutableDictionary *dictionaryProperties = [[NSMutableDictionary alloc] init];
    const char *className, *propertyName, *propertyAttributes; // UTF-8 Char
    unsigned int propertiesCount, i;
    while(messageClass != nil){
        className = class_getName(messageClass);
        [arrayClassName addObject: [NSString stringWithUTF8String: className]];
        // 接口开放属性
        objc_property_t *properties =  class_copyPropertyList(messageClass, &propertiesCount); // 获取接口Protocol开放属性
        for (i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            propertyName = property_getName(property); // 属性名称
            propertyAttributes = property_getAttributes(property); // 属性参数描述
            // 添加属性
            [dictionaryProperties setObject:[NSString stringWithUTF8String:propertyAttributes]
                                     forKey:[NSString stringWithUTF8String:propertyName]];
        }
        messageClass = class_getSuperclass(messageClass);
        if([[NSObject class] isSubclassOfClass: messageClass]) break;
    }
    NSMutableString *values = [[NSMutableString alloc] initWithCapacity: 100];
    id key, value;
    NSEnumerator *enumerator;
    // 输出类名
    for(int i = 0;i < [arrayClassName count];i++){
        value = [arrayClassName objectAtIndex:i];
        [values appendString:value];
        if(i+1 < [arrayClassName count]) [values appendString:@"->"];
    }
    NSLog(@"%@:%@", values, @"{");
    // 输出类开放属性
    enumerator = [dictionaryProperties keyEnumerator];
    while(key = [enumerator nextObject]){
        value = [dictionaryProperties objectForKey:key];
        NSLog(@"%@[%@]", key, value);
    }
    NSLog(@"}");
#endif
}

+(void) infoClassVariable: (id) message{
#if defined(DEBUG)||defined(_DEBUG)
    Class messageClass = [message class];
    if (class_isMetaClass(messageClass)) {
        NSLog(@"%@:%@", TAG, message);
        return;
    }
    NSMutableArray *arrayClassName = [[NSMutableArray alloc] initWithCapacity: 5];
    NSMutableDictionary *dictionaryVariables = [[NSMutableDictionary alloc] init];
    const char *className, *variableName, *variableType; // UTF-8 Char
    unsigned int i, variableCount;
    id variableValue;
    while(messageClass != nil){
        className = class_getName(messageClass);
        [arrayClassName addObject: [NSString stringWithUTF8String: className]];
        // 实体的变量[属性连接到的变量和变量值]
        Ivar * ivars = class_copyIvarList(messageClass, &variableCount);
        for (i = 0; i < variableCount; i++) {
            // C
            Ivar ivar = ivars[i];
            if(ivar == NULL) continue;
            variableName = ivar_getName(ivar);
            if(variableName == nil) continue;
            NSString *variableNameNS = [NSString stringWithUTF8String:variableName];
            variableType = ivar_getTypeEncoding(ivar);
            NSString *type =  [NSString stringWithCString:variableType encoding:NSUTF8StringEncoding];/*Object-C类型声明*/
            //NSLog(@"%@->%@",variableNameNS,type);
            //NSLog(@"%@",[NSString stringWithUTF8String:@encode(id)]);
            if(strcmp(ivar_getTypeEncoding(ivar), @encode(id)) == 0){
                // Object-C 对象类型,whether statically typed or typed id
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strchr(ivar_getTypeEncoding(ivar), '@') != NULL){
                // Object-C 对象类型,whether statically typed or typed id
                //NSLog(@"Object-C 对象类型,whether statically typed or typed id");
                variableValue = object_getIvar(message, ivar); // 获取Object-C对象类型值,返回id,非Object-C类型报错
                if(variableValue == nil) variableValue = @"nil";
                [dictionaryVariables setObject:variableValue forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(int)) == 0){
                // int
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(long)) == 0){
                // long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(float)) == 0){
                // float
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(double)) == 0){
                // double
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(bool)) == 0){
                // bool
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(char*)) == 0){
                // char *
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if(strcmp(ivar_getTypeEncoding(ivar), @encode(Class)) == 0){
                // Class
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(void)) == 0){
                // void
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(SEL)) == 0){
                // SEL
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(char)) == 0){
                // char
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(short)) == 0){
                // short
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(long long)) == 0){
                // long long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned char)) == 0){
                // unsigned char
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned int)) == 0){
                // unsigned int
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned long)) == 0){
                // unsigned long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if (strcmp(ivar_getTypeEncoding(ivar), @encode(unsigned long long)) == 0){
                // unsigned long long
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if([type isEqualToString:@"^type"]){
                // pointer
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if ([type hasPrefix:@"b"]){
                // bit field of num bits
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else if ([type isEqualToString:@"?"]){
                // unknow
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
            }else{
                // error
                [dictionaryVariables setObject:@"(unknowvaluetype)" forKey:variableNameNS];
                continue;
            }
        }
        messageClass = class_getSuperclass(messageClass);
        if([[NSObject class] isSubclassOfClass: messageClass]) break;
    }
    NSMutableString *values = [[NSMutableString alloc] initWithCapacity: 100];
    id key, value;
    NSEnumerator *enumerator;
    // 输出类名
    for(int i = 0;i < [arrayClassName count];i++){
        value = [arrayClassName objectAtIndex:i];
        [values appendString:value];
        if(i+1 < [arrayClassName count]) [values appendString:@"->"];
    }
    NSLog(@"%@:%@", values, @"{");
    // 输出类变量
    enumerator = [dictionaryVariables keyEnumerator];
    while(key = [enumerator nextObject]){
        value = [dictionaryVariables objectForKey:key];
        NSLog(@"%@:%@ = %@", TAG, key, value);
    }
    NSLog(@"}");
#endif
}

+(void) infoBundleAllFiles{
#if defined(DEBUG)||defined(_DEBUG)
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *paths = [bundle pathsForResourcesOfType:nil inDirectory:nil];
    for (int i=0; i < paths.count; i++) {
        NSString *path = paths[i];
        NSArray *pathComponents = [path pathComponents];
        [self info:pathComponents[pathComponents.count - 1]];
    }
#endif
}

+(void) infoBundleAllFiles:(NSString *)extends{
#if defined(DEBUG)||defined(_DEBUG)
    if(extends == nil){
        [self infoBundleAllFiles];
        return;
    }
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *paths = [bundle pathsForResourcesOfType:nil inDirectory:nil];
    for (int i=0; i < paths.count; i++) {
        NSString *path = paths[i];
        NSArray *pathComponents = [path pathComponents];
        if([extends caseInsensitiveCompare:[path pathExtension]] == NSOrderedSame){
            [self info:pathComponents[pathComponents.count - 1]];
        }
    }
#endif
}

+(void) infoBundleAllFolder{
#if defined(DEBUG)||defined(_DEBUG)
    BOOL isDirectory;
    NSBundle *bundle = [NSBundle mainBundle];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [bundle pathsForResourcesOfType:nil inDirectory:nil];
    for (int i=0; i < paths.count; i++) {
        NSString *path = paths[i];
        if([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory){
            NSArray *pathComponents = [path pathComponents];
            [self info:pathComponents[pathComponents.count - 1]];
        }
    }
#endif
}

-(NSString *) description{
#if defined(DEBUG)||defined(_DEBUG)
    return @"小天的自定义Log对象类,没有什么好怀念的类了.";
#endif
    return [super description];
}
/* Object-C Running Time: O-C运行时,必须引入运行时库 libobjc.A.dylib [OC语法]
 # 类操作
 class_getName
 class_getSuperclass
 class_setSuperclass  (iOS 2.0)
 class_isMetaClass
 class_getInstanceSize
 class_getInstanceVariable
 class_getClassVariable
 class_addIvar
 class_copyIvarList
 class_getIvarLayout
 class_setIvarLayout
 class_getWeakIvarLayout
 class_setWeakIvarLayout
 class_getProperty
 class_copyPropertyList
 class_addMethod
 class_getInstanceMethod
 class_getClassMethod
 class_copyMethodList
 class_replaceMethod
 class_getMethodImplementation
 class_getMethodImplementation_stret
 class_respondsToSelector
 class_addProtocol
 class_addProperty
 class_replaceProperty
 class_conformsToProtocol
 class_copyProtocolList
 class_getVersion
 class_setVersion
 objc_getFutureClass
 objc_setFutureClass
 # 类实例化操作
 objc_allocateClassPair
 objc_disposeClassPair
 objc_registerClassPair
 objc_duplicateClass
 # 实体类操作
 class_createInstance
 objc_constructInstance
 objc_destructInstance
 # 实体类方法
 object_copy
 object_dispose
 object_setInstanceVariable
 object_getInstanceVariable
 object_getIndexedIvars
 object_getIvar
 object_setIvar
 object_getClassName
 object_getClass
 object_setClass
 # 类定义获取
 objc_getClassList
 objc_copyClassList
 objc_lookUpClass
 objc_getClass
 objc_getRequiredClass
 objc_getMetaClass
 # 实体变量方法
 ivar_getName
 ivar_getTypeEncoding
 ivar_getOffset
 # 关联引用
 objc_setAssociatedObject
 objc_getAssociatedObject
 objc_removeAssociatedObjects
 # 方法反射回调[方法定义在objc-runtime.h头中]
 objc_msgSend
 objc_msgSend_stret
 objc_msgSendSuper
 objc_msgSendSuper_stret
 # 方法回调方法
 method_invoke
 method_invoke_stret
 method_getName
 method_getImplementation
 method_getTypeEncoding
 method_copyReturnType
 method_copyArgumentType
 method_getReturnType
 method_getNumberOfArguments
 method_getArgumentType
 method_getDescription
 method_setImplementation
 method_exchangeImplementations
 # 类库方法
 objc_copyImageNames
 class_getImageName
 objc_copyClassNamesForImage
 # 选择器方法
 sel_getName
 sel_registerName
 sel_getUid
 sel_isEqual
 # 接口协议方法
 objc_getProtocol
 objc_copyProtocolList
 objc_allocateProtocol
 objc_registerProtocol
 protocol_addMethodDescription
 protocol_addProtocol
 protocol_addProperty
 protocol_getName
 protocol_isEqual
 protocol_copyMethodDescriptionList
 protocol_getMethodDescription
 protocol_copyPropertyList
 protocol_getProperty
 protocol_copyProtocolList
 protocol_conformsToProtocol
 # 属性方法
 property_getName
 property_getAttributes
 property_copyAttributeValue
 property_copyAttributeList
 # Object-C 语言特性
 objc_enumerationMutation
 objc_setEnumerationMutationHandler
 imp_implementationWithBlock
 imp_getBlock
 imp_removeBlock
 objc_loadWeak
 objc_storeWeak
 
 类结构体数据的定义说明:
 1.Class :泛类定义
 2.Method :泛方法定义
 3.Ivar :实体泛变量定义
 4.Category :泛接口定义 An opaque type that represents a category.
 5.objc_property_t :Object-C泛属性定义 An opaque type that represents an Objective-C declared property.
 6.IMP :实现方法入口 A pointer to the start of a method implementation.
 7.SEL :泛方法选择器C语言 Defines an opaque type that represents a method selector
 8.objc_method_description :Object-C泛方法 Defines an Objective-C method
 9.objc_cache :最近以缓冲方法 Performance optimization for method calls. Contains pointers to recently used methods
 10.objc_property_attribute_t :泛属性 Defines a property attribute
 
 实体数据类型说明
 1.id :实体地址,pointer to an instance of a class.
 2.objc_object :实体引用,represents an instance of a class.
 3.objc_super :实体父类,specifies the superclass of an instance
 
 引用数据类型说明
 1.BOOL :布尔值类型[YES:1,NO:0]
 2.objc_AssociationPolicy :联合引用类型
 
 Object-C数据类型
 c :A char
 i :An int
 s :A short
 l :A long l is treated as a 32-bit quantity on 64-bit programs.
 q :A long long
 C :An unsigned char
 I :An unsigned int
 S :An unsigned short
 L :An unsigned long
 Q :An unsigned long long
 f :A float
 d :A double
 B :A C++ bool or a C99 _Bool
 v :A void
 * :A character string (char *)
 @ :An object (whether statically typed or typed id)
 # :A class object (Class)
 : :A method selector (SEL)
 [array type] :An array
 {name=type...} :A structure
 (name=type...) :A union
 bnum :A bit field of num bits
 ^type :A pointer to type
 ? :An unknown type (among other things, this code is used for function pointers)
 */
@end
