//
//  UtilRuntime.m
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//
#import "UtilRuntime.h"

@import ObjectiveC.runtime;
@implementation UtilRuntime

+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) swizzledSelector{
    //class_getInstanceMethod,获取通过SEL获取一个方法
    //method_getImplementation,获取一个方法的实现
    //method_getTypeEncoding,获取一个OC实现的编码类型
    //class_addMethod,給方法添加实现
    //class_replaceMethod,用一个方法的实现替换另一个方法的实现
    //method_exchangeImplementations,交换两个方法的实现
    //case1: 替换实例方法 Class selfClass = [self class];
    //case2: 替换类方法 Class selfClass = object_getClass([self class]);
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    // 添加自定义的方法到指定的类里面,如果添加成功则返回true,否则false[已经存在],(先尝试給源方法添加实现，这里是为了避免源方法没有实现的情况)
    BOOL didAddMethod = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        // 添加成功,替换原方法 (将源方法的实现替换到交换方法的实现)
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        // 添加失败：说明源方法已经有实现，交换两个方法的实现 (直接将两个方法的实现交换即可)
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    //Method Swizzling注意事项
    //每个类都维护一个方法（Method）列表，Method则包含SEL和其对应IMP的信息，方法交换做的事情就是把SEL和IMP的对应关系断开，并和新的IMP生成对应关系。
    //      交换前：Asel－>AImp Bsel－>BImp
    //      交换后：Asel－>BImp Bsel－>AImp
    //1、方法交换应该保证唯一性和线程安全 ( 唯一性：应该尽可能在＋load方法中实现，这样可以保证方法一定会调用且不会出现异常。 原子性：使用dispatch_once来执行方法交换，这样可以保证只运行一次。)
    //2、一定要调用原始实现 (由于iOS的内部实现对我们来说是不可见的，使用方法交换可能会导致其代码结构改变，而对系统产生其他影响，因此应该调用原始实现来保证内部操作的正常运行。)
    //3、方法名必须不能产生冲突 (这个是常识，避免跟其他库产生冲突。)
    //4、做好记录 (记录好被影响过的方法，不然时间长了或者其他人debug代码时候可能会对一些输出信息感到困惑。)
    //5、如果非迫不得已，尽量少用方法交换 (虽然方法交换可以让我们高效地解决问题，但是如果处理不好，可能会导致一些莫名其妙的bug。)
}

+(NSMutableArray<NSString*> *) queryPropertyList: (Class) clazz{
    //NSClassFromString(clazzName)
    return [UtilRuntime queryPropertyList:clazz endSupperClazz:nil];
}

+(NSMutableArray<NSString*> *) queryPropertyList: (Class) clazz endSupperClazz: (Class) supperClazz {
    if (!clazz) return nil;
    NSMutableArray<NSString*>* propertyList = [[NSMutableArray alloc] init];
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

+(NSMutableArray<NSString*>*)queryIvarList:(Class) clazz{
    NSMutableArray *fieldNames = [NSMutableArray array];
    while (clazz) {
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList(clazz, &ivarCount);
        for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
            Ivar ivar = ivars[ivarIndex];
            const char *typeEncoding = ivar_getTypeEncoding(ivar);
            if (typeEncoding[0] == @encode(id)[0] || typeEncoding[0] == @encode(Class)[0]) {
                [fieldNames addObject:@(ivar_getName(ivar))];
                /*ptrdiff_t offset = ivar_getOffset(ivar);//获得ivar的偏移量
                uintptr_t *fieldPointer = (__bridge void *)tryObject + offset;//通过偏移获得对象
                if (*fieldPointer == (uintptr_t)(__bridge void *)object) {
                    [instances addObject:tryObject];
                    [fieldNames addObject:@(ivar_getName(ivar))];
                    return;
                }*/
            }
        }
        clazz = class_getSuperclass(clazz);
    }
    return fieldNames;
}

