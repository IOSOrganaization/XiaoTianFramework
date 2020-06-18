//
//  NSObject+XTJson.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2016/12/5.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ObjectiveC.runtime;

NS_ASSUME_NONNULL_BEGIN
@class XTPropertyType;
@class XTProperty;

@interface NSObject(XTJson)

// 实体可选实现的配置开放入口 (所有属性必须支持KVC赋值模式才能赋值)
//
/// 设置指定序列化属性 -> 如果设置则取消自动获取序列化的变量 @[@"name",@"age"]
+(NSArray *)xtj_allowedSerializePropertyNames;
/// 设置忽略序列化属性 -> 如果设置则取消序列化指定变量名 @[@"localType"]
+(NSArray *)xtj_ignoredSerializePropertyNames;
/// 设置实体对象映射 -> 实体映射 @[@"person":@"PersonEntity",@"studens":@"StudenEntity",@"objName1":@"TeacherEntity"]
+(NSDictionary *)xtj_objectSerializePropertyNames;
/// 设置属性名称映射 -> 名称映射 @[@"obcName":@"jsonName",@"objName1":@"jsonName1"] (基本类型映射,实体类型映射[在实体映射列表要声明])
+(NSDictionary *)xtj_mappingSerializePropertyNames;
/// 设置指定属性的值 ->  强制赋值@{@"isOpen":@NO, @"isSuccess": @YES} (优先级1)
+(NSDictionary *)xtj_valueSerializePropertyNames;
/// 回调方法获取指定属性获取值 (优先级2)
+(id)xtj_valueToSerializeProperty:(id)vlue property:(XTProperty*) property;
/// 设置指定属性默认值 -> 如果值不存在或为空时赋默认值 @{@"isOpen":@NO, @"isSuccess":@YES} (优先级3)
+(NSDictionary *)xtj_valueDefaultSerializePropertyNames;

//
// 业务开放接口
/**
 *反序列化JSON字符串到实体对象/实体集合
 *@params data NSString / NSData 的Json数据格式 {} / []字符串, JSON支持基本类型的的 NSArray,NSDictionary
 *@return instancetype / NSArray<instancetype>单对象 / 集合对象
 */
+(id)deSerializing:(id) data;

/**
 *反序列化NSDictionary到实体对象
 *@params dic NSDictionary Key/Value
 *@return instancetype
 */
+(instancetype)deSerializingDictionary:(NSDictionary*) dic;

/**
 *反序列化JSON字符串到实体集合
 *@params array NSArray Key/Value
 *@return NSArray<instancetype>
 */
+(NSMutableArray<id>*)deSerializingArray:(NSArray*) array;

/**
 *序列化实体到Json字符串
 */
-(NSString*)serializing;

/**
*序列化实体到Object-C对象 NSArray 或 NSDictionary
*/
-(NSDictionary*)serializingToDic;
@end

// 缓冲属性
@interface XTProperty : NSObject
@property(readonly,nonatomic)NSString* name;//属性名
@property(readonly,nonatomic)XTPropertyType* type;//属性类型
@property(assign,nonatomic)Class typeClass;//目标类
@property(assign,nonatomic)Class srcClass;//源类
@property(assign,nonatomic)objc_property_t property;//属性

+ (instancetype)cachedPropertyWithProperty:(objc_property_t)property;
- (void)setOriginKey:(id)originKey forClass:(Class)c;
- (NSArray*)propertyKeysForClass:(Class)clazz;
- (Class)objectClassInArrayForClass:(Class)clazz;
- (void)setObjectClassInArray:(Class)objectClass forClass:(Class) clazz;

// 取/赋值
- (void)setValue:(id)value forObject:(id)object;//设置object的成员变量值
- (id)valueForObject:(id)object;//得到object的成员属性值

@end

// 类型
@interface XTPropertyType : NSObject
@property(nonatomic, copy)NSString *code;//类型编码
@property(nonatomic, readonly, getter=isIdType)BOOL idType;//是否为id类型
@property(nonatomic, readonly, getter=isNumberType)BOOL numberType;//是否为基本数字类型：int、float等
@property(nonatomic, readonly, getter=isBoolType)BOOL boolType;//是否为BOOL类型
@property(nonatomic, readonly)Class typeClass;//对象类型（如果是基本数据类型，此值为nil）
@property(nonatomic, readonly, getter = isFromFoundation)BOOL fromFoundation;//类型是否来自于Foundation框架，比如NSString、NSArray
@property(nonatomic, readonly, getter = isKVCDisabled)BOOL KVCDisabled;//类型是否不支持KVC
+ (instancetype)cachedTypeWithCode:(NSString*)code;//获得缓存的类型对象
@end

//key
#define XTJPropertyKeyTypeDictionary 0
#define XTJPropertyKeyTypeArray 1
@interface XTPropertyKey : NSObject
@property(copy,nonatomic)NSString *name;//属性的key的名字
@property(assign,nonatomic)int type;//key的种类//PropertyKeyTypeDictionary,PropertyKeyTypeArray
- (id)valueInObject:(id)object;//根据当前的key，也就是name，从object（字典或者数组）中取值
@end
NS_ASSUME_NONNULL_END
