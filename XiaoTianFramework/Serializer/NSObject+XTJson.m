//
//  NSObject+XTJson.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 2016/12/5.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import "NSObject+XTJson.h"
#import "ConstantsXT.h"
@import CoreData;

// 宏定义
#define XTJsonSemaphoreCreate \
static dispatch_semaphore_t signalSemaphore; \
static dispatch_once_t onceTokenSemaphore; \
dispatch_once(&onceTokenSemaphore, ^{ \
    signalSemaphore = dispatch_semaphore_create(1); \
});
#define XTJsonSemaphoreWait \
dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);
#define XTJsonSemaphoreSignal \
dispatch_semaphore_signal(signalSemaphore);

#pragma mark OC数据类型名称(支持KVO的类型:非KVO不支持自动序列化)
#define XTJPropertyTypeInt @"i"
#define XTJPropertyTypeShort @"s"
#define XTJPropertyTypeFloat @"f"
#define XTJPropertyTypeDouble @"d"
#define XTJPropertyTypeLong @"l"
#define XTJPropertyTypeLongLong @"q"
#define XTJPropertyTypeChar @"c"
#define XTJPropertyTypeBOOL1 @"c"
#define XTJPropertyTypeBOOL2 @"b"
#define XTJPropertyTypePointer @"*"

#define XTJPropertyTypeIvar @"^{objc_ivar=}"
#define XTJPropertyTypeMethod @"^{objc_method=}"
#define XTJPropertyTypeBlock @"@?"
#define XTJPropertyTypeClass @"#"
#define XTJPropertyTypeSEL @":"
#define XTJPropertyTypeId @"@"

