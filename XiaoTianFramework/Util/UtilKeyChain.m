//
//  UtilKeyChain.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/3.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UtilKeyChain.h"
#import <Security/Security.h>

//UtilKeyChain* _instance = nil;//没有static: 全局变量, 外部全局(app范围)变量(它会被存储在全局数据区,作用域整个app,同名会冲突,凡是定义在函数或方法之外的变量（除静态变量之外）都是外部全局变量)
static UtilKeyChain* _instance = nil;//static:静态, (内部)静态(全局:文件范围)变量(它会被存储在全局数据区,定义在文件中它的作用域就是整个文件,在方法内，它的作用域就是这方法)
//static int count = 0;//定义静态变量count，并初始化为0(不能调用方法初始化)
@implementation UtilKeyChain
+ (instancetype)share{
    static dispatch_once_t onceToken;//静态标识
    dispatch_once(&onceToken, ^{
        // 单实例(静态变量只初始化一次)
        _instance = [[UtilKeyChain alloc] init];
    });
    //static int count = 0;//静态变量只初始化一次(多次调用不初始化)
    //count++;//多次调用,一直累加
    //[Mylog info:@"count: %d", count];
    return _instance;
}
- (BOOL)addKeyChainData:(NSString*) data key:(NSString*)key {
    if (!key) return NO;//Key为空
    if (!data) return YES;//数据空
    NSData* tagData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData* tagKey = [key dataUsingEncoding:NSUTF8StringEncoding]; //KeyChain tag
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:tagKey forKey:(__bridge_transfer id)kSecAttrApplicationTag];//Tag
    [queryKey setObject:@NO forKey:(__bridge_transfer id)kSecReturnData];
    [queryKey setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
    [queryKey setObject:(__bridge_transfer id)kSecAttrKeyClassPrivate forKey:(__bridge_transfer id)kSecAttrKeyClass];
    CFTypeRef attributes;
    if (SecItemCopyMatching((CFDictionaryRef)queryKey, &attributes) == noErr){//秘钥已存在,更新
        NSMutableDictionary* updateItem = [[NSMutableDictionary alloc] init];
        [updateItem setObject:tagData forKey:(__bridge_transfer id)kSecValueData];//Value
        OSStatus status = SecItemUpdate((CFDictionaryRef)queryKey, (CFDictionaryRef)updateItem);
        if (status != noErr) {
            [Mylog info:@"更新秘钥链KeyChain失败,status=%@", [self fetchOSStatus:status]];
            return NO;
        }
    }else{
        [queryKey setObject:tagData forKey:(__bridge_transfer id)kSecValueData];//Value
        SecKeyRef persistKeyRef = nil;
        OSStatus status = SecItemAdd((__bridge_retained CFDictionaryRef) queryKey, (CFTypeRef *) &persistKeyRef);
        if (persistKeyRef != nil) CFRelease(persistKeyRef);
        if (status != noErr) {
            [Mylog info:@"添加到秘钥链KeyChain失败,status=%@", [self fetchOSStatus:status]];
            return NO;
        }
    }
    return NO;
}
- (NSString *)getKeyChainData:(NSString*) key {
    if(!key) return nil;//Key为空
    CFTypeRef tagKeyRef;
    OSStatus status = noErr;
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    NSData* tagKey = [key dataUsingEncoding:NSUTF8StringEncoding]; // KeyChain tag
    [queryKey setObject:tagKey forKey:(__bridge_transfer id)kSecAttrApplicationTag];
    [queryKey setObject:@YES forKey:(__bridge_transfer id)kSecReturnData];
    [queryKey setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
    status = SecItemCopyMatching((__bridge_retained CFDictionaryRef)queryKey, &tagKeyRef); // matching KeyChain tag
    if (status != noErr) {
        [Mylog info:@"获取秘钥链KeyChain错误: 根据秘钥Tag=%@匹配KeyChain时发生错误.%@", key, [self fetchOSStatus:status]];
        return nil;
    } else {
        NSData* tagData = (__bridge_transfer NSData*)tagKeyRef;
        return [[NSString alloc] initWithData:tagData encoding:NSUTF8StringEncoding];
    }
}
- (BOOL)deleteKeyChainData:(NSString*) key {
    if(!key) return NO;
    OSStatus status = noErr;
    NSData* keyTag = [key dataUsingEncoding:NSUTF8StringEncoding]; // KeyChain tag
    NSMutableDictionary * query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
    [query setObject:(__bridge_transfer id)kSecAttrKeyClassPrivate forKey:(__bridge_transfer id)kSecAttrKeyClass];
    [query setObject:keyTag forKey:(__bridge_transfer id)kSecAttrApplicationTag];
    status = SecItemDelete((CFDictionaryRef)query);
    if (status != noErr && status != errSecItemNotFound) {
        [Mylog info:@"删除秘钥链KeyChain:%@ 发生错误:%@", key, [self fetchOSStatus:status]];
        return nil;
    }
    return YES;
}
- (void)addAccount:(NSString*) account password:(NSString*)password identifier:(NSString*)identifier accessGroup:(NSString*)accessGroup{
    //KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number" accessGroup:@"YOUR_APP_ID_HERE.com.yourcompany.AppIdentifier"];
    //[wrapper setObject:@"<帐号>" forKey:(id)kSecAttrAccount];
    //[wrapper setObject:@"<帐号密码>" forKey:(id)kSecValueData];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:accessGroup];
    [wrapper setObject:account forKey:(id)kSecAttrAccount];
    [wrapper setObject:password forKey:(id)kSecValueData];
}
-(NSString *)getAccountIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:accessGroup];
    return [wrapper objectForKey:(id)kSecAttrAccount];
}
-(NSString *)getPasswordIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:accessGroup];
    return [wrapper objectForKey:(id)kSecValueData];
}
-(void)deleteIdentifier:(NSString*)identifier accessGroup:(NSString*)accessGroup{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:accessGroup];
    [wrapper resetKeychainItem];
}
- (NSString*) fetchOSStatus:(OSStatus)status{
    if(status == 0) return [NSString stringWithFormat:@"success (status=%d)", (int)status];
    else if(status == errSecNotAvailable) return [NSString stringWithFormat:@"no trust results available (status=%d)", (int)status];
    else if(status == errSecItemNotFound) return [NSString stringWithFormat:@"the item cannot be found (status=%d)", (int)status];
    else if(status == errSecParam) return [NSString stringWithFormat:@"parameter error (status=%d)", (int)status];
    else if(status == errSecAllocate) return [NSString stringWithFormat:@"memory allocation error (status=%d)", (int)status];
    else if(status == errSecInteractionNotAllowed) return [NSString stringWithFormat:@"user interaction not allowd (status=%d)", (int)status];
    else if(status == errSecUnimplemented) return [NSString stringWithFormat:@"not implemented (status=%d)", (int)status];
    else if(status == errSecDuplicateItem) return [NSString stringWithFormat:@"item already exists (status=%d)", (int)status];
    else if(status == errSecDecode) return [NSString stringWithFormat:@"unable to decode data (status=%d)", (int)status];
    else return [NSString stringWithFormat:@"unknow error (status=%d)", (int)status];
}
@end

