//
//  XTFSerializerJson.m
//  XiaoTianFramework
//  JSON序列化
//  Created by XiaoTian on 16/6/28.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

#import "XTFSerializerJson.h"
#import "Person.h"

@import ObjectiveC.runtime;

// NSJSONSerialization 系统JSON序列化反序列化[只支持基本类型转化为JSON,以及JSON转化为基本类型,支持基本类型:NSString, NSNumber, NSArray, NSDictionary, or NSNull]
@implementation XTFSerializerJson {
    NSMutableDictionary* cacheClassProperty;
}

- (instancetype) init {
    self = [super init];
    if (self) {
       cacheClassProperty = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) test {
    
//    NSDictionary *registerDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [[NSNumber alloc] initWithInt:25],@"age",
//                                 [[NSNumber alloc] initWithBool:true], @"working",
//                                 [[NSNumber alloc] initWithBool:false], @"param3",
//                                 [[NSNumber alloc] initWithDouble:173.56123419], @"height",
//                                 [[NSNumber alloc] initWithFloat:50.56], @"weight",
//                                 [[NSNumber alloc] initWithLong:12345678901], @"birthday",
//                                 @"小甜甜",@"name",
//                                 @"男", @"sex",
//                                 nil];
//    if ([NSJSONSerialization isValidJSONObject:registerDic]) {
//        NSError *error; // NSJSONWritingPrettyPrinted 格式打印
//        NSData *registerData = [NSJSONSerialization dataWithJSONObject:registerDic options:NSJSONWritingPrettyPrinted error:&error];
//        NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding]);
//    }
    // Object -> Json String
    Dog* dog = [[Dog alloc] init];
    dog.nameXJ = @"D爱心";
    dog.sexXJ = @"faile";
    Person* person = [[Person alloc] init];
    person.nameXJ = @"小天";
    person.sexXJ = @"男";
    person.weightXJ = 56.7;
    person.heightXJ = [[NSDecimalNumber alloc] initWithFloat:175.42321323f];
    person.ageXJ = [[NSNumber alloc] initWithInt:25];
    person.birthdayXJ = [[NSNumber alloc] initWithLong:12309093091];
    person.workingXJ = YES;
    person.dogXJ = dog;
    person.dogsXJ = @[dog,dog,dog,dog];
    person.dogdXJ = @{@"dog1":dog,@"dog2":dog};
    
    NSString * jsonData = [[NSString alloc] initWithData:[self serializing: @[person,person]] encoding:NSUTF8StringEncoding];
    //
    //NSLog(@"Register JSON:%@", jsonData);
    
    [self deSerializing:[jsonData dataUsingEncoding:NSUTF8StringEncoding] clazz:[Person class]];
}
// 序列化[任意对象->JSON序列]
-(NSData *) serializing:(NSObject *) objectData {
    // 使用系统NSJSONSerialization序列化
    // 1.对象的根必须为: NSArray or NSDictionary
    // 2.对象包含的类型必须为: NSString, NSNumber, NSArray, NSDictionary, or NSNull
    // 3.所有dictionary的 keys are NSStrings
    // 4.NSNumbers are not NaN or infinity
    // 抽取对象的所有属性,构造可序列化的NSArray或NSDictionary
    if ([objectData isKindOfClass:[NSArray class]]){
        // 根类为 NSArray
        //[XTFMylog info:@"根类为 NSArray"];
        NSArray* array = (NSArray*) objectData;
        NSMutableArray* root = [[NSMutableArray alloc] init];
        NSEnumerator* ite = [array objectEnumerator];
        id object = nil;
        while (object = [ite nextObject]) {
            [root addObject:[self serializingObject:object]];
        }
        if ([NSJSONSerialization isValidJSONObject:root]) {
            NSError *error; // NSJSONWritingPrettyPrinted 格式化打印
            NSData *registerData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                [XTFMylog info:@"NSJSONSerialization serializing Error.\n%@", error];
            }
            return registerData;
        }
        return nil;
    } else if ([objectData isKindOfClass:[NSDictionary class]]){
        // 根类为 NSDictionary
        //[XTFMylog info:@"根类为 NSDictionary"];
        NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
        NSDictionary* dictionary = (NSDictionary *) objectData;
        NSEnumerator* ite = [dictionary keyEnumerator];
        id key = nil;
        while (key = [ite nextObject]) {
            // Key只为String才添加
            if ([key isKindOfClass:[NSString class]]){
                [root setObject:[self serializingObject:[dictionary objectForKey:key]] forKey:key];
            }
        }
        if ([NSJSONSerialization isValidJSONObject:root]) {
            NSError *error; // NSJSONWritingPrettyPrinted 格式化打印
            NSData *registerData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                [XTFMylog info:@"NSJSONSerialization serializing Error.\n%@", error];
                return nil;
            }
            return registerData;
        }
        return nil;
    } else if ([objectData isKindOfClass:[NSObject class]]){
        // 根类为Object
        //[XTFMylog info:@"根类为 Object"];
        NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([objectData class], &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                // 属性必须以XJ声明结尾
                int propNameLength = strlen(propName);
                if (propNameLength < 2 || !endsWithXJ(propName)) continue;
                const char *propType = getPropertyType(property);
                char* simpleName = (char*) malloc(propNameLength - 1);
                strncpy(simpleName, propName, propNameLength - 2);
                simpleName[propNameLength - 2] = '\0';
                NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                //
                id value = [self serializingObject:[objectData valueForKey:propertyName]];
                if (value) {
                    [root setObject:value forKey:[NSString stringWithCString:simpleName encoding:[NSString defaultCStringEncoding]]];
                }
                //NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                //NSString *propertyType = [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
                //[XTFMylog info:@"%@,%@",propertyName,propertyType];
            }
        }
        free(properties);
        if ([NSJSONSerialization isValidJSONObject:root]) {
            NSError *error; // NSJSONWritingPrettyPrinted 格式化打印
            NSData *registerData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                [XTFMylog info:@"NSJSONSerialization serializing Error.\n%@", error];
                return nil;
            }
            return registerData;
        }
        return nil;
    }
    return nil;
}