// Block
typedef void (^XTJClassesEnumeration)(Class c, BOOL *stop);//遍历成员类
typedef void (^XTJPropertyEnumeration)(XTProperty* property, BOOL *stop);//遍历属性
//
@implementation NSObject(XTJson)
// 这个数组中的属性名才会进行字典和模型的转换
#pragma mark 序列化/反序列化
+(id)deSerializing:(id) data{
    id rootJson = [self jsonObject:data];//
    if ([rootJson isKindOfClass:[NSArray class]]) {
        //[Mylog infoTag:@"XTJson",@"根类为 NSArray"];
        return [self deSerializingArray:(NSArray *)rootJson];
    } else if([rootJson isKindOfClass:[NSDictionary class]]){
        //[Mylog infoTag:@"XTJson",@"根类为 NSDictionary"];
        return [self deSerializingDictionary:(NSDictionary *)rootJson];
    }
    return nil;
}
+(instancetype)deSerializingDictionary:(NSDictionary*)dic{
    return [[[self alloc] init] deSerializingObject:dic];
}
+(NSMutableArray<id>*)deSerializingArray:(NSArray*)array{
    NSMutableArray* root = [[NSMutableArray alloc] init];
    NSEnumerator* ite = [array objectEnumerator];
    id item = nil;
    while (item = [ite nextObject]){
        if ([item isKindOfClass:[NSDictionary class]]){
            id instance = [[[self alloc] init] deSerializingObject:item];
            if (instance) [root addObject:instance];
        }else if([item isKindOfClass:[NSArray class]]){
            id instance = [self deSerializingArray:item];
            if (instance) [root addObject:instance];
        }
    }
    return root;
}
-(NSString*)serializing{
    return [self.class jsonString:self];
}
-(NSDictionary*)serializingToDic{
    return [self serializingObject:self];
}
#pragma mark - 实体序列化/反序列化
// 实体->NSDictionary / 基本类型->值
-(id)serializingObject:(id)data{
    Class clazz = [data class];
    if ([NSObject xtj_isClassFromFoundation:clazz]) {
        if ([clazz isSubclassOfClass:NSArray.class]) {
            //NSArray
            NSMutableArray *array = [NSMutableArray array];
            for (id string in data) {
                [array addObject:[self serializingObject:string]];
            }
            return array;
        }else if ([clazz isSubclassOfClass:NSDictionary.class]){
            //NSDictionary
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (id key in data){
                [dic setObject:[self serializingObject:data[key]] forKey:key];
            }
            return dic;
        }
        // 基本类型
        return data;
    }
    NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
    NSArray *allowedPropertyNames = [self totalAllowedSerializePropertyNames:clazz];
    NSArray *ignoredPropertyNames = [self totalIgnoredSerializePropertyNames:clazz];
    
    [clazz xtj_enumerateProperty:^(XTProperty *property, BOOL *stop) {
        //[Mylog infoTag:@"XTJson",property];
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
        if ([ignoredPropertyNames containsObject:property.name]) {
            //[Mylog infoTag:@"XTJson", @"设置了忽略属性赋值:%@",property.name];
            return;
        }
        // 1.获取实体属性值
        id value = [property valueForObject:data];
        id name = property.name;
        // 2.手动配置了映射属性(根据映射的Json名重新取值)
        NSArray *propertyKeyses = [property propertyKeysForClass:[self class]];
        for (NSArray *propertyKeys in propertyKeyses) {//所有类(当前类+继承类+...)
            for (XTPropertyKey *propertyKey in propertyKeys) {//类属性(多层)
                //[Mylog infoTag:@"XTJson",@"propertyKey=%@",propertyKey];
                name = propertyKey.name;
                if (name) break;
            }
            if (name) break;
        }
        //3.是否设置了强制赋值/默认值
        id newValue = [clazz xtj_getNewValueFromObject:self oldValue:value property:property];
        if (newValue && newValue != value) {// 有过滤后的新值
            //[Mylog infoTag:@"XTJson",@"获取到了默认值:%@->%@",property.name,newValue];
            [property setValue:newValue forObject:self];
            return;
        }
        // 如果没有值，就直接返回
        if (!value || value == [NSNull null]) return;
        //4.复杂处理
        XTPropertyType *type = property.type;//属性
        Class propertyClass = type.typeClass;//属性类
        if (!type.isFromFoundation && propertyClass) { //实体类型
            [root setObject:[self serializingObject:value] forKey:name];
        }else{
            //[Mylog infoTag:@"XTJson",@"propertyClass:%@",propertyClass];
            if ([propertyClass isKindOfClass:[NSArray class]]) {
                // NSArray
                NSMutableArray *array = [NSMutableArray array];
                for (id string in value) {
                    [array addObject:[self serializingObject:string]];
                }
                [root setObject:array forKey:name];
            } else if ([propertyClass isKindOfClass:[NSDictionary class]]){
                // NSDictionary
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (id key in value){
                    [dic setObject:[self serializingObject:value[key]] forKey:key];
                }
                [root setObject:dic forKey:name];
            }else {
                [root setObject:[self serializingObject:value] forKey:name];
            }
        }
    }];
    return root;
}
// NSDictionary->实体
-(instancetype)deSerializingObject:(NSDictionary*)data{//反序列化NSDictionary->instancetype
    Class clazz = [self class];
    NSArray *allowedPropertyNames = [self totalAllowedSerializePropertyNames:clazz];//手动配置映射实体属性
    NSArray *ignoredPropertyNames = [self totalIgnoredSerializePropertyNames:clazz];//手动配置映射忽略属性
    [clazz xtj_enumerateProperty:^(XTProperty *property, BOOL *stop) {//迭代所有属性
        //[Mylog infoTag:@"XTJson",property];
        @try {
            // 0.检测是否被设置忽略
            if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
            if ([ignoredPropertyNames containsObject:property.name]) {
                //[Mylog infoTag:@"XTJson", @"设置了忽略属性赋值:%@",property.name];
                return;
            }
            // 1.取出属性值(Dictionary->Dictionary,Array->Array)
            id value = data[property.name];
            // 2.手动配置了映射属性(根据映射的Json名重新取值)
            NSArray *propertyKeyses = [property propertyKeysForClass:[self class]];
            //[Mylog infoTag:@"XTJson",@"propertyKeyses: %@",propertyKeyses];
            for (NSArray *propertyKeys in propertyKeyses) {//所有类(当前类+继承类+...)
                //value = data;
                for (XTPropertyKey *propertyKey in propertyKeys) {//类属性(多层)
                    //[Mylog infoTag:@"XTJson",@"propertyKey=%@",propertyKey];
                    value = [propertyKey valueInObject:data];//是否NSArray,NSDictionary
                    if (value) break;
                }
                if (value) break;
            }
            //3.是否设置了强制赋值/默认值
            id newValue = [clazz xtj_getNewValueFromObject:self oldValue:value property:property];
            if (newValue && newValue != value) { // 有过滤后的新值
                //[Mylog infoTag:@"XTJson",@"获取到了默认值:%@->%@",property.name,newValue];
                [property setValue:newValue forObject:self];
                return;
            }
            // 如果没有值，就直接返回
            if (!value || value == [NSNull null]) return;
            //4.复杂处理
            XTPropertyType *type = property.type;//属性
            Class propertyClass = type.typeClass;//属性类
            Class objectClass = [property objectClassInArrayForClass:[self class]];//映射属性类
            //[Mylog infoTag:@"XTJson",@"取到属性值:%@->%@=%@",property.name,NSStringFromClass(objectClass),value];
            // 不可变 -> 可变处理
            if (propertyClass == [NSMutableArray class] && [value isKindOfClass:[NSArray class]]) {
                value = [NSMutableArray arrayWithArray:value];
            } else if (propertyClass == [NSMutableDictionary class] && [value isKindOfClass:[NSDictionary class]]) {
                value = [NSMutableDictionary dictionaryWithDictionary:value];
            } else if (propertyClass == [NSMutableString class] && [value isKindOfClass:[NSString class]]) {
                value = [NSMutableString stringWithString:value];
            } else if (propertyClass == [NSMutableData class] && [value isKindOfClass:[NSData class]]) {
                value = [NSMutableData dataWithData:value];
            }
            //[Mylog infoTag:@"XTJson",@"取到属性值 类:%d %@",type.isFromFoundation, objectClass];
            if (!type.isFromFoundation && propertyClass) { //非系统类型模型属性(单实体对象)
                //[Mylog infoTag:@"XTJson",@"单实体类型属性"];
                value = [propertyClass deSerializingDictionary:value];
            } else if (objectClass) {
                if (objectClass == [NSURL class] && [value isKindOfClass:[NSArray class]]) {
                    // string array -> url array
                    NSMutableArray *urlArray = [NSMutableArray array];
                    for (NSString *string in value) {
                        if (![string isKindOfClass:[NSString class]]) continue;
                        [urlArray addObject:[self stringToURL:string]];
                    }
                    value = urlArray;
                } else { // 集合数组-->实体模型数组
                    //[Mylog infoTag:@"XTJson",@"集合实体类型属性"];
                    value = [objectClass deSerializingArray:value];
                }
            } else {
                if (propertyClass == [NSString class]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        // NSNumber -> NSString
                        value = [value description];
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        // NSURL -> NSString
                        value = [value absoluteString];
                    }
                } else if ([value isKindOfClass:[NSString class]]) {
                    if (propertyClass == [NSURL class]) {
                        // NSString -> NSURL 字符串转码
                        value = [self stringToURL:value];
                    } else if (type.isNumberType) {
                        NSString *oldValue = value;
                        // NSString -> NSNumber
                        if (type.typeClass == [NSDecimalNumber class]) {
                            value = [NSDecimalNumber decimalNumberWithString:oldValue];//浮点
                        } else {
                            value = [self.numberFormatter numberFromString:oldValue];//整数
                        }
                        // 如果是BOOL
                        if (type.isBoolType) {
                            // 字符串转BOOL（字符串没有charValue方法）系统会调用字符串的charValue转为BOOL类型
                            NSString *lower = [oldValue lowercaseString];
                            if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) {
                                value = @YES;
                            } else if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) {
                                value = @NO;
                            }
                        }
                    }
                }
                // value和property类型不匹配
                if (propertyClass && ![value isKindOfClass:propertyClass]) {
                    [Mylog infoTag:@"XTJson",@"属性 %@ 类型和值类型: %@ 不一致赋值失败", property.name, NSStringFromClass([value class])];
                    value = nil;
                }
            }
            // 3.赋值
            //[Mylog infoTag:@"XTJson",@"读取结束赋值:%@=%@",property.name,value];
            [property setValue:value forObject:self];
        } @catch (NSException *exception) {
            [Mylog infoTag:@"XTJson",exception];
        }
    }];
    return self;
}
// NSManagerObject
-(instancetype)deSerializingObject:(NSDictionary*)data context:(NSManagedObjectContext *)context{
    return nil;
}