@interface KeychainItemWrapper (PrivateMethods)
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
- (void)writeToKeychain;
@end

@implementation KeychainItemWrapper
@synthesize keychainItemData, genericPasswordQuery;

- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup{
    if (self = [super init]){
        genericPasswordQuery = [[NSMutableDictionary alloc] init];
        [genericPasswordQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [genericPasswordQuery setObject:identifier forKey:(id)kSecAttrGeneric];
        if (accessGroup != nil){
#if TARGET_IPHONE_SIMULATOR
            // SecItemAdd and SecItemUpdate on the simulator will return -25243 (errSecNoAccessForItem).
#else
            [genericPasswordQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
        }
        [genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [genericPasswordQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];
        CFTypeRef outDictionary;
        if (!(SecItemCopyMatching((CFDictionaryRef)tempQuery, &outDictionary) == noErr)){
            // Stick these default values into keychain item if nothing found.
            [self resetKeychainItem];
            // Add the generic attribute and the keychain access group.
            [keychainItemData setObject:identifier forKey:(id)kSecAttrGeneric];
            if (accessGroup != nil) {
#if TARGET_IPHONE_SIMULATOR
                //simulator will return -25243 (errSecNoAccessForItem).
#else
                [keychainItemData setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
            }
        } else{
            // load the saved data from Keychain.
            self.keychainItemData = [self secItemFormatToDictionary:(__bridge_transfer NSMutableDictionary*)outDictionary];
        }
    }
    return self;
}
- (void)setObject:(id)inObject forKey:(id)key{
    if (inObject == nil) return;
    id currentObject = [keychainItemData objectForKey:key];
    if (![currentObject isEqual:inObject]){
        [keychainItemData setObject:inObject forKey:key];
        [self writeToKeychain];
    }
}
- (id)objectForKey:(id)key{
    return [keychainItemData objectForKey:key];
}
- (void)resetKeychainItem{
    OSStatus junk = noErr;
    if (!keychainItemData){
        self.keychainItemData = [[NSMutableDictionary alloc] init];
    }else if (keychainItemData){
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:keychainItemData];
        junk = SecItemDelete((CFDictionaryRef)tempDictionary);
        NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary." );
    }
    [keychainItemData setObject:@"" forKey:(id)kSecAttrAccount];
    [keychainItemData setObject:@"" forKey:(id)kSecAttrLabel];
    [keychainItemData setObject:@"" forKey:(id)kSecAttrDescription];
    [keychainItemData setObject:@"" forKey:(id)kSecValueData];
}
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    [returnDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    CFTypeRef passwordData;
    if (SecItemCopyMatching((CFDictionaryRef)returnDictionary, &passwordData) == noErr){
        [returnDictionary removeObjectForKey:(id)kSecReturnData];
        NSData* data = (__bridge_transfer NSData*)passwordData;
        NSString *password = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        [returnDictionary setObject:password forKey:(id)kSecValueData];
    }else{
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }
    return returnDictionary;
}
- (void)writeToKeychain{
    CFTypeRef attributes;
    NSMutableDictionary *updateItem = NULL;
    OSStatus result;
    if (SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, &attributes) == noErr){//已存在,更新
        [Mylog info:@"已存在,更新"];
        // 1. we need the attributes from the Keychain.
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary*) attributes];
        // 2. we need to add the appropriate search key/values.
        [updateItem setObject:[genericPasswordQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];
        // 3. we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:keychainItemData];
        [tempCheck removeObjectForKey:(id)kSecClass];
#if TARGET_IPHONE_SIMULATOR
        [tempCheck removeObjectForKey:(id)kSecAttrAccessGroup];
#endif
        result = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)tempCheck);
        NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    }else{
        [Mylog info:@"不存在,新增"];
        result = SecItemAdd((CFDictionaryRef)[self dictionaryToSecItemFormat:keychainItemData], NULL);
        [Mylog info:[self fetchOSStatus:result]];
        NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    }
}
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    NSString *passwordString = [dictionaryToConvert objectForKey:(id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];//Convert the NSString to NSData
    return returnDictionary;
}
- (NSString*) fetchOSStatus:(OSStatus)status{
    if(status == 0) return [NSString stringWithFormat:@"success (status=%d)", (int)status];
    else if(status == errSecNotAvailable) return [NSString stringWithFormat:@"no trust results available (status=%d)", (int)status];
    else if(status == errSecItemNotFound) return [NSString stringWithFormat:@"the item cannot be found (status=%d)", (int)status];
    else if(status == errSecParam) return [NSString stringWithFormat:@"parameter error (status=%d)", (int)status];
    else if(status == errSecAllocate) return [NSString stringWithFormat:@"memory allocation error (status=%d)", (int)status];
    else if(status == errSecInteractionNotAllowed) return [NSString stringWithFormat:@"user interaction not allowd (status=%d)", (int)status];
    else if(status == errSecUnimplemented) return [NSString stringWithFormat:@"not implemented (status=%d)", (int)status];
    else if(status == errSecDuplicateItem) return [NSString stringWithFormat:@"item already exists (status=%d)", (int)status];
    else if(status == errSecDecode) return [NSString stringWithFormat:@"unable to decode data (status=%d)", (int)status];
    else return [NSString stringWithFormat:@"unknow error (status=%d)", (int)status];
}
@end
