//
//  Constants.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

// 宏定义
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define isIPhoneX [[UIScreen mainScreen] bounds].size.width >=375.0f && [[UIScreen mainScreen] bounds].size.height >=812.0f
#define bottomBarHeight 34
#define statuBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define rectContent CGRectMake(0, statuBarHeight+44, screenWidth, screenHeight-statuBarHeight-44)

// 常量
UIKIT_EXTERN NSString *const DIVICE_ID;