#pragma mark - Json序列化/反序列化(系统JerializerJson)
/// jsonData: Json NSString/NSData -> NSArray,NSDictionary (NSArray,NSDictionary返回)
+(id)jsonObject:(id)jsonData{
    NSError *error;
    id rootJson;
    if ([jsonData isKindOfClass:[NSString class]]) {
        rootJson = [NSJSONSerialization JSONObjectWithData:[((NSString *)jsonData) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    } else if ([jsonData isKindOfClass:[NSData class]]) {
        rootJson = [NSJSONSerialization JSONObjectWithData:(NSData *)jsonData options:kNilOptions error:&error];
    } else if ([jsonData isKindOfClass:[NSArray class]] || [jsonData isKindOfClass:[NSDictionary class]]) {
        return jsonData;
    }
    if (error) {
        [Mylog infoTag:@"XTJson",@"NSJSONSerialization deSerializing Error.\n%@", error];
        return nil;
    }
    return rootJson;
}
/// NSArray/NSDictionary/Entity -> Json String
+(NSString*)jsonString:(id)object{
    if ([object isKindOfClass:[NSArray class]]){
        // 根类为 NSArray
        //[Mylog infoTag:@"XTJson", @"根类为 NSArray"];
        return [self string:[self jsonStringArray:(NSArray*)object]];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        // 根类为 NSDictionary
        //[Mylog infoTag:@"XTJson", @"根类为 NSDictionary"];
        return [self string:[self jsonStringDictionary:(NSDictionary*)object]];
    } else if ([object isKindOfClass:[NSObject class]]){
        // 根类为Object
        //[Mylog infoTag:@"XTJson", @"根类为 Object"];
        return [self string:[self jsonStringObject:(NSObject*)object]];
    }
    return nil;
}
-(NSData*)jsonStringArray:(NSArray*) array{
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
            [Mylog infoTag:@"XTJson", @"NSJSONSerialization serializing Error.\n%@", error];
        }
        return registerData;
    }
    return nil;
}
-(NSData*)jsonStringDictionary:(NSDictionary*) dictionary{
    NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
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
            [Mylog infoTag:@"XTJson", @"NSJSONSerialization serializing Error.\n%@", error];
            return nil;
        }
        return registerData;
    }
    return nil;
}
-(NSData*)jsonStringObject:(NSObject*)objectData{
    id value = [self serializingObject:objectData];
    if ([NSJSONSerialization isValidJSONObject:value]) {
        NSError *error; // NSJSONWritingPrettyPrinted 格式化打印
        NSData *registerData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            [Mylog infoTag:@"XTJson", @"NSJSONSerialization serializing Error.\n%@", error];
            return nil;
        }
        return registerData;
    }
    // Object-C->Json类型,继承类/或类: NSArray,NSDictionary,NSNumber,NSNull,NSString
    [Mylog infoTag:@"XTJson",@"Json实体实例化失败,实体包含了非Object-C(Json)基本类型,请检查实体/属性实体属性类型或是否实现了忽略属性方法(xtj_ignoredSerializePropertyNames)"];
    return nil;
}

