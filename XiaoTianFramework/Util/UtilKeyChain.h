//
//  UtilKeyChain.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/3.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilKeyChain : NSObject
/// 全局单例
+(instancetype) share;
/// 添加数据到KeyChain中 (如果更新了provisioning profile的话, Keychain data会丢失)
- (BOOL) addKeyChainData:(NSString* _Nullable)data key:(NSString*)key;
/// 从KeyChain中获取NSData数据
- (NSString*)getKeyChainData:(NSString*) keyChainTag;
/// 删除KeyChain的数据
- (BOOL)deleteKeyChainData:(NSString*) key;

//
/// 保存登录用户名密码
- (void)addAccount:(NSString*) account password:(NSString*)password identifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;
/// 获取登录用户名密码
-(NSString *)getAccountIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;
-(NSString *)getPasswordIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;
/// 删除登录用户名密码
-(void)deleteIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup;
@end

@interface KeychainItemWrapper : NSObject{
NSMutableDictionary *keychainItemData; // The actual keychain item data backing store.
NSMutableDictionary *genericPasswordQuery; // A placeholder for the generic keychain item query used to locate the item.
}
@property (nonatomic, retain) NSMutableDictionary *keychainItemData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;
/// Designated initializer.
- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup;
/// Save value for key
- (void)setObject:(id)inObject forKey:(id)key;
/// Read value by key
- (id)objectForKey:(id)key;
/// Initializes and resets the default generic keychain item data.
- (void)resetKeychainItem;
@end

NS_ASSUME_NONNULL_END
