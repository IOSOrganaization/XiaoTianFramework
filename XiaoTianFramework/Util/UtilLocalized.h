//
//  UtilLocalized.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilLocalized : NSObject

// 多语言
+(NSString*) string:(NSString*) name;
+(NSString*) string:(NSString*) name comment:(NSString* _Nullable) comment;
@end

NS_ASSUME_NONNULL_END
