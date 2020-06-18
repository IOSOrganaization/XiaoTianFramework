//
//  SerializerJson.m
//  XiaoTianFramework
//  JSON序列化
//  Created by XiaoTian on 16/6/28.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

#import "SerializerJson.h"
#import "Mylog.h"
@import ObjectiveC.runtime;
//
#define XTJPropertyTypeInt @"i"
#define XTJPropertyTypeShort @"s"
#define XTJPropertyTypeFloat @"f"
#define XTJPropertyTypeDouble @"d"
#define XTJPropertyTypeLong @"l"
#define XTJPropertyTypeLongLong @"q"
#define XTJPropertyTypeChar @"c"
#define XTJPropertyTypeBOOL1 @"c"//0,1
#define XTJPropertyTypeBOOL2 @"b"//true,false
#define XTJPropertyTypePointer @"*"
//
#pragma mark Test Json Entity 所有参与序列化和反序列化的属性都要以: XJ结尾, 不以XJ结尾不参与序列化
@interface XTJTestResponseFileImage : NSObject
@property(strong,nonatomic)NSString* idXJ;
@property(strong,nonatomic)NSString* nameXJ;
@property(strong,nonatomic)NSString* fileUrlXJ;
@property(strong,nonatomic)NSString* cursorXJ;
@property(strong,nonatomic)NSString* dataRatioXJ;
@property(assign,nonatomic)int widthXJ;
@property(assign,nonatomic)long heightXJ;
@end

@interface XTJTestResponseFileContent : NSObject
@property(strong,nonatomic)NSString* contentXJ;
@property(strong,nonatomic)NSString* folderNameXJ;
@end

@interface XTJTestResponseAD : NSObject
@property(strong,nonatomic)NSString* fileUrl;
@property(assign,nonatomic)int fileType;
@property(assign,nonatomic)int targetType;
@property(strong,nonatomic)NSString* targetContent;
@property(assign,nonatomic)long displaySeconds;
@property(assign,nonatomic)BOOL displayOnResume;
@property(assign,nonatomic)int style;
@end
@interface XTJTestResponseFile : NSObject
@property(strong,nonatomic)NSArray<XTJTestResponseFileContent*>* filesXJ;//Array需要配置实体映射
@property(assign,nonatomic)long latestVersionXJ;
@end
@interface XTJTestResponseVersion : NSObject
@property(strong,nonatomic)NSString* idXJ;
@property(strong,nonatomic)NSString* downloadUrlXJ;
@property(strong,nonatomic)NSArray<XTJTestResponseFileImage*>* imagesXJ;//Array需要配置实体映射
@property(assign,nonatomic)BOOL isForceXJ;
@property(strong,nonatomic)NSString* nameXJ;
@property(strong,nonatomic)NSString* versionNameXJ;
@property(strong,nonatomic)NSString* versionDescXJ;
@property(assign,nonatomic)int versionNumXJ;
@end
@interface XTJTestResponse : NSObject
@property(strong,nonatomic)XTJTestResponseAD* advertXJ;//嵌套类,非id类型不需要声明映射实体
@property(strong,nonatomic)XTJTestResponseFile* sysFileXJ;
@property(strong,nonatomic)XTJTestResponseVersion* versionXJ;
@end
@implementation XTJTestResponse
//- (NSDictionary<NSString *,NSString *> *)entityMapping{return @{@"advertXJ":@"XTJTestResponseAD",@"sysFileXJ":@"XTJTestResponseFile",@"versionXJ":@"XTJTestResponseVersion"};}
- (NSString *)description{ return [NSString stringWithFormat:@"%@:{advertXJ=%@,sysFileXJ=%@,versionXJ=%@}",[self class],self.advertXJ,self.sysFileXJ,self.versionXJ];}
@end
@implementation XTJTestResponseVersion
- (NSDictionary<NSString *,NSString *> *)entityMapping{return @{@"imagesXJ":@"XTJTestResponseFileImage"};}
- (NSString *)description{return [NSString stringWithFormat:@"%@:{idXJ=%@,downloadUrlXJ=%@,imagesXJ=%@,isForceXJ=%d,nameXJ=%@,versionNameXJ=%@,versionDescXJ=%@,versionNumXJ=%d}", [self class],self.idXJ,self.downloadUrlXJ,self.imagesXJ,self.isForceXJ,self.nameXJ,self.versionNameXJ,self.versionDescXJ,self.versionNumXJ];}
@end
@implementation XTJTestResponseFile
- (NSDictionary<NSString *,NSString *> *)entityMapping{return @{@"filesXJ":@"XTJTestResponseFileContent"};}
- (NSString *)description{return [NSString stringWithFormat:@"%@:{filesXJ=%@,latestVersionXJ=%ld}",[self class],self.filesXJ,self.latestVersionXJ];}
@end
@implementation XTJTestResponseAD
//- (NSString *)description{ return [NSString stringWithFormat:@"{advertXJ=%@,sysFileXJ=%@,versionXJ=%@}", self.advertXJ,self.sysFileXJ,self.versionXJ]; }
@end
@implementation XTJTestResponseFileContent
- (NSString *)description{return [NSString stringWithFormat:@"%@:{contentXJ=%@,folderNameXJ=%@}",[self class],self.contentXJ,self.folderNameXJ];}
@end
@implementation XTJTestResponseFileImage
- (NSString *)description{return [NSString stringWithFormat:@"%@:{idXJ=%@,nameXJ=%@,fileUrlXJ=%@,cursorXJ=%@,dataRatioXJ=%@,widthXJ=%d,heightXJ=%ld}",[self class],self.idXJ,self.nameXJ,self.fileUrlXJ,self.cursorXJ,self.dataRatioXJ,self.widthXJ,self.heightXJ];}
@end