// 反序列化[JSON序列->任意对象]
-(id) deSerializing:(NSData *) jsonData clazz:(Class ) clazz{
    NSError *error;
    id rootJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        [XTFMylog info:@"NSJSONSerialization deSerializing Error.\n%@", error];
        return nil;
    }
    if ([rootJson isKindOfClass:[NSArray class]]) {
        //[XTFMylog info:@"根类为 NSArray"];
        NSMutableArray* root = [[NSMutableArray alloc] init];
        NSArray *jsonArray = (NSArray *)rootJson;
        NSEnumerator* ite = [jsonArray objectEnumerator];
        id item = nil;
        while (item = [ite nextObject]){
            if ([item isKindOfClass:[NSDictionary class]]){
                id instance = [self deSerializingObject:item clazz:clazz];
                if (!instance){
                    [root addObject:instance];
                }
            }
        }
        return root;
    } else {
        //[XTFMylog info:@"根类为 NSDictionary"];
        NSDictionary *jsonDictionary = (NSDictionary *)rootJson;
        return [self deSerializingObject:jsonDictionary clazz:clazz];
    }
    return nil;
}
-(id) deSerializing:(NSData *) jsonData{
    NSError *error;
    id rootJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        [XTFMylog info:@"NSJSONSerialization deSerializing Error.\n%@", error];
        return [[NSString alloc] initWithFormat:@"NSJSONSerialization deSerializing Error.\n%@", error];
    }
    return rootJson;
}

