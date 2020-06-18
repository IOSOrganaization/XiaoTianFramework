//
//  UtilString.h
//  qiqidu
//
//  Created by XiaoTian on 2019/12/6.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilString : NSObject

+(NSString*)text:(NSString*)string;
+(NSString*) concatString:(NSArray<NSString*>*)array concat:(NSString*) concat;
+(NSString*)deviceTokenString:(NSData*)deviceToken;
@end

NS_ASSUME_NONNULL_END