#pragma mark 字符串/数据
-(NSString*)string:(NSData*) data{
    if(!data || data.length < 1)return nil;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
-(NSData*)data:(NSString*) string{
    if(!string || string.length < 1)return nil;
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark NSObjec Class Helper Method
+(void)xtj_enumerateProperty:(XTJPropertyEnumeration)enumeration{
    if (enumeration == nil) return;
    NSArray *cachedProperties = [self xtj_properties];//所有属性
    BOOL stop = NO;
    for (XTProperty *property in cachedProperties) {
        enumeration(property, &stop);
        if (stop) break;
    }
}
// 获取类的所有属性
+(NSMutableArray *) xtj_properties{
    NSMutableArray *cachedProperties = [self cacheDicForKey:&XTJCachedPropertiesKey][NSStringFromClass(self)];//静态缓冲属性
    if (cachedProperties == nil) {
        XTJsonSemaphoreCreate
        XTJsonSemaphoreWait
        cachedProperties = [NSMutableArray array];
        [self xtj_enumerateClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList(c, &outCount);
            for (unsigned int i = 0; i<outCount; i++) {
                XTProperty *property = [XTProperty cachedPropertyWithProperty:properties[i]];
                // 过滤掉Foundation框架类里面的类
                if ([self xtj_isClassFromFoundation:property.srcClass]) continue;
                property.srcClass = c;
                //[Mylog infoTag:@"XTJson",@"绑定XTProperty映射名称属性:%@.%@->%@", self,property.name,[self xtj_propertyKey:property.name]];
                [property setOriginKey:[self xtj_propertyKey:property.name] forClass:self];//Key转名映射
                //[Mylog infoTag:@"XTJson",@"绑定XTProperty映射实体属性:%@.%@->%@", self,property.name,[self propertyObjectClass:property.name]];
                [property setObjectClassInArray:[self propertyObjectClass:property.name] forClass:self];//实体对象映射
                [cachedProperties addObject:property];
            }
            free(properties);
        }];
        [self cacheDicForKey:&XTJCachedPropertiesKey][NSStringFromClass(self)] = cachedProperties;
        XTJsonSemaphoreSignal
    }
    return cachedProperties;
}
+ (void)xtj_enumerateClasses:(XTJClassesEnumeration)enumeration{//遍历所有继承类,指定结束根类
    if (enumeration == nil) return;
    BOOL stop = NO;
    Class c = self;
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
        if ([self xtj_isClassFromFoundation:c]) break;
    }
}
+ (void)xtj_enumerateAllClasses:(XTJClassesEnumeration)enumeration{//遍历所有继承类
    if (enumeration == nil) return;
    BOOL stop = NO;
    Class c = self;
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
    }
}
+ (BOOL)xtj_isClassFromFoundation:(Class)c{//Foundation指定的类
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;
    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{// 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses = [NSSet setWithObjects: [NSNull class],[NSURL class], [NSDate class], [NSValue class], [NSData class],[NSError class],
                             [NSArray class], [NSDictionary class], [NSString class], [NSAttributedString class], nil];
    });
    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([c isSubclassOfClass:foundationClass]) {//isKindOfClass:实例-是同类,isMemberOfClass:实例-是成员,isSubclassOfClass:类继承于
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
+ (id) xtj_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(XTProperty *__unsafe_unretained)property{
    id newValue = nil;
    // 强制赋值
    if ([self respondsToSelector:@selector(xtj_valueSerializePropertyNames)]) {
        newValue = [self xtj_valueSerializePropertyNames][property.name];
        if (newValue) return newValue;
    }
    // 如果有实现方法(实体类)
    if ([self respondsToSelector:@selector(xtj_valueToSerializeProperty:property:)]) {
        newValue = [self xtj_valueToSerializeProperty:oldValue property:property];
        if (newValue && newValue != oldValue) return newValue;
    }
    // 为nil时赋默认值
    if(!newValue && !oldValue && [self respondsToSelector:@selector(xtj_valueDefaultSerializePropertyNames)]){
        newValue = [self xtj_valueDefaultSerializePropertyNames][property.name];
    }
    return newValue;
}

-(NSArray*)totalAllowedSerializePropertyNames:(Class) class{
    return [class xtj_totalObjectsWithSelector:@selector(xtj_allowedSerializePropertyNames) key:&XTJAllowedSerializePropertyNamesKey];
}
-(NSArray*)totalIgnoredSerializePropertyNames:(Class) class{
    return [class xtj_totalIgnoredSerializePropertyNames:@selector(xtj_ignoredSerializePropertyNames) key:&XTJIgnoredPropertyNamesKey];
}
-(NSDictionary*)totalObjectSerializePropertyNames:(Class) class{
    return [class xtj_totalObjectSerializePropertyNames:@selector(xtj_objectSerializePropertyNames) key:&XTJObjectSerializePropertyNamesKey];
}
//+ (id)xtj_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(MJProperty *__unsafe_unretained)property{
//    // 如果有实现方法
//    if ([object respondsToSelector:@selector(xtj_newValueFromOldValue:property:)]) {
//        return [object mj_newValueFromOldValue:oldValue property:property];
//    }
//    // 兼容旧版本
//    if ([self respondsToSelector:@selector(newValueFromOldValue:property:)]) {
//        return [self performSelector:@selector(newValueFromOldValue:property:)  withObject:oldValue  withObject:property];
//    }
//
//    // 查看静态设置
//    __block id newValue = oldValue;
//    [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
//        MJNewValueFromOldValue block = objc_getAssociatedObject(c, &MJNewValueFromOldValueKey);
//        if (block) {
//            newValue = block(object, oldValue, property);
//            *stop = YES;
//        }
//    }];
//    return newValue;
//}
- (NSURL*)stringToURL:(NSString*)url{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8))];
    #pragma clang diagnostic pop
}
- (NSNumberFormatter*)numberFormatter{
    static NSNumberFormatter *numberFormatter_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter_ = [[NSNumberFormatter alloc] init];
    });
    return numberFormatter_;
}
- (id)xtj_propertyKey:(NSString *)propertyName{
    __block id key = nil;
    // 查看有没有需要替换的key
//    if ([self respondsToSelector:@selector(xtj_mappingSerializePropertyNames)]) {
//        key = [self xtj_mappingSerializePropertyNames][propertyName];
//    }
    
    // 调用block
//    if (!key) {
//        [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
//            MJReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyName121Key);
//            if (block) {
//                key = block(propertyName);
//            }
//            if (key) *stop = YES;
//        }];
//    }
//
//    // 查看有没有需要替换的key
    if ((!key || [key isEqual:propertyName]) && [self respondsToSelector:@selector(xtj_mappingSerializePropertyNames)]) {
        key = [self performSelector:@selector(xtj_mappingSerializePropertyNames)][propertyName];
    }
//    if (!key || [key isEqual:propertyName]) {
//        [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
//            NSDictionary *dict = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyNameKey);
//            if (dict) {
//                key = dict[propertyName];
//            }
//            if (key && ![key isEqual:propertyName]) *stop = YES;
//        }];
//    }
    // 2.用属性名作为key
    //if (!key) key = propertyName;
    return key;
}
- (Class)propertyObjectClass:(NSString*) name{
    NSString* className = [self totalObjectSerializePropertyNames:[self class]][name];
    return className ? NSClassFromString(className) : nil;
}
#pragma mark 静态缓存属性
//
static const char XTJKeyReplacedKeyFromPropertyName = '\0';
static const char XTJKeyReplacedKeyFromPropertyName121Key = '\0';
static const char XTJNewValueFromOldValueKey = '\0';
static const char XTJObjectClassInArrayKey = '\0';
static const char XTJCachedPropertiesKey = '\0';
//
static const char XTJAllowedPropertyNamesKey = '\0';
static const char XTJIgnoredPropertyNamesKey = '\0';
static const char XTJAllowedSerializePropertyNamesKey = '\0';
static const char XTJIgnoredSerializePropertyNamesKey = '\0';
static const char XTJObjectSerializePropertyNamesKey= '\0';
static const char XTJMappingSerializePropertyNamesKey= '\0';
//
+(NSMutableDictionary*) cacheDicForKey:(const void *)key{
    static NSMutableDictionary *replacedKeyFromPropertyNameDict;
    static NSMutableDictionary *replacedKeyFromPropertyName121Dict;
    static NSMutableDictionary *newValueFromOldValueDict;
    static NSMutableDictionary *objectClassInArrayDict;
    static NSMutableDictionary *cachedPropertiesDict;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        replacedKeyFromPropertyNameDict = [NSMutableDictionary dictionary];
        replacedKeyFromPropertyName121Dict = [NSMutableDictionary dictionary];
        newValueFromOldValueDict = [NSMutableDictionary dictionary];
        objectClassInArrayDict = [NSMutableDictionary dictionary];
        cachedPropertiesDict = [NSMutableDictionary dictionary];
    });
    
    if (key == &XTJKeyReplacedKeyFromPropertyName) return replacedKeyFromPropertyNameDict;
    if (key == &XTJKeyReplacedKeyFromPropertyName121Key) return replacedKeyFromPropertyName121Dict;
    if (key == &XTJNewValueFromOldValueKey) return newValueFromOldValueDict;
    if (key == &XTJObjectClassInArrayKey) return objectClassInArrayDict;
    if (key == &XTJCachedPropertiesKey) return cachedPropertiesDict;
    return nil;
}

