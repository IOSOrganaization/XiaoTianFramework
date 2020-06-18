//
//  CryptorSecurity.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 16/6/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//
NS_ASSUME_NONNULL_BEGIN

@interface CryptorSecurity : NSObject
/// 测试
-(void) test;
/// 根据指数exponent,模modulus, 进行RSA加密,exponent(十六进制值):指数不足6位前面补0兼容iOS9+,(padding 模式,通常为随机: kSecPaddingNone)
- (NSData *) encryptDataByRSA:(NSData *)data exponent:(NSString *) exp modulus:(NSString*) mod paddingType:(SecPadding) padding;
/// 根据公钥字符串,进行RSA加密
- (NSData *) encryptDataByRSA:(NSData *)data publicKey:(NSString *) keyStringPub paddingType:(SecPadding) padding;
- (NSData *) encryptDataByRSA:(NSData *)data pemCertKeyFile:(NSString *) publicKeyFile paddingType:(SecPadding) padding;
- (NSData *) encryptDataByRSA:(NSData *)data p12CertFile:(NSString *) p12KeyFile paddingType:(SecPadding) padding;
//- (NSData *) decryDataByRSA:(NSData *)data exponent:(NSString *) exp modulus:(NSString*) mod paddingType:(SecPadding) padding;
- (NSData *) decryDataByRSA:(NSData *)data privateKey:(NSString *) keyStringPri paddingType:(SecPadding) padding;
- (NSData *) decryDataByRSA:(NSData *)data pemCertKeyFile:(NSString *) privateKeyFile paddingType:(SecPadding) padding;
- (NSData *) decryDataByRSA:(NSData *)data p12CertFile:(NSString *) p12KeyFile paddingType:(SecPadding) padding;
// RSA Sign
- (NSString *) signDataByRSA:(NSData *)data privateKey:(NSString *) keyStringPri paddingType:(SecPadding) padding;
// HEX
- (NSString *) dataToHexString: (NSData *) data;
// Base64 编码
- (NSData *) dataToBase64Data:(NSData *)data;
- (NSData *) stringToBase64Data:(NSString *)string;
- (NSString *) dataToBase64String: (NSData *)data;
- (NSString *) stringToBase64String:(NSString *)string;
- (NSString *) dataToBase64String: (NSData *)data length: (int)length;
// Base64 解码
- (NSData *) base64DataToData:(NSData *) base64Data;
- (NSData *) base64StringToData:(NSString *)base64String;
- (NSString *) base64DataToString:(NSData *)base64Data;
- (NSString *) base64StringToString:(NSString *)base64String;
// MD5
- (NSString *) dataMD5:(NSData *) data;
- (NSString *) stringMD5:(NSString *) string;
- (NSString *) fileMD5:(NSString *) filePath;
// UUID
+(NSString*) createRandomUUID;
@end

NS_ASSUME_NONNULL_END