+(NSString *) queryPropertyType: (Class) clazz propertyName:(NSString *) propertyName{
    const char* propType = getPropertyType(class_getProperty(clazz, [propertyName cStringUsingEncoding:NSASCIIStringEncoding]));
    return [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
}
/// C 获取属性类型
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

+(NSMutableArray<NSString*> *) queryProtocolMethodList:(Protocol*) protocol isInstanceMethod:(BOOL) isInstanceMethod isRequiredMethod:(BOOL)isRequiredMethod{
    //Protocol* protocol = objc_getProtocol([trim(protocolName) cStringUsingEncoding:NSUTF8StringEncoding]);
    unsigned int selectorCount = 0;
    struct objc_method_description* methods = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &selectorCount);
    NSMutableArray<NSString*>* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < selectorCount; i++){
        [result addObject: NSStringFromSelector(methods[i].name)];
    }
    free(methods);
    return result;
}
/// C 获取接口类型签名
static char* getMethodTypesInProtocol(Protocol* protocol,NSString* methodName,BOOL isInstanceMethod,BOOL isRequired){
    unsigned int selectorCount = 0;
    struct objc_method_description* methods = protocol_copyMethodDescriptionList(protocol, isInstanceMethod, isRequired, &selectorCount);
    for (int i = 0; i < selectorCount; i++){
        if ([methodName isEqualToString:NSStringFromSelector(methods[i].name)]){
            char* types = malloc(strlen(methods[i].types) + 1); //Add C End Char
            strcpy(types, methods[i].types);
            return types;
        }
    }
    free(methods);
    return NULL;
}
/// C 添加接口协议到当前内存([methodName:[typeEncodeing:v@:@, isInstance:YES, params:void,NSString*,int]])
static void defineProtocol(NSString* protocolName, NSDictionary* methods){
    const char* protocolNameC = [protocolName UTF8String];
    Protocol* protocol = objc_allocateProtocol(protocolNameC);//创建接口协议类型
    if (protocol){
        // 添加接口协议方法(必须在注册前添加)
        for (NSString* methodName in methods.allKeys){
            NSDictionary* methodParams = methods[methodName];
            BOOL isInstance = methodParams[@"isInstance"];
            NSString* typeEncodeing = methodParams[@"typeEncodeing"];
            if (typeEncodeing){
                addMethodToProtocol(protocol, methodName, typeEncodeing, isInstance);
            }else{
                NSString* params = methods[@"params"];
                addMethodToProtocolByParamsType(protocol, methodName, params, isInstance);
            }
        }
        objc_registerProtocol(protocol);//注册到内存
    }
}
/// C 添加方法到接口协议(protocol:接口协议类,methodName:方法名,typeEncoding:返回+方法参数类型编码,isInstance:是否实例方法)
static void addMethodToProtocol(Protocol* protocol,NSString* methodName,NSString* typeEncoding,BOOL isInstance){
    SEL sel = NSSelectorFromString(methodName);
    const char* type = [typeEncoding UTF8String];
    protocol_addMethodDescription(protocol, sel, type, YES, isInstance);
}
/// C 添加方法到接口协议(protocol:接口协议类,methodName:方法名,params:返回+方法参数类型(用逗号分开,与方法外部名称一一对应),isInstance:是否实例方法)
static void addMethodToProtocolByParamsType(Protocol* protocol,NSString* methodName,NSString* params,BOOL isInstance){
    NSDictionary* protocolTypeEncodeing = usefuleTypeEncoding();
    NSArray* paramsMethod = [params componentsSeparatedByString:@","]; // 返回+方法参数
    // 返回+参数 < 变量数
    if([methodName componentsSeparatedByString:@":"].count < paramsMethod.count){ //方法名称参数分隔符写死
        methodName = [methodName stringByAppendingString:@":"];
    }
    NSMutableString* methodTypeEncoding = [[NSMutableString alloc] init];
    // 返回值
    NSString* returnEncode = protocolTypeEncodeing[paramsMethod[0]];
    if(returnEncode){//常见基本类型
        [methodTypeEncoding appendString:returnEncode];
    }else{
        NSString* customerClass = [paramsMethod[0] stringByReplacingOccurrencesOfString:@"*" withString:@""];//去掉*号
        if (existProtocolOrClass(customerClass)){// 可以直接用id
            returnEncode = @"@";// 自定义类类型(在Object-C中实则这些都是id地址类型)
        }else{
            [Mylog info:@"返回参数类型编码在常用系统参数中找不到:%@", paramsMethod[0]];// 不支持类型
        }
    }
    [methodTypeEncoding appendString:@"@:"]; //返回值和方法参数分隔符写死
    for (int i=1; i<paramsMethod.count; i++){
        NSString* param = trim(paramsMethod[i]);
        NSString* paramEncode = protocolTypeEncodeing[param];//常用系统参数基本类型的C编码
        if (paramEncode){
            [methodTypeEncoding appendString:paramEncode];
        }else{
            if (existProtocolOrClass([paramsMethod[i] stringByReplacingOccurrencesOfString:@"*" withString:@""])){
                returnEncode = @"@";// 自定义类类型(在Object-C中实则这些都是id地址类型,可以直接用id代替)
            }else{
                [Mylog info:@"方法参数类型在常用类型中找不到:%@", param];// 不支持类型
            }
        }
    }
    // 添加方法
    addMethodToProtocol(protocol, methodName, methodTypeEncoding, isInstance);
}
/// C 添加类到当前内存
static void defineClass(NSString* className,NSString* supperClass,NSArray* protocols,NSDictionary* methods){
    // class testClass:NSObject<NSCoding,NSEqualable,NSCompareable>{}
    Class clazz = NSClassFromString(className);// 类类型,用于添加接口/实例方法
    if(!clazz){//类不存在,创建类,注册到内存
        Class clazzSuper = NSClassFromString(supperClass) ?: NSObject.class;
        clazz = objc_allocateClassPair(clazzSuper, className.UTF8String, 0);
        objc_registerClassPair(clazz);
    }
    for (NSString* name in protocols){//添加接口协议
        NSString* protocolName = trim(name);
        Protocol* protocol = objc_getProtocol(protocolName.UTF8String);
        class_addProtocol(clazz, protocol);
    }
    Class clazzMeta = objc_getMetaClass(className.UTF8String);// 类的原始类型,用于添加静态方法
    for (NSString* methodName in methods.allKeys){
        NSDictionary* methodParams = methods[methodName];
        
    }
    //[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    // 添加属性get/set
    class_addMethod(clazz, @selector(getProperty:), (IMP)getProperty, "@@:@");//id:id
    class_addMethod(clazz, @selector(setProperty:forKey:), (IMP)getProperty, "v@:@");//void:id
}
/// 通过类名称,方法名,请求参数调用类的类方法(常见类型的普通方法,特殊方法太多调不起:inout,const关键字等)
static id callClassMethod(NSString* className,NSString* methodName,NSArray* params){
    Class clazz = NSClassFromString(className);
    SEL selector = NSSelectorFromString(methodName);
    NSObject* emptyObject = [[NSObject alloc] init];
    //[.methodReturnType:返回类型,.methodReturnLength:返回类型名称长度, getArgumentTypeAtIndex:获取指定参数类型]
    NSMethodSignature* methodSignature = [clazz methodSignatureForSelector:selector];//方法签名: v@:@
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSignature];//创建调用器
    //设置调用器参数
    [invocation setTarget:clazz];//目标
    [invocation setSelector:selector];//方法
    // 方法参数
    if (params.count > methodSignature.numberOfArguments - 2){//过滤返回和参数分割符@:,传入参数大于方法参数: [v@:@]
        [Mylog info:@"传入参数大于方法参数"];
    }else if(params.count < methodSignature.numberOfArguments - 2){
        NSCAssert(NO, @"传入参数小于方法参数");
    }
    NSMutableString* methodTypeEncode = [[NSString stringWithUTF8String:methodSignature.methodReturnType] mutableCopy];
    [methodTypeEncode appendString:@"@:"];
    for(NSInteger i = 2; i < methodSignature.numberOfArguments;i++){ //过滤返回和参数分割符@:
        [methodTypeEncode appendString:[NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]]];
        const char* type = [methodSignature getArgumentTypeAtIndex:i];
        id value = params[i - 2];
        [Mylog info:[NSString stringWithUTF8String:type]];
        // 对象(NSArray)转换为基本类型
        switch (type[0] == 'r' ? type[1] : type[0]) {//第一个字符[const char *: r*]
            // 支持的基本类型
            case 'c': {
                char valuet = [value charValue];
                [invocation setArgument:&valuet atIndex:i];
                break;
            }
            #define callClassMethodTypeCase(character,type,method) \
            case character:{ \
                type valuet = [value method]; \
                [invocation setArgument:&valuet atIndex:i]; \
                break; \
            }
            // 加入普通类型
            callClassMethodTypeCase('C', unsigned char, unsignedCharValue)
            callClassMethodTypeCase('s', short, shortValue)
            callClassMethodTypeCase('S', unsigned short, unsignedShortValue)
            callClassMethodTypeCase('i', int, intValue)
            callClassMethodTypeCase('I', unsigned int, unsignedIntValue)
            callClassMethodTypeCase('l', long, longValue)
            callClassMethodTypeCase('L', unsigned long, unsignedLongValue)
            callClassMethodTypeCase('q', long long, longLongValue)
            callClassMethodTypeCase('Q', unsigned long long, unsignedLongLongValue)
            callClassMethodTypeCase('f', float, unsignedCharValue)
            callClassMethodTypeCase('d', double, doubleValue)
            callClassMethodTypeCase('B', BOOL, boolValue)
            //Selector方法选择器
            case ':':{
                SEL valuet = nil;
                if (value != emptyObject){
                    valuet = NSSelectorFromString(value);
                }
                [invocation setArgument:&valuet atIndex:i];
                break;
            }
            //struct 开始
            case '{':{
                NSString* firstStructName = getFirstStructName([NSString stringWithUTF8String:type]);
                if ([firstStructName rangeOfString:@"CGRect"].location != NSNotFound){
                    // [NSValue valueWithCGRect:rect]
                    CGRect valuet = [value CGRectValue];
                    [invocation setArgument:&valuet atIndex:i];
                }
                #define callClassMethodTypeCaseStruct(type,method) \
                    else if ([firstStructName rangeOfString:@#type].location != NSNotFound){ \
                    type valuet = [value method]; \
                    [invocation setArgument:&valuet atIndex:i]; \
                }
                callClassMethodTypeCaseStruct(CGPoint, CGPointValue)
                callClassMethodTypeCaseStruct(CGVector, CGVectorValue)
                callClassMethodTypeCaseStruct(CGSize, CGSizeValue)
                callClassMethodTypeCaseStruct(UIEdgeInsets, UIEdgeInsetsValue)
                callClassMethodTypeCaseStruct(UIOffset, UIOffsetValue)
                else{
                    // 其他自定义struct
                    [Mylog info:@"无法识别的struct类型:%@,可以手动类型添加解析.",firstStructName];
                }
                break;
            }
            case '*'://char *
            case '^'://指针(block)
            break;
            case '#'://Class
            break;
            default:{
                if (value == nil){
                    NSNull* valuet = [NSNull null];
                    [invocation setArgument:&valuet atIndex:i];
                }else if(value == emptyObject || ([value isKindOfClass:[NSNumber class]] && strcmp([value objCType], "c") == 0 && [value boolValue] == NO)){
                    id valuet = nil;
                    [invocation setArgument:&valuet atIndex:i];
                }/*else if(){
                    
                }*/else{ //@指针
                    [invocation setArgument:&value atIndex:i];
                }
                break;
            }
        }
    }
    [Mylog info:methodTypeEncode];
    [invocation invoke];
    return nil;
}