#pragma mark - block和方法处理:存储block的返回值
+ (void)xtj_setupBlockReturnValue:(id (^)(void))block key:(const char *)key{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // 清空数据
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    [[self cacheDicForKey:key] removeAllObjects];
    XTJsonSemaphoreSignal
}

+ (NSMutableArray *)xtj_totalObjectsWithSelector:(SEL)selector key:(const char *)key{
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    NSMutableArray *array = [self cacheDicForKey:key][NSStringFromClass(self)];
    if (array == nil) {
        // 创建、存储
        array = [NSMutableArray array];
        [self cacheDicForKey:key][NSStringFromClass(self)] = array;
        if ([self respondsToSelector:selector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *subArray = [self performSelector:selector];
            #pragma clang diagnostic pop
            if (subArray) {
                [array addObjectsFromArray:subArray];
            }
        }
        [self xtj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSArray *subArray = objc_getAssociatedObject(c, key);
            [array addObjectsFromArray:subArray];
        }];
    }
    XTJsonSemaphoreSignal
    return array;
}
+ (NSArray*) xtj_totalIgnoredSerializePropertyNames:(SEL)selector key:(const char *)key{
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    NSMutableArray *array = [self cacheDicForKey:key][NSStringFromClass(self)];
    if (array == nil) {
        // 创建、存储
        array = [NSMutableArray array];
        [self cacheDicForKey:key][NSStringFromClass(self)] = array;
        if ([self respondsToSelector:selector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *subArray = [self performSelector:selector];
            #pragma clang diagnostic pop
            if (subArray) {
                [array addObjectsFromArray:subArray];
            }
        }
        [self xtj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSArray *subArray = objc_getAssociatedObject(c, key);
            [array addObjectsFromArray:subArray];
        }];
    }
    XTJsonSemaphoreSignal
    return array;
}
+ (NSMutableDictionary *)xtj_totalObjectSerializePropertyNames:(SEL)selector key:(const char *)key{
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    NSMutableDictionary *dic = [self cacheDicForKey:key][NSStringFromClass(self)];
    if (dic == nil) {
        // 创建、存储
        dic = [NSMutableDictionary dictionary];
        [self cacheDicForKey:key][NSStringFromClass(self)] = dic;
        if ([self respondsToSelector:selector]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSMutableDictionary *subdic = [self performSelector:selector];
            #pragma clang diagnostic pop
            if (subdic) {
                [dic addEntriesFromDictionary:subdic];
            }
        }
        [self xtj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSMutableDictionary *subdic = objc_getAssociatedObject(c, key);
            [dic addEntriesFromDictionary:subdic];
        }];
    }
    XTJsonSemaphoreSignal
    return dic;
}
@end


