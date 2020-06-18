//
//  HttpCacheXT.m
//  jjrcw
//
//  Created by XiaoTian on 2020/5/21.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "HttpCacheXT.h"
@import ObjectiveC.runtime;

@implementation HttpCacheXT

- (void)setId:(NSString *)id{
    // KVO发通知(will,did)
    [self willChangeValueForKey:@"id"];//触发记录旧的值
    self->_id = id;
    [self didChangeValueForKey:@"id"];//触发Change
    // KVC
    //setValue:forKey
    //(1).首先去接收者(调用方法的那个对象)的类中查找与key相匹配的访问器方法(-set<Key>),如果找到了一个方法,就检查它参数的类型,如果它的参数类型不是一个对象指针类型,但是只为nil,就会执行setNilValueForKey:方法, setNilValueForKey:方法的默认实现,是产生一个NSInvalidArgumentException的异常,但是你可以重写这个方法.如果方法参数的类是一个对象指针类型,就会简单的执行这个方法, 传入对应的参数.如果方法的参数类型是NSNumber或NSValue的对应的基本类型,先把它转换为基本数据类,再执行方法,传入转换后的数据.
    //(2).如果没有对应的访问器方法(setter方法),如果接受者的类的+accessInstanceVariablesDirectly方法返回YES,那么就查找这个接受者的与key相匹配的实例变量,否则异常 (匹配模式为<key>,_<key>,is<Key>,_is<Key>,):比如:key为age,只要属性存在_age,_isAge,age,isAge中的其中一个就认为匹配上了,如果找到这样的一个实例变量,并且的类型是一个对象指针类型,首先released对象上的旧值,然后把传入的新值retain后的传入的值赋值该成员变量,如果方法的参数类型是NSNumber或NSValue的对应的基本类型,先把它转换为基本数据类,再执行方法,传入转换后的数据.
    //(3).如果访问器方法和实例变量都没有找到,执行setValue:forUndefinedKey:方法,该方法的默认实现是产生一个 NSUndefinedKeyException 类型的异常,但是我们可以重写setValue:forUndefinedKey:方法
    //valueForKey: 以上同理(自动加前缀,valueForUndefinedKey:)
    //valueForKeyPath: 必须用在集合对象上或普通对象的集合属性上,集合时还包含了简单算符
}
// 自动触发KVO通知(返回NO不触发)
+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        return NO;
    }else{
        return [super automaticallyNotifiesObserversForKey:key];
    }
}
#pragma NSCoder 归档 (NSKeyedArchiver\NSkeyedUnarchiver) 对象 <=> NSData
- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.id forKey:@"id"];
    [coder encodeObject:self.signature forKey:@"signature"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeDouble:self.time forKey:@"time"];
    //单对象 [NSKeyedArchiver archivedDataWithRootObject:entityId]; [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    //多对象 NSMutableData* data = [[NSMutableData alloc] init]; NSKeyedArchiver* keyedDecoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //      [keyedDecoder encodeObject:entity1Id forKey:@"entity1"];[keyedDecoder encodeObject:entity2Id forKey:@"entity2"];[keyedDecoder finishEncoding];
    //      NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data]; [keyedUnarchiver decodeObjectForKey:@"entity1"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder{
    if(!coder) return nil;
    self = [super init];
    if (self){
        self.id = [coder decodeObjectForKey:@"id"];
        self.signature = [coder decodeObjectForKey:@"signature"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.data = [coder decodeObjectForKey:@"data"];
        self.time = [coder decodeDoubleForKey:@"time"];
    }
    return self;
}
#pragma NSCopying 遵循NSCopying协议并实现方法copyWithZone就可以让自己的类用copy修饰符
- (id)copyWithZone:(nullable NSZone *)zone{
    HttpCacheXT* instance = [[[self class] allocWithZone:zone] init];
    instance.id = self.id;
    instance.signature = self.signature;
    instance.url = self.url;
    instance.data = self.data;
    instance.time = self.time;
    return instance;
}
//KVC
-(void)kvc{
    //https://www.jianshu.com/p/ff17a9619894
    //KVO支持实例变量, KVC的Keypath必须用在集合对象上或普通对象的集合属性上, 集合时还包含了简单算符有@avg， @count， @max， @min，@sum, age为键,格式 @"@sum.age"或 @"集合属性.@max.age"
    NSArray *array = @[@13, @23, @89, @3, @4, @46, @"2"];//NSNumber,NSString
    CGFloat sum1 = [[array valueForKeyPath:@"@sum.floatValue"] floatValue];//@运算符.属性 求和
    [Mylog info:@"%f", sum1];
    //运算符
    [Mylog info:[array valueForKeyPath:@"@count"]];//求个数
    [Mylog info:[array valueForKeyPath:@"@avg.floatValue"]];//平均
    [Mylog info:[array valueForKeyPath:@"@min.floatValue"]];//最小
    [Mylog info:[array valueForKeyPath:@"@max.floatValue"]];//最大
    NSArray *arrayText = @[@"Zhangsan", @"Lisi", @"WangWu"];
    //数组内字符串
    [Mylog info:[arrayText valueForKeyPath:@"uppercaseString"]];//转大写
    [Mylog info:[arrayText valueForKeyPath:@"lowercaseString"]];//转小写
    [Mylog info:[arrayText valueForKeyPath:@"length"]];//字符长度
    //字典取值
    NSArray *array1 = @[
        @{@"uid": @"id001", @"info":@{@"owner": @"zhanSan", @"code":@"001"}},
        @{@"uid": @"id002", @"info":@{@"owner": @"liSi", @"code":@"002"}},
        @{@"uid": @"id003", @"info":@{@"owner": @"wangEr", @"code":@"003"}}
    ];
    [Mylog info:[array1 valueForKeyPath:@"uid"]];//相同的key取值
    [Mylog info:[array1 valueForKeyPath:@"info.owner"]];//多层取值
    [Mylog info:[array1 valueForKeyPath:@"info.owner.uppercaseString"]];//相同的key取值并转大写
    //数组去重
    NSArray *array2 = @[@"1", @"dd", @"ccc", @"dd", @"1", @"d", @"d"];
    [Mylog info:[array2 valueForKeyPath:@"@distinctUnionOfObjects.self"]];//值去重
    //字典去重
    NSArray *array3 = @[
        @{@"name": @"zhangsan", @"age": @"1"},
        @{@"name": @"zhangsan", @"age": @"1"},
        @{@"name": @"lisi", @"age": @"2"}
    ];
    [Mylog info:[array3 valueForKeyPath:@"@distinctUnionOfObjects.name"]];//属性去重
    //模型取值
    if(NSClassFromString(@"RuntimeCreatePeople")) objc_disposeClassPair(NSClassFromString(@"RuntimeCreatePeople"));
    Class People = objc_allocateClassPair([NSObject class], "RuntimeCreatePeople", 0);
    class_addIvar(People, @"name".UTF8String, sizeof(id), log2(sizeof(id)), @encode(id));//变量
    class_addIvar(People, @"age".UTF8String, sizeof(int), log2(sizeof(int)), @encode(int));//
    objc_property_attribute_t types = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; //C = copy
    objc_property_attribute_t backIvar = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { types, ownership, backIvar };
    class_addProperty(People, @"firstName".UTF8String, attrs, 3);//属性
    //class_addMethod([SomeClass class], @selector(name), (IMP)nameGetter, "@@:");//方法
    //class_addMethod([SomeClass class], @selector(setName:), (IMP)nameSetter, "v@:@");
    class_addProtocol(People, NSProtocolFromString(@"NSCoder"));//协议
    objc_registerClassPair(People);
    NSMutableArray *peoples = [NSMutableArray arrayWithCapacity:array.count];
    for (int i = 0; i < arrayText.count; i++) {
        id p = [People alloc];
        [p setValue:arrayText[i] forKey:@"name"];
        [p setValue:@(i) forKey:@"age"];
        [peoples addObject:p];
    }
    [Mylog info:[peoples valueForKeyPath:@"name"]];//模型属性
}
//KVO
-(void)kvo{
    
}
@end