// 从struct的编码中获取struct名称{CGRect={CGPoint=dd}{CGSize=dd}}
static NSString* getFirstStructName(NSString* structEncoding){
    NSArray* parts = [structEncoding componentsSeparatedByString:@"="];
    NSString* firstPart = parts[0];
    int start = 0;
    for(int i=0; i< firstPart.length; i++){
        char c = [firstPart characterAtIndex:i];
        if(c == '{' || c == '_'){
            start ++;
        }else{
            break;
        }
    }
    return [firstPart substringFromIndex:start];
}
// 通过Associate保存属性(要引用唯一地址,动态)
static void setProperty(id invoke,SEL selector,id value,NSString* key){
    
}
static id getProperty(id invoke,SEL selector,NSString* key){
    return nil;
}
/// 接口协议或类 是否存在
static BOOL existProtocolOrClass(NSString* name){
    if (NSClassFromString(name)){
        return true;
    }
    if (NSProtocolFromString(name)){
        return true;
    }
    return false;
}

static NSString *trim(NSString *string){
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(void) test{
//    Protocol* protocol = NSProtocolFromString(@"NSCoding");
//    Protocol* protocolTable = NSProtocolFromString(@"UITableViewDelegate");
//    [XTFMylog info:[self queryProtocolMethodList:protocolTable isInstanceMethod:YES isRequiredMethod:YES]];
//    [XTFMylog info:[self queryProtocolMethodList:protocolTable isInstanceMethod:YES isRequiredMethod:NO]];
//    [XTFMylog info:[NSString stringWithUTF8String:getMethodTypesInProtocol(protocol,@"encodeWithCoder:",YES,YES)]];
    [Mylog info:usefuleTypeEncoding()];
    // 定义接口
    defineProtocol(@"XTFTextProtocol_Empty", nil);
    Protocol* xtfProtocol = objc_allocateProtocol([@"XTFTextProtocol" UTF8String]);
    // 添加方法到接口(必须在注册前添加)
    addMethodToProtocol(xtfProtocol, @"encodeWithCoder:", @"v@:@", YES);
    addMethodToProtocolByParamsType(xtfProtocol,@"encodeWithCoder:type:util:",@"NSString*,NSCoding*,int,UtilXML*",YES);
    addMethodToProtocolByParamsType(xtfProtocol,@"encodeWithCoderId:type:util:",@"id,id,int,id",YES);
    // 注册接口
    objc_registerProtocol(xtfProtocol);
    [Mylog info:[self queryProtocolMethodList:xtfProtocol isInstanceMethod:YES isRequiredMethod:YES]];
    // 定义类
    defineClass(@"UtilXTFTest",@"XTFUtilEnvironment", @[@"NSCoding", @"UITableViewDelegate"], nil);
    [Mylog info:@"################"];
    
    //[XTFMylog info: callClassMethod(@"XTFUtilRuntime",@"testClassMethod:name:util:frame:",@[@"类名+方法名+参数: 调用类方法.",@"",@"",[NSValue valueWithCGRect:CGRectZero]])];
    //[XTFMylog info:callClassMethod(@"XTFMylog",@"description",@[@"类名+方法名+参数: 调用类方法. %@,%@",@"参数二",@"参数三"])];
    [Mylog info: callClassMethod(@"XTFMylog",@"info:",@[@"类名+方法名+参数: 调用类方法."])];
}
// 运行时动态创建类
+(void)runtimeCreateClass{
    if(NSClassFromString(@"RuntimeCreateClass")) objc_disposeClassPair(NSClassFromString(@"RuntimeCreateClass"));
    Class runtimeCreateClass = objc_allocateClassPair([NSObject class], "RuntimeCreateClass", 0);//父类，类名，然后额外的空间
    //添加成员
    class_addIvar(runtimeCreateClass, @"name".UTF8String, sizeof(id), log2(sizeof(id)),@encode(id));//id类型,变量
    
    objc_property_attribute_t types = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backIvar = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { types, ownership, backIvar };
    class_addProperty(runtimeCreateClass, @"name".UTF8String, attrs, 3);//属性
    class_addProtocol(runtimeCreateClass, NSProtocolFromString(@"NSCoder"));//协议
    //注册到runtime中( 因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，同时runtime 会调用 class_setIvarLayout 或 class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量；)
    objc_registerClassPair(runtimeCreateClass);//注册后不能在改变属性
    //初始化,赋值,取值
    id cc = [runtimeCreateClass alloc];
    [cc setValue:@"XiaoTian" forKey:@"name"];
    [Mylog info:[cc valueForKey:@"name"]];
}
// 参数常见类型的C编码
static NSDictionary* usefuleTypeEncoding(){
    // 基本类型编码Type Encodings(types A C string that represents the method signature)
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    NSMutableDictionary* typeSignature = [[NSMutableDictionary alloc] init];
    [typeSignature setObject:@"@?" forKey: @"block"]; //Block anonymity function
    [typeSignature setObject:@"^@" forKey: @"id*"]; //^type: A pointer to type
    [typeSignature setObject:[NSString stringWithUTF8String: @encode(id)] forKey: @"id"];
    //宏定义:## 连接符,# 用双引号括起来
    #define typeSignatureSetType(type) [typeSignature setObject:[NSString stringWithUTF8String: @encode(type)] forKey: @#type];
    typeSignatureSetType(int);
    typeSignatureSetType(long);
    typeSignatureSetType(short);
    typeSignatureSetType(float);
    typeSignatureSetType(double);
    typeSignatureSetType(long long);
    typeSignatureSetType(unsigned int);
    typeSignatureSetType(unsigned long);
    typeSignatureSetType(unsigned short);
    typeSignatureSetType(void);
    typeSignatureSetType(char);
    typeSignatureSetType(BOOL);
    typeSignatureSetType(SEL);
    typeSignatureSetType(void*);
    typeSignatureSetType(Class);
    typeSignatureSetType(CGFloat);
    typeSignatureSetType(CGSize);
    typeSignatureSetType(CGRect);
    typeSignatureSetType(CGPoint);
    typeSignatureSetType(CGVector);
    typeSignatureSetType(NSRange);
    typeSignatureSetType(NSInteger);
    typeSignatureSetType(UIEdgeInsets);
    return typeSignature;
}
+(Mylog*) testClassMethod:(const CGFloat) weight name:(Class) name util:(UtilEnvironment*) util frame:(CGRect) frame{
    [Mylog info:@"testClassMethod:(CGFloat) weight name:(NSString*) name util:(XTFUtilEnvironment*) util frame:(CGRect) frame"];
    return nil;
}
// 一个objc对象如何进行内存布局?  所有父类的成员变量和自己的成员变量都会存放在该对象所对应的存储空间中. 每一个对象内部都有一个isa指针,指向他的类对象,类对象中存放着本对象的 对象方法列表,成员变量的列表,属性列表 它内部也有一个isa指针指向元对象(meta class),元对象内部存放的是类方法列表,类对象内部还有一个superclass的指针,指向他的父类对象。根对象就是NSobject，它的superclass指针指向nil。 类对象既然称为对象，那它也是一个实例。类对象中也有一个isa指针指向它的元类(meta class)，即类对象是元类的实例。元类内部存放的是类方法列表，根元类的isa指针指向自己，superclass指针指向NSObject类。
// 类方法: 属于类对象的,只能通过类对象调用,类方法中的self是类对象,类方法可以调用其他的类方法,类方法中不能访问成员变量,类方法中不能直接调用对象方法
// 实例方法：属于实例对象的,只能通过实例对象调用,实例方法中的self是实例对象,实例方法中可以访问成员变量,实例方法中直接调用实例方法,实例方法中也可以调用类方法(通过类名)
// 常见运算时错误:
//1.EXC_BAD_ACCESS 访问了野指针,1.对一个已经释放的对象执行了release,2.访问已经释放对象的成员变量或者发消息, 3.自循环/死循环 (最常见的是使用了assign错误属性修饰符)
//                开启Zombie Objects可以调试,他会用一个僵尸实现默认的dealloc,在反生异常时打印出消息并跳入调试器[Product->Scheme->Edit Scheme->Diagnositcs->Zombie Objects]
// autoreleasepool, autoreleasepool 以一个队列数组的形式实现,主要通过下列三个函数完成.objc_autoreleasepoolPush,objc_autoreleasepoolPop,objc_autorelease
//2.SIGSEVG 段错误信息,1.当硬件出现错误,访问不可读的内存地址,向受保护的内存地址写入数据,2.当应用中的某个指针指向不允许写操作并试图修改指向位置值时
//3.SIGBUS 总栈错误信号,1.访问的内存是一个无效地址,指向的位置根本不是物理内存地址(SIGSEVG,SIGBUS 都是EXC_BAD_ACCESS的子类型,EXC_*等同于此信号不依赖体系结构)
//4.
@end