@implementation XTProperty{
    NSMutableDictionary *propertyKeysDict;//Key
    NSMutableDictionary *objectClassInArrayDict;//Key:Class
}
- (instancetype)init{
    if (self = [super init]) {
        propertyKeysDict = [NSMutableDictionary dictionary];
        objectClassInArrayDict = [NSMutableDictionary dictionary];
    }
    return self;
}
+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property{
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    XTProperty *propertyObj = objc_getAssociatedObject(self, property);
    if (propertyObj == nil) {
        propertyObj = [[self alloc] init];
        propertyObj.property = property;
        objc_setAssociatedObject(self, property, propertyObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    XTJsonSemaphoreSignal
    return propertyObj;
}
- (void)setProperty:(objc_property_t)property{
    _property = property;
    //MJExtensionAssertParamNotNil(property);
    // 1.属性名
    _name = @(property_getName(property));
    // 2.成员类型
    NSString *attrs = @(property_getAttributes(property));
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) { // 没有,
        code = [attrs substringFromIndex:loc];
    } else {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }
    _type = [XTPropertyType cachedTypeWithCode:code];
}

-(NSArray*)propertyKeysForClass:(Class)class{
    NSString *key = NSStringFromClass(class);
    if (!key) return nil;
    return propertyKeysDict[key];
}
// 获得成员变量的值(KVC取值)
- (id)valueForObject:(id)object{
    if (self.type.KVCDisabled) return [NSNull null];
    return [object valueForKey:self.name];
}
// 设置成员变量的值(KVC赋值)
- (void)setValue:(id)value forObject:(id)object{
    if (self.type.KVCDisabled || value == nil) return;
    //[Mylog infoTag:@"XTJson",@"支持KVC赋值: %@(%p).%@=%@", [object class],object,self.name,value];
    [object setValue:value forKey:self.name];
}
// 对应着字典中的key
- (void)setOriginKey:(id)originKey forClass:(Class)clazz{
    if(originKey == nil) return;
    if ([originKey isKindOfClass:[NSString class]]) { // 字符串类型的key
        NSArray *propertyKeys = [self propertyKeysWithStringKey:originKey];//hunterJobUrl
        if (propertyKeys.count) {
            [self setPorpertyKeys:@[propertyKeys] forClass:clazz];
        }
    }/* else if ([originKey isKindOfClass:[NSArray class]]) {
        NSMutableArray *keyses = [NSMutableArray array];
        for (NSString *stringKey in originKey) {
            NSArray *propertyKeys = [self propertyKeysWithStringKey:stringKey];
            if (propertyKeys.count) {
                [keyses addObject:propertyKeys];
            }
        }
        if (keyses.count) {
            [self setPorpertyKeys:keyses forClass:clazz];
        }
    }*/
}
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class)clazz{
    if (!objectClass) return;
    NSString *key = NSStringFromClass(clazz);
    if (!key) return;
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    objectClassInArrayDict[key] = objectClass;
    XTJsonSemaphoreSignal
}

