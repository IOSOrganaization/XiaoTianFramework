//
//  UtilString.m
//  qiqidu
//
//  Created by XiaoTian on 2019/12/6.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "UtilString.h"
#import "NSString+XT.h"

@implementation UtilString

/// 返回文本(如果是nil则返回"")
+ (NSString *)text:(NSString *)string{
    return string ? [string isEqual:[NSNull null]] ? @"" : string : @"";
}

+ (NSString *)concatString:(NSArray<NSString *> *)array concat:(NSString *)concat{
    if(!array || array.count < 1) return @"";
    NSMutableString* text = [[NSMutableString alloc] init];
    for (int i= 0; i < array.count; i++) {
        NSObject* item = array[i];
        if(item && [item isKindOfClass:[NSString class]]){
            NSString* is = (NSString*)item;
            if (is.length > 0){
                [text appendString: (NSString*)item];
                if(i + 1 < array.count) [text appendString: concat];
            }
        }
    }
    return text;
}
+(NSString*)deviceTokenString:(NSData*)deviceToken{
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSUInteger iCount = deviceToken.length;
    for (int i = 0; i < iCount; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    return deviceTokenString;
}
@end
