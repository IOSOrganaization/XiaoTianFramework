//
//  SerializerJson.h
//  XiaoTianFramework
//  Json字符串->实体,实体->Json字符串
//  Created by XiaoTian on 16/6/28.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

@interface SerializerJson : NSObject
// 序列化对象
-(NSData *) serializing:(NSObject *) objectData;

// 反序化对象
-(id) deSerializing:(NSData *) jsonData clazz:(Class) clazz;
-(id) deSerializing:(NSData *) jsonData;
-(id) deSerializingObject:(NSDictionary *) dictionary clazz:(Class) clazz;
-(id) deSerializingArrayObject:(NSArray *) array clazz:(Class) clazz;

// 格式化JSON Data
-(NSData *) formatJSONData:(NSData *) jsonData;
@end
