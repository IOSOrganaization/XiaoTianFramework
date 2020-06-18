//
//  UITextField+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2019/12/23.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>
// Block定义
typedef void(^UITextFieldXTChangeCallBack)(UITextField* _Nonnull textField);
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UITextField(XT)
// 扩展属性
@property(copy,nonatomic)UITextFieldXTChangeCallBack onTextChangeCallback;

// 扩展方法
-(void)setLeftPadding:(int)padding;
-(void)setPlaceholderColor:(UIColor*)color;
-(void)setPlaceholderFont:(UIFont*)font;
@end

NS_ASSUME_NONNULL_END
