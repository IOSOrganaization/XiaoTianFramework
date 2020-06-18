//
//  NSString+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2019/12/6.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface NSStringMaker: NSObject
///
- (instancetype)init:(NSString*) concat;
///添加字符串
-(void)appendString:(NSString *)aString;
///添加格式化字符串
-(void)appendFormat:(NSString *)format, ...;
///链式模式,添加字符串
-(NSStringMaker* (^)(NSString*)) append;
///链式模式,添加格式化字符串
-(NSStringMaker* (^)(NSString*,...)) appendFormat;
@end

@interface NSString(XT)
// 扩展属性
// 扩展方法
-(BOOL)isMobile;
-(BOOL)isEmail;
-(BOOL)isURL;
-(BOOL)isStartWith:(NSString *)str;
-(BOOL)isEndWith:(NSString *)str;
-(BOOL)isNotNil;
-(BOOL)isNotEmpty;
-(UIColor*)colorValue;
-(NSString*)join:(void (^)(NSStringMaker* maker)) maker;
-(NSString*)trim;
@end

NS_ASSUME_NONNULL_END
