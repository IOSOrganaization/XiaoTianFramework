//
//  Constants.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "ConstantsXT.h"

// 宏定义(编译器替换)
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define isIPhoneX [[UIScreen mainScreen] bounds].size.width >=375.0f && [[UIScreen mainScreen] bounds].size.height >=812.0f
#define bottomBarHeight 34
#define statuBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define rectContent CGRectMake(0, statuBarHeight+44, screenWidth, screenHeight-statuBarHeight-44)
// 匿名函数
typedef void (^XTAnonymityBlock)(void);

// 全局静态常量(全局引用,声明对外开放,整个App唯一)
UIKIT_EXTERN NSString* const VERSION_XT;//UIKIT_EXTERN,FOUNDATION_EXTERN,FOUNDATION_EXPORT,FOUNDATION_IMPORT 指定框架外变量(编译(编译命名)方式,编译变量可见性跟随框架)
extern NSString* const VERSION_XT_NAME;//系统默认: 编译方式,可见性(extern:外部的, 声明是其他已经定义好的全局常量)
//NSString* const VERSION_XT_NAME = @"";//头定义全局变量,多次/多文件引入头会重复冲突(import的作用是把头文件中的内容进行拷贝)