// NSJSONSerialization 系统JSON序列化反序列化[只支持基本类型转化为JSON,以及JSON转化为基本类型,支持基本类型:NSString, NSNumber, NSArray, NSDictionary, or NSNull]
@implementation SerializerJson {
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
    // 嵌套实体
    NSString* jsonResponse = @"{\"advert\":{\"fileUrl\":\"https://img.77du.net/advert/20190529103709FhTVjOXpDsh5UWI2P1R87X2BnwCm.jpg\",\"fileType\":1,\"targetType\":3,\"targetContent\":\"{ \'page\':1,\'pageId\':\'770158466059730944\'}\",\"displaySeconds\":5,\"displayOnResume\":0,\"style\":3},\"sysFile\":{\"latestVersion\":1,\"files\":[{\"folderName\":\"assets/newsTemplate\",\"content\":\"https://static.77du.net/appres/newsTemplate.zip\"},{\"folderName\":\"assets/jjrw\",\"content\":\"https://static.77du.net/appres/77du/jjrw.zip\"}]},\"version\":{\"downloadUrl\":\"itms-apps://itunes.apple.com/cn/app/id1438339209?mt=8\",\"images\":[{\"cursor\":null,\"dataRatio\":\"0.0\",\"fileUrl\":\"https://img.77du.net/sys/20191125140353FrVt_txaKY6jney6tZQh1z0Mfpl0.jpg\",\"height\":700,\"id\":893001260897140736,\"name\":\"升级@3x.jpg\",\"width\":730}],\"isForce\":1,\"name\":\"77度-ios-3.2.5\",\"versionDesc\":\"2019.11.26更新内容\",\"versionName\":\"version-3.2.7\",\"versionNum\":139}}";
    // 反序列化
    SerializerJson* sj = [[SerializerJson alloc] init];
    XTJTestResponse* response = [sj deSerializing:[jsonResponse dataUsingEncoding:NSUTF8StringEncoding] clazz:XTJTestResponse.class];
    [Mylog info:@"SerializerJson 反序列化测试: %@", response];
    // 序列化
    NSData* json = [sj serializing:response];
    [Mylog info:@"SerializerJson 反序列化测试: %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
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
        //[Mylog info:@"根类为 NSArray"];
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
                [Mylog info:@"NSJSONSerialization serializing Error.\n%@", error];
            }
            return registerData;
        }
        return nil;
    } else if ([objectData isKindOfClass:[NSDictionary class]]){
        // 根类为 NSDictionary
        //[Mylog info:@"根类为 NSDictionary"];
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
                [Mylog info:@"NSJSONSerialization serializing Error.\n%@", error];
                return nil;
            }
            return registerData;
        }
        return nil;
    } else if ([objectData isKindOfClass:[NSObject class]]){
        // 根类为Object
        //[Mylog info:@"根类为 Object"];
        NSMutableDictionary* root = [[NSMutableDictionary alloc] init];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([objectData class], &outCount);
        for(i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                // 属性必须以XJ声明结尾
                size_t propNameLength = strlen(propName);
                if (propNameLength < 2 || !endsWithXJ(propName)) continue;
                //const char *propType = getPropertyType(property);
                char* simpleName = (char*) malloc(propNameLength - 1);
                strncpy(simpleName, propName, propNameLength - 2);
                simpleName[propNameLength - 2] = '\0';
                NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                id value = [self serializingObject:[objectData valueForKey:propertyName]];
                if (value) {
                    [root setObject:value forKey:[NSString stringWithCString:simpleName encoding:[NSString defaultCStringEncoding]]];
                }
                //NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                //NSString *propertyType = [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
                //[Mylog info:@"%@,%@",propertyName,propertyType];
            }
        }
        free(properties);
        if ([NSJSONSerialization isValidJSONObject:root]) {
            NSError *error; // NSJSONWritingPrettyPrinted 格式化打印
            NSData *registerData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                [Mylog info:@"NSJSONSerialization serializing Error.\n%@", error];
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
        [Mylog info:@"NSJSONSerialization deSerializing Error.\n%@", error];
        return nil;
    }
    if ([rootJson isKindOfClass:[NSArray class]]) {
        //[Mylog info:@"根类为 NSArray"];
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
        //[Mylog info:@"根类为 NSDictionary"];
        NSDictionary *jsonDictionary = (NSDictionary *)rootJson;
        return [self deSerializingObject:jsonDictionary clazz:clazz];
    }
    return nil;
}
-(id) deSerializing:(NSData *) jsonData{
    NSError *error;
    id rootJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        [Mylog info:@"NSJSONSerialization deSerializing Error.\n%@", error];
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
                size_t propNameLength = strlen(propName);
                if (propNameLength < 2 || !endsWithXJ(propName)) continue;
                //const char *propType = getPropertyType(property);
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
                size_t propNameLength = strlen(propName);
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
            [Mylog info:@"Entity %@ propertys is empty serializing error.", clazz];
            return nil;
        }
        cachePropertys = cache;
        [cacheClassProperty setObject:cachePropertys forKey:classHash];
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
                //[Mylog info:@"%@,%@,%@", itemKey, value, propertyType];
                @try {
                    // 可赋值类型
                    if ([@"NSString" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    }else if([value isKindOfClass:[NSDictionary class]]){
                        // 子类是Dictionary单个定义类型对象
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
                    }else if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]){
                        // 集合Array类(entityMapping配置映射实体)
                        NSArray* array = (NSArray*)value;
                        NSMutableArray* values = [[NSMutableArray alloc] init];
                        if([instance respondsToSelector:@selector(entityMapping)]){
                            NSDictionary<NSString*,NSString*>* map = [instance performSelector:@selector(entityMapping)];
                            NSEnumerator* iteMap = [map keyEnumerator];
                            id iteMapKey = nil;
                            while (iteMapKey = [iteMap nextObject]){
                                if([iteMapKey isEqualToString:[NSString stringWithFormat:@"%@XJ",itemKey]]){
                                    Class mapClazz = NSClassFromString(map[iteMapKey]);
                                    if (mapClazz != nil){
                                        for(int i=0; i<array.count; i++){
                                            NSObject* arrayValue = array[i];
                                            if([arrayValue isKindOfClass:[NSDictionary class]]){
                                                [values addObject:[self deSerializingObject:(NSDictionary*)arrayValue clazz:mapClazz]];
                                            }else if([arrayValue isKindOfClass:[NSArray class]]){
                                                [values addObject:[self deSerializingArrayObject:(NSArray*)arrayValue clazz:mapClazz]];
                                            }
                                        }
                                    }else{
                                        [Mylog info:@"配置的映射类不存在:%@->%@",iteMapKey,map[iteMapKey]];
                                        values = value;
                                    }
                                    break;
                                }
                            }
                        }
                        [instance setValue:values forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    // 数字类型
                    } else if ([@"NSNumber" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSMutableString" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"NSDecimalNumber" isEqualToString:propertyType]){
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"i" isEqualToString:[propertyType lowercaseString]]){//Int
                        [instance setValue:[NSNumber numberWithInt:[value intValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"f" isEqualToString:[propertyType lowercaseString]]){//Float
                        [instance setValue:[NSNumber numberWithFloat:[value floatValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"d" isEqualToString:[propertyType lowercaseString]]){//Double
                        [instance setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"b" isEqualToString:[propertyType lowercaseString]]){//BOOL
                        [instance setValue:[NSNumber numberWithBool:[value boolValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"s" isEqualToString:[propertyType lowercaseString]]){//Short
                        [instance setValue:[NSNumber numberWithShort:[value shortValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"q" isEqualToString:[propertyType lowercaseString]]){//LongLong
                        [instance setValue:[NSNumber numberWithLongLong:[value longLongValue]] forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    } else if ([@"c" isEqualToString:[propertyType lowercaseString]]){//Char /BOOL: 0/1
                        [instance setValue:value forKey:[NSString stringWithFormat:@"%@XJ",itemKey]];
                    }
                    //[Mylog info:@"跳过属性设置:%@",itemKey];
                } @catch(NSException* e){
                    [Mylog info:@"尝试设置实体属性值时发生错误.属性名:%@XJ,属性值:%@,属性类型:%@", itemKey, value, propertyType];
                }
                
                // 缓存指针模式
                /*char *propType;
                NSValue* cachePropertysValue = [cachePropertys objectForKey:itemKey];
                [cachePropertysValue getValue:&propType];
                //[Mylog info:@"%@,%@,%s", itemKey, value, propType];
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
                        //[Mylog info:@"跳过属性设置:%@",itemKey];
                    }
                } @catch(NSException* e){
                    [Mylog info:@"尝试设置实体属性值时发生错误.属性名:%@XJ,属性值:%@,属性类型:%s", itemKey, value, propType];
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
    id data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return [[[NSString alloc] initWithFormat:@"dataWithJSONObject Error.\n%@", error] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return data;
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //[Mylog info:@"Attributes=%s\n", attributes];
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

- (void)dealloc{
    [Mylog infoDealloc:self];
}
@end
