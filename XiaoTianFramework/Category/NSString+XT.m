//
//  NSString+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2019/12/6.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "NSString+XT.h"

@implementation NSString(XT)
/// 空字符串
-(BOOL)isEmpty{
    return self.length == 0;
}
/// 空或空字符串
-(BOOL)isNotNull{
    return nil != self && ![self isEqual:[NSNull null]] && self.length > 0;
}
/// 是否是手机电话号码13位号码(国内手机,不准)
-(BOOL)isMobile{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}
/// 是否是合法Email格式
-(BOOL)isEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
/// 是否合法URL格式(http:// 或 https://)
-(BOOL)isURL{
    if([self isStartWith:@"http://"]) return true;
    if([self isStartWith:@"https://"]) return true;
    return false;
}
/// 以指定字符串开始
-(BOOL)isStartWith:(NSString *)str{
    NSRange rang =  [self rangeOfString:str];
    if(rang.length == 0){
        return NO;
    }else{
        return rang.location == 0;
    }
}
/// 以指定字符串结尾
-(BOOL)isEndWith:(NSString *)str{
    NSRange rang =  [self rangeOfString:str];
    if(rang.length == 0){
        return NO;
    }else{
        return (rang.location + rang.length) == self.length;
    }
}
/// 字符介入
-(NSString*)join:(void (^)(NSStringMaker* maker)) maker{
    NSStringMaker* text = [[NSStringMaker alloc] init:self];
    maker(text);
    return text.description;
}
/// 非空 / 非nil / 非NSNull 字符串
- (BOOL)isNotNil{
    if(!self) return NO;
    if(self.length < 1) return NO;
    if([self isEqual:[NSNull null]]) return NO;//JSON序列化空对象
    return YES;
}
/// 非空字符串
- (BOOL)isNotEmpty{
    if(!self) return NO;
    if(self.length < 1) return NO;
    return YES;
}
/// 6位/8位 色码字符串转换为颜色: #FFFFFF, #FFFFFFFF
-(UIColor*)colorValue{
    NSString *cString = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    NSRange range;
    NSString *rString;
    NSString *gString;
    NSString *bString;
    NSString *aString;
    range.location = 0;
    range.length = 2;
    if ([cString length] == 6){
        rString = [cString substringWithRange:range];
        range.location = 2;
        gString = [cString substringWithRange:range];
        range.location = 4;
        bString = [cString substringWithRange:range];
        aString = @"FF";
    }else if([cString length] == 8){
        aString = [cString substringWithRange:range];
        range.location = 2;
        rString = [cString substringWithRange:range];
        range.location = 4;
        gString = [cString substringWithRange:range];
        range.location = 5;
        bString = [cString substringWithRange:range];
    }else if([cString length] == 3){
        range.length = 1;
        NSString* single;
        single = [cString substringWithRange:range];
        rString = [NSString stringWithFormat:@"%@%@", single,single];
        range.location = 1;
        single = [cString substringWithRange:range];
        gString = [NSString stringWithFormat:@"%@%@", single,single];
        range.location = 2;
        single = [cString substringWithRange:range];
        bString = [NSString stringWithFormat:@"%@%@", single,single];
        aString = @"FF";
    }else{
         return [UIColor clearColor];
    }
    // Scan values
    unsigned int a,r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float) a / 255.0f)];
}
- (NSString *)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end

/// 字符串拼接
@implementation NSStringMaker{
    NSMutableString* text;
    NSString* split;
}
- (instancetype)init:(NSString*) concat{
    self = [super init];
    if (self) {
        split = concat;
    }
    return self;
}
-(void)appendString:(NSString *)aString{
    if(![aString isNotNull]) return;
    //[Mylog info:[NSString stringWithFormat:@"添加文本:%@" ,aString]];
    if(!text){
        text = [[NSMutableString alloc] init];
        [text appendString:aString];
    }else{
        [text appendString:split];
        [text appendString:aString];
    }
}
-(void)appendFormat:(NSString *)format, ...{
    va_list list;
    va_start(list, format);//宏读取不定参数(创建指向不定参指针)
    [self appendString:[[NSString alloc] initWithFormat:format arguments:list]];
    va_end(list);//宏结束读取不定参数(释放指针)
}
-(NSStringMaker* (^)(NSString*)) append{
    return ^id(NSString* string){
        [self appendString:string];
        return self;
    };
}
-(NSStringMaker* (^)(NSString*,...)) appendFormat{
    return ^id(NSString*format,...){//不定参数转传不行
        va_list list;
        va_start(list, format);//宏读取不定参数(创建指向不定参指针)
        [self appendString:[[NSString alloc] initWithFormat:format arguments:list]];
        va_end(list);//宏结束读取不定参数(释放指针)
        return self;
    };
}
-(NSString*) description{
    return text;
}
@end
