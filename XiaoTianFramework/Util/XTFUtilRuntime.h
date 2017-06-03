//
//  UtilRuntime.h
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTFUtilRuntime : NSObject

+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) originalSelector;

@end