// 序列化对象
-(NSObject *) serializingObject :(NSObject *) objectData{
    if (objectData == nil) return nil;
    // 抽取对象的所有属性,构造可序列化的NSArray或NSDictionary
    if ([objectData isKindOfClass:[NSArray class]]){
        // 根类为 NSArray
        NSArray* array = (NSArray *) objectData;
        NSMutableArray* root = [[NSMutableArray alloc] init];
        NSEnumerator* ite = [array objectEnumerator];
        id object = nil;
        while (object = [ite nextObject]) {
            [root addObject:[self serializingObject:object]];
        }
        return root;
    } else if ([objectData isKindOfClass:[NSDictionary class]]){
        // 根类为 NSDictionary
        NSDictionary* dictionary = (NSDictionary *) objectData;
        NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
        NSEnumerator* ite = [dictionary keyEnumerator];
        id key = nil;
        while (key = [ite nextObject]) {
            // Key只为String才添加
            if ([key isKindOfClass:[NSString class]]){
                [root setObject:[self serializingObject:[dictionary objectForKey:key]] forKey:key];
            }
        }
        return root;
    } else if ([objectData isKindOfClass:[NSString class]]){
        // 根类为NSString
        return objectData;
    } else if ([objectData isKindOfClass:[NSNumber class]]){
        // 根类为NSNumber
        return objectData;
    } else if ([objectData isKindOfClass:[NSNull class]]){
        // 根类为NSNull
        return objectData;
    } else if ([objectData isKindOfClass:[NSObject class]]){
        // 根类为Object
        NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
        // Propertys
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([objectData class], &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                // 属性必须以XJ声明结尾
                int propNameLength = strlen(propName);
                if (propNameLength < 2 || !endsWithXJ(propName)) continue;
                const char *propType = getPropertyType(property);
                char* simpleName = (char*) malloc(propNameLength - 1);
                strncpy(simpleName, propName, propNameLength - 2);
                simpleName[propNameLength - 2] = '\0';
                NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                //
                id value = [self serializingObject:[objectData valueForKey:propertyName]];
                if (value) {
                    [root setObject:value forKey:[NSString stringWithCString:simpleName encoding:[NSString defaultCStringEncoding]]];
                }
            }
        }
        free(properties);
        return root;
    }
    return nil;
}