- (Class)objectClassInArrayForClass:(Class)clazz{
    NSString *key = NSStringFromClass(clazz);
    if (!key) return nil;
    return objectClassInArrayDict[key];
}
// 通过字符串key创建对应的keys
- (NSArray *)propertyKeysWithStringKey:(NSString *)stringKey{
    if (stringKey.length == 0) return nil;
    //[Mylog infoTag:@"XTJson", @"通过字符串key创建对应的keys:%@",stringKey];
    NSMutableArray *propertyKeys = [NSMutableArray array];
    // 如果有多级映射 [jorUrl.value]
    NSArray *oldKeys = [stringKey componentsSeparatedByString:@"."];
    for (NSString *oldKey in oldKeys) {
        NSUInteger start = [oldKey rangeOfString:@"["].location;
        if (start != NSNotFound) { // 有索引的key
            NSString *prefixKey = [oldKey substringToIndex:start];
            NSString *indexKey = prefixKey;
            if (prefixKey.length) {
                XTPropertyKey *propertyKey = [[XTPropertyKey alloc] init];
                propertyKey.name = prefixKey;
                [propertyKeys addObject:propertyKey];

                indexKey = [oldKey stringByReplacingOccurrencesOfString:prefixKey withString:@""];
            }

            /** 解析索引 **/
            // 元素
            NSArray *cmps = [[indexKey stringByReplacingOccurrencesOfString:@"[" withString:@""] componentsSeparatedByString:@"]"];
            for (NSInteger i = 0; i<cmps.count - 1; i++) {
                XTPropertyKey *subPropertyKey = [[XTPropertyKey alloc] init];
                subPropertyKey.type = XTJPropertyKeyTypeArray;
                subPropertyKey.name = cmps[i];
                [propertyKeys addObject:subPropertyKey];
            }
        } else { // 没有索引的key
            XTPropertyKey *propertyKey = [[XTPropertyKey alloc] init];
            propertyKey.name = oldKey;
            [propertyKeys addObject:propertyKey];
        }
    }
    return propertyKeys;
}
// 对应着字典中的多级key
- (void)setPorpertyKeys:(NSArray *)propertyKeys forClass:(Class)clazz{
    if (propertyKeys.count == 0) return;
    NSString *key = NSStringFromClass(clazz);
    if (!key) return;
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    propertyKeysDict[key] = propertyKeys;
    XTJsonSemaphoreSignal
}
- (NSString *)description{
    return [NSString stringWithFormat:@"XTProperty:{name=%@}", self.name];
}
@end

