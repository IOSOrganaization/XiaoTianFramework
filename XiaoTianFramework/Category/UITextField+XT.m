//
//  UITextField+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2019/12/23.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "UITextField+XT.h"
#import <objc/runtime.h>

@implementation UITextField(XT)
/// UIControlEventValueChanged  的 Selector转换为Block
@dynamic onTextChangeCallback;
/// 设置OnTextChange的Block
- (void)setOnTextChangeCallback:(UITextFieldXTChangeCallBack)onTextChangeCallback{
    objc_setAssociatedObject(self, @selector(onTextChangeCallback), onTextChangeCallback, OBJC_ASSOCIATION_COPY);
    [self addTarget:self action:@selector(onTextChangeCallbackXT:) forControlEvents:UIControlEventValueChanged];// ValueChange
}
- (UITextFieldXTChangeCallBack)onTextChangeCallback{
    return objc_getAssociatedObject(self, @selector(onTextChangeCallback));
}
-(void)onTextChangeCallbackXT:(UITextField*)textField{
    if( self.onTextChangeCallback) self.onTextChangeCallback(textField);
}

/// Left Padding
-(void)setLeftPadding:(int)padding{
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.bounds.size.height)];
    self.leftViewMode = UITextFieldViewModeAlways;
}
/// KVC 设置占位符颜色(iOS13禁止设置,导致闪退)
- (void)setPlaceholderColor:(UIColor *)color{
    [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}
// KVC 设置占位符文本字体
- (void)setPlaceholderFont:(UIFont *)font{
    [self setValue:font forKeyPath:@"_placeholderLabel.font"];
}

-(void)test{
    [self becomeFirstResponder];//获得焦点
    [self resignFirstResponder];//失去焦点
    self.borderStyle = UITextBorderStyleRoundedRect;// 设置文本框边框(无,方框,破折线)
    self.clearsOnBeginEditing = YES;// 在开始编辑的时候清除上次余留的文本
    self.placeholder = @"Please in put your name"; // 提示输入信息
    self.clearButtonMode = UITextFieldViewModeWhileEditing;// 右侧清除按钮
    //self.inputView = view ;// 可以自定义键盘
    //self.inputAccessoryView = view;// 键盘附加视图，可以加表情的子视图 重点
    self.secureTextEntry = YES;// 密码模式,加密
    self.keyboardType = UIKeyboardTypeDefault;//设置键盘类型
    self.returnKeyType = UIReturnKeyDone;// return键名替换
    //[self addTarget:self action:@selector(tfAction) forControlEvents:UIControlEventEditingDidEndOnExit];//点击return触发
    // App Associated Domains 关联域名,自动填充账号密码
    // 1.在app管理后台证书管理页面开启关联域名服务
    // 2.在app中配置要管理的域名 Associated Domains : +添加 webcredentials:77du.net
    // 3.在账号密码登录页(系统自动识别TextField,TextField.secureTextEntry = YES为密码框)弹出键盘自动呈现自动填账号密码
}
@end