// 反序列化对象
-(id) deSerializingObject:(NSDictionary*) dictionary clazz:(Class) clazz{
    if (dictionary == nil) return nil;
    // NSArray,NSDictionary为Json对应的根类别,直接取消,不能反序列化
    if ([clazz isSubclassOfClass: [NSArray class]]) {
        return nil;
    }
    if ([clazz isSubclassOfClass: [NSDictionary class]]) {
        return nil;
    }
    //
    NSNumber* classHash = [NSNumber numberWithInteger:[clazz hash]];
    NSDictionary* cachePropertys = [cacheClassProperty objectForKey:classHash];
    if (!cachePropertys) {
        NSMutableDictionary* cache = [[NSMutableDictionary alloc] init];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(clazz, &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                // 属性必须以XJ声明结尾
                int propNameLength = strlen(propName);
                if (propNameLength < 2 || !endsWithXJ(propName)) continue;
                const char* propType = getPropertyType(property);
                char* simpleName = (char*) malloc(propNameLength - 1);
                strncpy(simpleName, propName, propNameLength - 2);
                simpleName[propNameLength - 2] = '\0';
                NSString *propertyName = [NSString stringWithCString:simpleName encoding:[NSString defaultCStringEncoding]];
                NSString *propertyType = [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
                //[cache setObject:[NSValue valueWithPointer:propType] forKey:propertyName]; // 缓存地址指针[缓存后指针地址会变]
                [cache setObject:propertyType forKey:propertyName];
            }
        }
        if ([cache count] == 0){
            [XTFMylog info:@"Entity %@ propertys is empty serializing error.", clazz];
            return nil;
        }
        cachePropertys = cache;
        [cacheClassProperty setObject:cache forKey:classHash];
    }
    NSEnumerator* ite = [dictionary keyEnumerator];
    id itemKey = nil;
    id instance = nil;
    while (itemKey = [ite nextObject]){
        if([itemKey isKindOfClass:[NSString class]]){
            NSString* key = (NSString*) itemKey;
            if([[cachePropertys allKeys] containsObject:key]){
                if (instance == nil){
                    instance = [[clazz alloc] init];
                }
                id value = [dictionary objectForKey:itemKey];
                // 实体属性类型
                NSString *propertyType = [cachePropertys objectForKey:itemKey];
                // 缓存NSString
                //[XTFMylog info:@"%@,%@,%@", itemKey, value, propertyType];
                @try {
                    if ([@"NSString" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSNumber" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSMutableString" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSDecimalNumber" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"f" isEqualToString:propertyType]){ // 所有数字基本类型封装为NSNumber
                        [instance setValue:[NSNumber numberWithFloat:[value floatValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"d" isEqualToString:propertyType]){
                        [instance setValue:[NSNumber numberWithInt:[value intValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"B" isEqualToString:propertyType]){
                        [instance setValue:[NSNumber numberWithBool:[value boolValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSArray" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSMutableArray" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else {
                        // 子类是Dictionary单个定义类型对象
                        if([value isKindOfClass:[NSDictionary class]]){
                            Class clazz = NSClassFromString(propertyType);
                            if (clazz != nil){
                                id valueInstance = [self deSerializingObject:value clazz:clazz];
                                if(valueInstance != nil){
                                    // 匹配单个对象
                                    [instance setValue:valueInstance forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                                } else {
                                    // 普通 Dictionary
                                    [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                                }
                            } else {
                                // 其他不能系统实例化的 Dictionary
                                [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                            }
                        }
                        //[XTFMylog info:@"跳过属性设置:%@",itemKey];
                    }
                } @catch(NSException* e){
                    [XTFMylog info:@"尝试设置实体属性值时发生错误.属性名:%@XJ,属性值:%@,属性类型:%@", itemKey, value, propertyType];
                }
                
                // 缓存指针模式
                /*char *propType;
                NSValue* cachePropertysValue = [cachePropertys objectForKey:itemKey];
                [cachePropertysValue getValue:&propType];
                //[XTFMylog info:@"%@,%@,%s", itemKey, value, propType];
                @try {
                    // 实体类型[只支持NSString,NSNumber,NSNull],设置对应的值[Value类型不对应,尝试自动转换类型]
                    if (strcmp("NSString", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("NSNumber", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("NSMutableString", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("NSDecimalNumber", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("f", propType) == 0){
                        //[instance setValue:(float)value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("B", propType) == 0){
                        //[instance setValue: forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("NSArray", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if (strcmp("NSMutableArray", propType) == 0){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else {
                        // 子类是Dictionary单个定义类型对象
                        if([value isKindOfClass:[NSDictionary class]]){
                            NSString *propertyType = [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
                            Class clazz = NSClassFromString(propertyType);
                            if (clazz != nil){
                                id valueInstance = [self deSerializingObject:value clazz:clazz];
                                if(valueInstance != nil){
                                    // 匹配单个对象
                                    [instance setValue:valueInstance forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                                } else {
                                    // 普通 Dictionary
                                    [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                                }
                            } else {
                                // 其他不能系统实例化的 Dictionary
                                [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                            }
                        }
                        //[XTFMylog info:@"跳过属性设置:%@",itemKey];
                    }
                } @catch(NSException* e){
                    [XTFMylog info:@"尝试设置实体属性值时发生错误.属性名:%@XJ,属性值:%@,属性类型:%s", itemKey, value, propType];
                }*/
            }
        }
    }
    return instance;
}

-(id) deSerializingArrayObject:(NSArray *) array clazz:(Class) clazz {
    if (array == nil || [array count] < 1 ) return nil;
    // NSArray,NSDictionary为Json对应的根类别,直接取消,不能反序列化
    if ([clazz isSubclassOfClass: [NSArray class]]) {
        return nil;
    }
    if ([clazz isSubclassOfClass: [NSDictionary class]]) {
        return nil;
    }
    NSMutableArray* arrayResult = [[NSMutableArray alloc] initWithCapacity:[array count]];
    id enumerator = array.objectEnumerator;
    id item = nil;
    while (item = [enumerator nextObject]) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            id instance = [self deSerializingObject:item clazz:clazz];
            if (instance != nil) {
                [arrayResult addObject:instance];
            }
        }
    }
    return arrayResult;
}

// 格式化JSON Data
-(NSData *) formatJSONData:(NSData *) jsonData {
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return [[[NSString alloc] initWithFormat:@"NSJSONSerialization Error.\n%@", error] dataUsingEncoding:NSUTF8StringEncoding];
    }
    id data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return [[[NSString alloc] initWithFormat:@"dataWithJSONObject Error.\n%@", error] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return data;
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
static const int endsWithXJ(const char *str){
    size_t lenstr = strlen(str);
    return strncmp(str + lenstr - 2, "XJ", 2) == 0;
}
@end