@implementation XTPropertyType
+ (instancetype)cachedTypeWithCode:(NSString *)code{
    NSAssert(code, @"数据类型编码为空 nil");
    static NSMutableDictionary *types;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSMutableDictionary dictionary];
    });
    
    XTJsonSemaphoreCreate
    XTJsonSemaphoreWait
    XTPropertyType *type = types[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        types[code] = type;
    }
    XTJsonSemaphoreSignal
    return type;
}
- (void)setCode:(NSString *)code{
    _code = code;
    NSAssert(code, @"数据类型编码为空 nil");
    if ([code isEqualToString:XTJPropertyTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [NSObject xtj_isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
    } else if ([code isEqualToString:XTJPropertyTypeSEL] || [code isEqualToString:XTJPropertyTypeIvar] || [code isEqualToString:XTJPropertyTypeMethod]) {
        _KVCDisabled = YES;
    }
    // 是否为数字类型
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[XTJPropertyTypeInt, XTJPropertyTypeShort, XTJPropertyTypeBOOL1,
                             XTJPropertyTypeBOOL2, XTJPropertyTypeFloat, XTJPropertyTypeDouble,
                             XTJPropertyTypeLong, XTJPropertyTypeLongLong, XTJPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        // BOOL 0/1
        if ([lowerCode isEqualToString:XTJPropertyTypeBOOL1] || [lowerCode isEqualToString:XTJPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }
}
@end

@implementation XTPropertyKey

- (id)valueInObject:(id)object{
    if ([object isKindOfClass:[NSDictionary class]] && self.type == XTJPropertyKeyTypeDictionary) {
        // Dictionary->Dictionary
        return object[self.name];
    }else if ([object isKindOfClass:[NSArray class]] && self.type == XTJPropertyKeyTypeArray) {
        // Array->Array
        NSArray *array = object;
        NSUInteger index = self.name.intValue;
        if (index < array.count) return array[index];
        return nil;
    }
    return nil;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"{name=%@,type=%d}", self.name,self.type];
}
@end
