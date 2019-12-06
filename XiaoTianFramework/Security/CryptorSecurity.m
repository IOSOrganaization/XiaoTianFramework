//
//  XTFCryptorSecurity.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 16/6/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

#import "CryptorSecurity.h"
#import "BasicEncodingRules.h"
#import "Mylog.h"
#include <CommonCrypto/CommonCrypto.h>

// Base 64 Encode/Decode

@implementation CryptorSecurity

- (void) test {
    /*
     登陆密码自动缓冲到本地APP[自动登录],所以采用加密的方式存储:
     1.密码采用UTF-8转为Base64后通过RSA密钥加密后保存密文在本地文件,\
     当需要自动登录时自动获取密文计算MD5作为登录密码
     
     2.RSA加密参数:
     模:bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07
     公匙的指数:10001
     私匙的指数:88741cf7500c0ef43125d5fa1c3df8e9ae5859791efce3a8b73d5538eeba9be1bc71f90d109b7941bd19605f8e89619e77ea626d9c53557cb193e0e7cfe6eb6c437a3c0967dc5e9d6313c5e8ba6b058078763359cf4bda21472e54e5f856a79943057ad4ffd748e40dc617a1f23b179e7b9937955a8c7cdc0b58897a55948961
     
     3.案例[RSA算码器采用随机填充模式],请参考案例结果进行调试:
     明文:123456
     密文:7493D9ADE81BBC26B6B200545124F7CA24F964590E87A07F56D5BBCEA8BB03BE66F9B1D558E755C00095B029450FF30FCC7611E209CADE2A669D24492C2D3303D0FB660DF6ACE9AAB8107DE03E74D3F835AFF486A061F3F8A0D6CBBB5438D8210DFC0D1C9CA5441DA7C626BD93D81E4C52FD9723BBFF73C0C96788260ED8BE34
     密码:0428e4e99a05652a0c7cdbc3e99be06a
     */
    //
    NSData * d = [self encryptDataByRSA:[self dataToBase64Data:[@"123456" dataUsingEncoding:NSUTF8StringEncoding]] exponent:@"010001" modulus:@"bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07" paddingType:kSecPaddingNone];
    [Mylog info:@"RSA加密后的Hex结果:%@",[self dataToHexString:d]];
    [Mylog info:@"RSA加密后的MD5结果:%@",[self stringMD5:[self dataToHexString:d]]];
    NSData *s = [self decryDataByRSA:d exponent:@"88741cf7500c0ef43125d5fa1c3df8e9ae5859791efce3a8b73d5538eeba9be1bc71f90d109b7941bd19605f8e89619e77ea626d9c53557cb193e0e7cfe6eb6c437a3c0967dc5e9d6313c5e8ba6b058078763359cf4bda21472e54e5f856a79943057ad4ffd748e40dc617a1f23b179e7b9937955a8c7cdc0b58897a55948961" modulus:@"bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07" paddingType:kSecPaddingNone];
    [Mylog info:@"RSA解密结果:%@",[[NSString alloc] initWithData:s encoding:NSUTF8StringEncoding]];
    [self pem];
    // 生成秘钥对
    //[self generateKeyPairWithPublicTag:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test" privateTag: @"com.xiaotian.XTCryptorSecurity.RSA_PriKey\test" keyBits:1024];
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test"];
//    NSString *pubKeyHex = [self dataToBase64String:[self getKeyChainBits:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test"]];
//    NSString *priKeyHex = [self dataToBase64String:[self getKeyChainBits:@"com.xiaotian.XTCryptorSecurity.RSA_PriKey\test"]];
//    [Mylog info:pubKeyHex];
//    [Mylog info:priKeyHex];
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test"];
    //[self pem];
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test"];
    
}
/// 根据指数,模进行RSA加密,exponent(十六进制值):指数不足6位前面补0兼容iOS9+,(padding 模式,通常为随机: kSecPaddingNone)
-(NSData *) encryptDataByRSA:(NSData *)data exponent:(NSString*) exponent modulus:(NSString*) modulus paddingType:(SecPadding) padding {
    // 指数+模,生成秘钥的二进制数据(exponent:必须六位,不足要前面补0)
    NSData* publicKeyData = [self createBerRSAData:[self hexStringToData:exponent] modulus:[self hexStringToData:modulus]];
    SecKeyRef key = [self addNewPublicKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey" publicKeyData:publicKeyData];
    if (key) {
        return [self encryptDataByRSA:data withKeyRef:key paddingType:padding];
    }
    return NULL;
}
/// 根据公钥,进行RSA加密
-(NSData *) encryptDataByRSA:(NSData *)data publicKey:(NSString *) keyStringPub paddingType:(SecPadding) padding{
    // 过滤出完整前后声明Public Key字符串
    NSString *keyPubPurity = nil;
    NSRange spospu = [keyStringPub rangeOfString:@"-----BEGIN RSA PUBLIC KEY-----"];
    NSRange epospu;
    if(spospu.length > 0){
        epospu = [keyStringPub rangeOfString:@"-----END RSA PUBLIC KEY-----"];
    } else {
        spospu = [keyStringPub rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
        epospu = [keyStringPub rangeOfString:@"-----END PUBLIC KEY-----"];
    }
    if(spospu.location == NSNotFound || epospu.location == NSNotFound){
        [Mylog info:@"通过-----BEGIN RSA PUBLIC KEY----- 或 -----BEGIN PUBLIC KEY-----截取公钥字符串失败."];
        return nil;
    }
    // 截取秘钥内容
    NSUInteger start = spospu.location + spospu.length;
    NSUInteger end = epospu.location;
    keyPubPurity = [keyStringPub substringWithRange: NSMakeRange(start, end - start)];
    // 清除无效字符
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // Public Key 进行Base64解码,获取RSA秘钥的二进制
    NSData *publicKeyData = [self base64StringToData: keyPubPurity];
    
    // 过滤RSA公钥头声明 Skip ASN.1 public key header
    unsigned long len = [publicKeyData length];
    unsigned char *c_key = (unsigned char *)[publicKeyData bytes];
    unsigned int  idx     = 0;
    if (c_key[idx++] == 0x30) {
        if (c_key[idx] > 0x80) {
            idx += c_key[idx] - 0x80 + 1;
        } else {
            idx++;
        }
        // PKCS #1 rsaEncryption szOID_RSA_RSA
        static unsigned char seqiod[] = {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00};
        if (!memcmp(&c_key[idx], seqiod, 15)) {
            idx += 15;
            if (c_key[idx++] == 0x03) {
                if (c_key[idx] > 0x80) {
                    idx += c_key[idx] - 0x80 + 1;
                } else {
                    idx++;
                }
                if (c_key[idx++] == '\0') {
                    // Now make a new NSData from this buffer
                    publicKeyData = ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
                } else {
                    [Mylog info:@"编码错误: RSA PKCS #1后续头结束位\0读取错误."];
                    return nil;
                }
            } else {
                [Mylog info:@"编码错误: RSA PKCS #1后必须以0x03开始."];
                return nil;
            }
        } else {
            [Mylog info:@"编码错误: RSA PKCS #1 匹配失败."];
            return nil;
        }
    } else {
        [Mylog info:@"编码错误: RSA 秘钥必须以0x30开始."];
        return nil;
    }
    //[Mylog info:@"过滤声明字段后的公钥数据(添加到系统秘钥链中) Data:\n%@", [self dataToHexString:keyDataPub]];
    // keychain 添加公钥数据到秘钥链,获取公钥引用
    SecKeyRef key = [self addNewPublicKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey" publicKeyData:publicKeyData];
    if (key) {
        // 获取到公钥引用开始编码
        return [self encryptDataByRSA:data withKeyRef:key paddingType:padding];
    }else{
         [Mylog info:@"编码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", @"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    }
    return nil;
}
/// 根据公钥文件,进行RSA加密
- (NSData *) encryptDataByRSA:(NSData *)data pemCertKeyFile:(NSString *) publicKeyFile paddingType:(SecPadding) padding{
    // 该公钥文件必须为pem[通过Base64形式保存的秘钥]
    NSString* publicKey = [NSString stringWithContentsOfFile:publicKeyFile encoding:NSUTF8StringEncoding error:nil];
    return [self encryptDataByRSA:data publicKey:publicKey paddingType:padding];
}
/// 根据公钥p12文件,进行RSA加密
- (NSData *) encryptDataByRSA:(NSData *)data p12CertFile:(NSString *) p12KeyFile paddingType:(SecPadding) padding{
    NSData* p12Data = [NSData dataWithContentsOfFile:p12KeyFile];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (CFDataRef) p12Data);
    SecKeyRef key = NULL;//指针类型空:NULL,id类型空:nil
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    if (cert != NULL){
        policy = SecPolicyCreateBasicX509();
        if (policy){
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr){
                SecTrustResultType result;
                OSStatus status = SecTrustEvaluate(trust, &result);
                if(status != noErr) {
                    [Mylog info:@"编码错误: 获取证书值失败.%@", [self fetchOSStatus:status]];
                    return nil;
                }
                if (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified){
                    key = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    if (key) {
        // 获取到公钥引用开始用公钥编码
        return [self decryptDataByRSA:data withKeyRef:key paddingType:padding];
    }else{
        [Mylog info:@"编码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", @"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    }
    return nil;
}
/// 指数,模进行
-(NSData *) decryDataByRSA:(NSData *)data exponent:(NSString *) exponent modulus:(NSString*) modulus paddingType:(SecPadding) padding{
    // 指数+模,生成秘钥的二进制数据(exponent:必须六位,不足要前面补0)
    NSData* privateKeyData = [self createBerRSAData:[self hexStringToData:exponent] modulus:[self hexStringToData:modulus]];
    SecKeyRef key = [self addNewPrivateKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PrivKey" privateKeyData:privateKeyData];
    if (key) {
        return [self decryptDataByRSA:data withKeyRef:key paddingType:padding];
    }
    return NULL;
}
/// 根据私钥,进行RSA解密
-(NSData *) decryDataByRSA:(NSData *)data privateKey:(NSString *) keyStringPri paddingType:(SecPadding) padding{
    // 过滤出完整Private Key字符串
    NSRange spospri = [keyStringPri rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epospri;
    if (spospri.length > 0) {
        epospri = [keyStringPri rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    } else {
        spospri = [keyStringPri rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
        epospri = [keyStringPri rangeOfString:@"-----END PRIVATE KEY-----"];
    }
    if (spospri.location == NSNotFound && epospri.location == NSNotFound) {
        [Mylog info:@"解码错误: 通过-----BEGIN RSA PRIVATE KEY-----或-----BEGIN PRIVATE KEY-----截取私钥字符串失败."];
        return nil;
    }
    // 截取
    NSString *keyPriPurity = nil;
    NSUInteger start = spospri.location + spospri.length;
    NSUInteger end = epospri.location;
    NSRange rangep = NSMakeRange(start, end - start);
    keyPriPurity = [keyStringPri substringWithRange:rangep];
    // 清除无效字符
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // Private Key 进行Base64编码,后续对Base64结果码进行操作
    NSData *privateKeyData = [self base64StringToData:keyPriPurity];
    //[Mylog info:[self dataToHexString:keyDataPri]];
    // 过滤RSA私钥头声明 Skip ASN.1 public key header
    unsigned long lenp = [privateKeyData length];
    unsigned char *c_keyp = (unsigned char *)[privateKeyData bytes];
    unsigned int idxp = 22; // 从22位开始 magic byte at offset 22
    if (0x04 == c_keyp[idxp++]) {
        //calculate length of the key
        unsigned int c_len = c_keyp[idxp++];
        int det = c_len & 0x80;
        if (!det) {
            c_len = c_len & 0x7f;
        } else {
            int byteCount = c_len & 0x7f;
            if (byteCount + idxp > lenp) {
                //rsa length field longer than buffer
                [Mylog info:@"解码错误:RSA私钥的字段长度大于缓存值."];
                return nil;
            }
            unsigned int accum = 0;
            unsigned char *ptr = &c_keyp[idxp];
            idxp += byteCount;
            while (byteCount) {
                accum = (accum << 8) + *ptr;
                ptr++;
                byteCount--;
            }
            c_len = accum;
        }
        // Now make a new NSData from this buffer
        privateKeyData = [privateKeyData subdataWithRange:NSMakeRange(idxp, c_len)];
    } else {
        [Mylog info:@"解码错误: 私钥的第22位必须为0x04.pkb64[22]=0x%02X",c_keyp[--idxp]];
        return nil;
    }
    // 添加私钥数据到秘钥链,得到私钥引用
    SecKeyRef key = [self addNewPrivateKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PrivKey" privateKeyData:privateKeyData];
    if (key) {
        // 获取到私钥引用开始用私钥解码
        return [self decryptDataByRSA:data withKeyRef:key paddingType:padding];
    }else{
        [Mylog info:@"解码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", @"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    }
    return nil;
}
/// 根据私钥文件,进行RSA解密
- (NSData *) decryDataByRSA:(NSData *)data pemCertKeyFile:(NSString *) privateKeyFile paddingType:(SecPadding) padding{
    // 该公钥文件必须为pem[通过Base64形式保存的秘钥]
    NSString* privateKey = [NSString stringWithContentsOfFile:privateKeyFile encoding:NSUTF8StringEncoding error:nil];
    return [self decryDataByRSA:data privateKey:privateKey paddingType:padding];
}
/// 根据私钥p12文件,进行RSA解密
- (NSData *) decryDataByRSA:(NSData *)data p12CertFile:(NSString *) p12KeyFile password:(NSString*)password paddingType:(SecPadding) padding{
    NSData* p12Data = [NSData dataWithContentsOfFile:p12KeyFile];
    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    SecKeyRef privateKeyRef = NULL;
    //change to the actual password you used here
    [options setObject:password forKey:(id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((CFDataRef)p12Data, (CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0){
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr){
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    if (privateKeyRef) {
        // 获取到私钥引用开始用公私解码
        return [self decryptDataByRSA:data withKeyRef:privateKeyRef paddingType:padding];
    }else{
        [Mylog info:@"解码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", @"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    }
    return nil;
}
/// 根据私钥,执行RSA签名,返回签名的Base64
- (NSString *) signDataByRSA:(NSData *)data privateKey:(NSString *) keyStringPri paddingType:(SecPadding) padding{
    // 过滤出完整Private Key字符串
    NSRange spospri = [keyStringPri rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epospri;
    if (spospri.length > 0) {
        epospri = [keyStringPri rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    } else {
        spospri = [keyStringPri rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
        epospri = [keyStringPri rangeOfString:@"-----END PRIVATE KEY-----"];
    }
    if (spospri.location == NSNotFound && epospri.location == NSNotFound) {
        [Mylog info:@"签名错误: 通过-----BEGIN RSA PRIVATE KEY-----或-----BEGIN PRIVATE KEY-----截取私钥字符串失败."];
        return nil;
    }
    // 截取
    NSString *keyPriPurity = nil;
    NSUInteger start = spospri.location + spospri.length;
    NSUInteger end = epospri.location;
    NSRange rangep = NSMakeRange(start, end - start);
    keyPriPurity = [keyStringPri substringWithRange:rangep];
    // 清除无效字符
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@" "  withString:@""];
    // Private Key 进行Base64编码,后续对Base64结果码进行操作
    NSData *privateKeyData = [self base64StringToData:keyPriPurity];
    //[Mylog info:[self dataToHexString:keyDataPri]];
    // 过滤RSA私钥头声明 Skip ASN.1 public key header
    unsigned long lenp = [privateKeyData length];
    unsigned char *c_keyp = (unsigned char *)[privateKeyData bytes];
    unsigned int idxp = 22; // 从22位开始 magic byte at offset 22
    if (0x04 == c_keyp[idxp++]) {
        //calculate length of the key
        unsigned int c_len = c_keyp[idxp++];
        int det = c_len & 0x80;
        if (!det) {
            c_len = c_len & 0x7f;
        } else {
            int byteCount = c_len & 0x7f;
            if (byteCount + idxp > lenp) {
                //rsa length field longer than buffer
                [Mylog info:@"签名错误:RSA私钥的字段长度大于缓存值."];
                return nil;
            }
            unsigned int accum = 0;
            unsigned char *ptr = &c_keyp[idxp];
            idxp += byteCount;
            while (byteCount) {
                accum = (accum << 8) + *ptr;
                ptr++;
                byteCount--;
            }
            c_len = accum;
        }
        // Now make a new NSData from this buffer
        privateKeyData = [privateKeyData subdataWithRange:NSMakeRange(idxp, c_len)];
    } else {
        [Mylog info:@"签名错误: 私钥的第22位必须为0x04.pkb64[22]=0x%02X",c_keyp[--idxp]];
        return nil;
    }
    // 添加私钥数据到秘钥链,得到私钥引用
    SecKeyRef key = [self addNewPrivateKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PrivKey" privateKeyData:privateKeyData];
    if (key) {
        // 获取到私钥引用开始用私钥签名
        uint8_t *signedHashBytes = NULL;
        // calculate private key size
        size_t signedHashBytesSize = SecKeyGetBlockSize(key);
        // create space to put signature
        signedHashBytes = (uint8_t *)malloc(signedHashBytesSize * sizeof(uint8_t));
        memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
        OSStatus status;
        // sign data
        switch (padding) {
            case kSecPaddingPKCS1MD2:{
                uint8_t digest[CC_MD2_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1MD2,digest,CC_MD2_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1MD5:{
                uint8_t digest[CC_MD5_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1MD5,digest,CC_MD5_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1SHA1:{
                uint8_t digest[CC_SHA1_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1SHA1,digest,CC_SHA1_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1SHA224:{
                uint8_t digest[CC_SHA224_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1SHA224,digest,CC_SHA224_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1SHA256:{
                uint8_t digest[CC_SHA256_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1SHA256,digest,CC_SHA256_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1SHA384:{
                uint8_t digest[CC_SHA384_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1SHA384,digest,CC_SHA384_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            case kSecPaddingPKCS1SHA512:{
                uint8_t digest[CC_SHA512_DIGEST_LENGTH];
                CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
                status = SecKeyRawSign(key,kSecPaddingPKCS1SHA512,digest,CC_SHA512_DIGEST_LENGTH,signedHashBytes,&signedHashBytesSize);
                break;
            }
            default:
                status = -1;
                [Mylog info:@"签名错误: SecPadding必须为[kSecPaddingPKCS1MD2,kSecPaddingPKCS1MD5,kSecPaddingPKCS1SHA1/224/256/384/512]"];
                break;
        }
        if (status != errSecSuccess) {
            [Mylog info:@"签名错误: ", [self fetchOSStatus:status]];
            return nil;
        }
        // get signature hash
        NSData *signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
        if (key)CFRelease(key);
        // release created space
        if (signedHashBytes)free(signedHashBytes);
        // return Base64 encoded signature string
        return [self dataToBase64String:signedHash];
    }else{
        [Mylog info:@"编码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", @"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    }
    return nil;
}
- (void) pem {
    NSError *error;
    //NSString *keyStringPub = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"pem"] encoding:NSUTF8StringEncoding error:&error];
    //NSString *keyStringPri = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"pem"] encoding:NSUTF8StringEncoding error:&error];
    NSString *keyStringPub = @"-----BEGIN PUBLIC KEY-----\n\
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCDoA9biOxsvffmsK8Vl6mbSNC\n\
    bRPXErrrgGJJGZwoVEt2pCaeHiehk1kV+xuqkYegO9VfJB49ABqgROlDzTGJZG8c\n\
    PqZ6Vah4ecUTg4ilEHJMwQhIdTgb43G8U7J3UWRrUCna9Gz/UdKradrQoPG5X1wa\n\
    4Y0FwgyvQeH5x2sRrQIDAQAB\n\
    -----END PUBLIC KEY-----";
    NSString *exponent = @"010001";
    NSString *modulus = @"C20E803D6E23B1B2F7DF9AC2BC565EA66D23426D13D712BAEB806249199C28544B76A4269E1E27A1935915FB1BAA9187A03BD55F241E3D001AA044E943CD3189646F1C3EA67A55A87879C5138388A510724CC1084875381BE371BC53B27751646B5029DAF46CFF51D2AB69DAD0A0F1B95F5C1AE18D05C20CAF41E1F9C76B11AD";
    //
    NSString *keyStringPri = @"-----BEGIN PRIVATE KEY-----\n\
    MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMIOgD1uI7Gy99+a\n\
    wrxWXqZtI0JtE9cSuuuAYkkZnChUS3akJp4eJ6GTWRX7G6qRh6A71V8kHj0AGqBE\n\
    6UPNMYlkbxw+pnpVqHh5xRODiKUQckzBCEh1OBvjcbxTsndRZGtQKdr0bP9R0qtp\n\
    2tCg8blfXBrhjQXCDK9B4fnHaxGtAgMBAAECgYAKqaNQPMoHTI8kISvMD27Z9Cs4\n\
    zieF7MiKgh5kZ9zVtnQDC9f3Xi7NSPxfIdIOWDq8ii0aMjDbJzNPVRoAGLk8+6/h\n\
    mTRTjKu4LDVAJ5VGrwd4z6LuyKX7VsaNkRtMy02MFAwqA4qXzcnQocNoTMWaD+RN\n\
    Em64Gl1FiW0HpVDtoQJBAP0CtHJ92x4sT5tgkANbDqhLpiyNbZgTjwIM8NkohhpZ\n\
    3Y6vGj7NB34lA//rMRPe36gRSdbrtYPRdJhUCH4Qz+UCQQDEWXmQcoDcZdkb/64q\n\
    1ntMoKejf5aTJ0CwEGKSb1xy8m05iRvemfjLh6lKy5NPg/f3P6hlbbvwyUbXJ6MP\n\
    uk4pAkEArkYssShLxA7VjrsGt6kDAZ2KCuon8TaXrNvpEku9g20fFWc7dsKXRKaO\n\
    iLsiBQPhnsy5xdZ6IyAlZb+MUfmWmQJAMH5QscY14TkeR/X71ASo6yH6hTzruWhG\n\
    Z7WEQtpSIOmS5FTilzW75riYrSpeNZNIWL5WHsbdVfjAED9v3GCNEQJAIey0MA5R\n\
    lwJhDmFWgrthc8+NZaV6Ud83JC/KYHAa4zjgKmVNQ2JGD6M3YMoZzD2XuPoegzE0\n\
    53BU01g4fgwF7A==\n\
    -----END PRIVATE KEY-----";
    
    //RSA秘钥串(Base64)形式编码
    NSData* enCode = [self encryptDataByRSA:[@"测试XiaoTiantian测试" dataUsingEncoding:NSUTF8StringEncoding] publicKey:keyStringPub paddingType:kSecPaddingNone];
    [Mylog info:@"RSA秘钥PEM Key编码结果:%@", [self dataToBase64String:enCode length:(int)[enCode length]]];
    //解析出公钥的指数+模
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    //RSA指数+摸形式加密
    enCode = [self encryptDataByRSA:[@"测试XiaoTiantian测试" dataUsingEncoding:NSUTF8StringEncoding] exponent:exponent modulus:modulus paddingType:kSecPaddingNone];
    [Mylog info:@"RSA指数模编码结果:%@", [self dataToBase64String:enCode length:(int)[enCode length]]];
    //RSA秘钥串(Base64)形式解码
    NSData* deCode = [self decryDataByRSA:enCode privateKey:keyStringPri paddingType:kSecPaddingNone];
    [Mylog info:@"RSA秘钥PEM Key解码结果:%@", [[NSString alloc] initWithData:deCode encoding:NSUTF8StringEncoding]];
    //
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PrivKey"];
    //[Mylog info:@"编码结果Base64:%@", [self dataToBase64String:enCode length:(int)[enCode length]]];
    // 私钥解码
}
/// 通过秘钥链引用对数据执行编码
- (NSData *)encryptDataByRSA:(NSData *)data withKeyRef:(SecKeyRef) keyRef paddingType:(SecPadding) paddingType{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx += src_block_size){ // 根据秘钥数据块大小,分块进行编码
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef, // SecKeyRef 秘钥
                               paddingType, // SecPadding 填充模式
                               srcbuf + idx, //plainText 要编码文本
                               data_len, // plainTextLen 编码文本长度
                               outbuf, // cipherText 编码后的文本
                               &outlen // cipherTextLen 编码后文本长度
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}
/// 通过秘钥链引用对数据执行解码
- (NSData *)decryptDataByRSA:(NSData *)data withKeyRef:(SecKeyRef) keyRef paddingType:(SecPadding) paddingType{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef, paddingType, srcbuf + idx, data_len, outbuf, &outlen);
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        } else {
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( outbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}
/// 通过公钥数据创建SecKeyRef秘钥
- (SecKeyRef) addNewPublicKeyChain:(NSString*) keyChaintTag publicKeyData:(NSData*)publicKeyData {
    NSData * tagData = [[NSData alloc] initWithBytes:(const void *)[keyChaintTag UTF8String] length:[keyChaintTag length]];
    NSMutableDictionary * peerKeyAttr = [[NSMutableDictionary alloc] init];
    [peerKeyAttr setObject:tagData forKey:(__bridge id)kSecAttrApplicationTag];
    [peerKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    // 如果秘钥链存在则删除,重新添加秘钥链
    OSStatus statusDel = [self deleteKeyChainByTag:tagData];
    if (statusDel != noErr){
        [Mylog info:@"删除秘钥链%@失败.%@", keyChaintTag, [self fetchOSStatus:statusDel]];
    }
    [peerKeyAttr setObject:publicKeyData forKey:(__bridge id)kSecValueData];
    [peerKeyAttr setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [peerKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    SecKeyRef persistKeyRef = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) peerKeyAttr, (CFTypeRef *)&persistKeyRef);
    if (persistKeyRef != nil){
        CFRelease(persistKeyRef);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        [Mylog info:@"编码错误: 添加私钥到秘钥链失败,status=%d", status];
        return nil;
    }
    // 配置读取秘钥链
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [peerKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    // 开始匹配TAG的秘钥链
    SecKeyRef secKeyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)peerKeyAttr, (CFTypeRef *)&secKeyRef);
    if(status != noErr) {
        [Mylog info:@"编码错误: 匹配%@的秘钥链失败,%@", keyChaintTag, [self fetchOSStatus:status]];
        return nil;
    }
    if(!secKeyRef) {
        [Mylog info:@"编码错误: 匹配秘钥链%@失败,秘钥链结果SecKeyRef=nil.", keyChaintTag];
        return nil;
    }
    return secKeyRef;
}
/// 通过私钥数据创建SecKeyRef秘钥
- (SecKeyRef) addNewPrivateKeyChain:(NSString*) keyChaintTag privateKeyData:(NSData*)privateKeyData {
    NSData * tagData = [[NSData alloc] initWithBytes:(const void *)[keyChaintTag UTF8String] length:[keyChaintTag length]];
    [Mylog info:[self dataToHexString:privateKeyData]];
    NSMutableDictionary * peerKeyAttr = [[NSMutableDictionary alloc] init];
    [peerKeyAttr setObject:tagData forKey:(__bridge id)kSecAttrApplicationTag];
    [peerKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    // 如果秘钥链存在则删除,重新添加秘钥链
    OSStatus statusDel = [self deleteKeyChainByTag:tagData];
    if (statusDel != noErr){
        [Mylog info:@"删除秘钥链%@失败.%@", keyChaintTag, [self fetchOSStatus:statusDel]];
    }
    [peerKeyAttr setObject:privateKeyData forKey:(__bridge id)kSecValueData];
    [peerKeyAttr setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [peerKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    SecKeyRef persistKeyRef = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) peerKeyAttr, (CFTypeRef *)&persistKeyRef);
    if (persistKeyRef != nil){
        CFRelease(persistKeyRef);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)){
        [Mylog info:@"解码错误: 添加私钥到秘钥链失败,status=%d", status];
        return nil;
    }
    [Mylog info:@"添加私钥%@:Status: %@", keyChaintTag, [self fetchOSStatus:status]];
    // 配置读取秘钥链
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [peerKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    // 开始匹配TAG的秘钥链
    SecKeyRef secKeyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)peerKeyAttr, (CFTypeRef *)&secKeyRef);
    if(status != noErr) {
        [Mylog info:@"解码错误: 匹配%@的秘钥链失败,%@", keyChaintTag, [self fetchOSStatus:status]];
        return nil;
    }
    if(!secKeyRef) {
        [Mylog info:@"解码错误: 匹配秘钥链%@失败,秘钥链结果SecKeyRef=nil.", keyChaintTag];
        return nil;
    }
    return secKeyRef;
}
/// 生成RSA秘钥对并加入秘钥链[publicTagString:公钥保存到KeyChain的Tag,privateTagString:私钥保存到KeyChain的Tag,keyBits:秘钥位数[1024,2048]]
-(BOOL) generateKeyPairWithPublicTag:(NSString *)publicTagString privateTag:(NSString *)privateTagString keyBits:(int) keyBits {
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // Name Tag String To NSData
    NSData *publicTag = [publicTagString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateTag = [privateTagString dataUsingEncoding:NSUTF8StringEncoding];
    // 秘钥Key
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    // set RSA attribute
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:keyBits] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    // 如果已经有该秘钥链,则删除
    [self deleteKeyChainByTag:publicTag];
    [self deleteKeyChainByTag:privateTag];
    // 生成秘钥对并保存到系统秘钥链中(要使用,根据 Tagname 在系统秘钥链中获取)
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
    if(status != noErr){
        [Mylog info:@"生成RSA秘钥错误: 生成秘钥链失败.%@", [self fetchOSStatus:status]];
        return false;
    } else {
        [Mylog info:@"生成RSA秘钥对已经成功添加到KeyChain秘钥链中,可以通过KeyChain的Tag进行使用秘钥对了.%@", [self fetchOSStatus:status]];
        return true;
    }
}
/// 计算公钥的两大部分组成信息[Exponent指数,Modulus模]
- (void)calculatePublicKeyExponentAndModulus:(NSString *) keyChainTag {
    NSData* keyChainData = [self getKeyChainBits: keyChainTag];
    if (keyChainData == NULL) return;
    [Mylog info:@"Key Chain Data :\n%@", [self dataToHexString:keyChainData]];
    int iterator = 0;
    iterator++; // TYPE - bit stream - mod + exp
    [self derEncodingGetSizeFrom:keyChainData at:&iterator]; // Total size
    
    iterator++; // TYPE - bit stream mod
    int mod_size = [self derEncodingGetSizeFrom:keyChainData at:&iterator];
    NSData* keyChainModule = [keyChainData subdataWithRange:NSMakeRange(iterator, mod_size)];
    iterator += mod_size;
    
    iterator++; // TYPE - bit stream exp
    int exp_size = [self derEncodingGetSizeFrom:keyChainData at:&iterator];
    
    NSData* keyChainExponent = [keyChainData subdataWithRange:NSMakeRange(iterator, exp_size)];
    
    //[Mylog info:@"Key Chain derSize :%d", [self derEncodingGetSizeFrom:keyChainModule]];
    [Mylog info:@"Key Chain Exponent :\n%@", [self dataToHexString:keyChainExponent]];
    [Mylog info:@"Key Chain Modulus :\n%@", [self dataToHexString:keyChainModule]];
}

- (int) derEncodingGetSizeFrom:(NSData*)buf at:(int*)iterator{
    const uint8_t* data = [buf bytes];
    int itr = *iterator;
    int num_bytes = 1;
    int ret = 0;
    if (data[itr] > 0x80) {
        num_bytes = data[itr] - 0x80;
        itr++;
    }
    for (int i = 0 ; i < num_bytes; i++){
        ret = (ret * 0x100) + data[itr + i];
    }
    *iterator = itr + num_bytes;
    return ret;
}

/// 创建可以保存于KeyChain中的RSA秘钥二进制数据[expBits:指数值,modBits:模值]
- (NSData *) createBerRSAData:(NSData *) expBits modulus:(NSData *) modBits {
    NSMutableData *fullKey = [[NSMutableData alloc] initWithLength:6+[modBits length]+[expBits length]  +  1  ] ;
    unsigned char *fullKeyBytes = [fullKey mutableBytes];
    unsigned int bytep = 0; // current byte pointer
    fullKeyBytes[bytep++] = 0x30;
    if(4+[modBits length]+[expBits length] >= 128){
        fullKeyBytes[bytep++] = 0x81;
        [fullKey increaseLengthBy:1];
    }
    unsigned int seqLenLoc = bytep;
    fullKeyBytes[bytep++] = 4+[modBits length]+[expBits length] +1 ;
    fullKeyBytes[bytep++] = 0x02;
    if([modBits length] >= 128){
        fullKeyBytes[bytep++] = 0x81;
        [fullKey increaseLengthBy:1];
        fullKeyBytes[seqLenLoc]++;
    }
    fullKeyBytes[bytep++] = [modBits length] +1;
    fullKeyBytes[bytep++] = 0x00; // 适配IOS9添加 0占位符
    [modBits getBytes:&fullKeyBytes[bytep] length:[modBits length]];
    bytep += [modBits length];
    fullKeyBytes[bytep++] = 0x02;
    fullKeyBytes[bytep++] = [expBits length];
    [expBits getBytes:&fullKeyBytes[bytep] length:[expBits length]];
    return [NSData dataWithBytes:fullKeyBytes length:bytep + [expBits length]]; // 保存到KeyChain的RSA数据
}
- (NSData *) createBerRSADataByBasicEncodingRules:(NSData *) expBits modulus:(NSData *) modBits {
    NSMutableArray *containerArray = [[NSMutableArray alloc] init];
    //适配 IOS9 在module前插入占位符0
    const char fixByte = 0;
    NSMutableData * fixModulusBit = [NSMutableData dataWithBytes:&fixByte length:1];
    [fixModulusBit appendData:modBits];
    [containerArray addObject:fixModulusBit]; // 公钥的模
    [containerArray addObject:expBits]; // 指数:默认65537(0x001001),必须5位,不够5位前面加0[010001]
    return [containerArray berData]; // RSA Ber Data RSA指数模合并数据 [DataByBasicEncodingRules.h]
}

/// 根据KeyChain中的秘钥Tag name获取秘钥的二进制数据
- (NSData *)getKeyChainBits:(NSString*) keyChainTag {
    CFTypeRef secKeyRef;
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = NULL;
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    NSData* publicTag = [keyChainTag dataUsingEncoding:NSUTF8StringEncoding]; // KeyChain tag
    // Set the public key query dictionary.
    [queryPublicKey setObject:publicTag forKey:(__bridge_transfer id)kSecAttrApplicationTag];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge_transfer id)kSecReturnData];
    [queryPublicKey setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
    [queryPublicKey setObject:(__bridge_transfer id)kSecAttrKeyTypeRSA forKey:(__bridge_transfer id)kSecAttrKeyType];
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge_retained CFDictionaryRef)queryPublicKey, &secKeyRef); // matching KeyChain tag
    if (sanityCheck != noErr) {
        [Mylog info:@"获取秘钥错误: 根据秘钥Tag=%@匹配KeyChain时发生错误.%@", keyChainTag, [self fetchOSStatus:sanityCheck]];
        publicKeyBits = NULL;
    } else {
        publicKeyBits = (__bridge_transfer NSData*)secKeyRef;
        //NSLog(@"public bits %@",publicKeyBits);
    }
    return publicKeyBits;
}
///
- (NSData*)encryptString:(NSString*)original RSAPublicKey:(SecKeyRef)publicKey padding:(SecPadding)padding{
    @try{
        size_t encryptedLength = SecKeyGetBlockSize(publicKey);
        uint8_t encrypted[encryptedLength];
        
        const char* cStringValue = [original UTF8String];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        padding,
                                        (const uint8_t*)cStringValue,
                                        strlen(cStringValue),
                                        encrypted,
                                        &encryptedLength);
        if(status == noErr){
            return [[NSData alloc] initWithBytes:(const void*)encrypted length:encryptedLength];
        }
        else
            return nil;
    }@catch (NSException * e){
        //do nothing
        Mylog(@"exception: %@", [e reason]);
    }
    return nil;
}
// 删除KeyChain Tag匹配的秘钥链
- (OSStatus)deleteKeyChainByTag:(NSData*) keyChainTag {
    NSMutableDictionary * query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [query setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [query setObject:keyChainTag forKey:(__bridge id)kSecAttrApplicationTag]; // Tag name
    return SecItemDelete((CFDictionaryRef)query);
}

// 转化OSStatus错误为提示消息
- (NSString*) fetchOSStatus:(OSStatus)status{
    if(status == 0) return [NSString stringWithFormat:@"success (status=%d)", status];
    else if(status == errSecNotAvailable)
        return [NSString stringWithFormat:@"no trust results available (status=%d)", status];
    else if(status == errSecItemNotFound)
        return [NSString stringWithFormat:@"the item cannot be found (status=%d)", status];
    else if(status == errSecParam)
        return [NSString stringWithFormat:@"parameter error (status=%d)", status];
    else if(status == errSecAllocate)
        return [NSString stringWithFormat:@"memory allocation error (status=%d)", status];
    else if(status == errSecInteractionNotAllowed)
        return [NSString stringWithFormat:@"user interaction not allowd (status=%d)", status];
    else if(status == errSecUnimplemented)
        return [NSString stringWithFormat:@"not implemented (status=%d)", status];
    else if(status == errSecDuplicateItem)
        return [NSString stringWithFormat:@"item already exists (status=%d)", status];
    else if(status == errSecDecode)
        return [NSString stringWithFormat:@"unable to decode data (status=%d)", status];
    else
        return [NSString stringWithFormat:@"unknow error (status=%d)", status];
}
/// Hex String转化为NSData
- (NSData *) hexStringToData:(NSString *) inputData {
    const char *chars = [inputData UTF8String];
    int i = 0;
    NSUInteger len = inputData.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}
/// String 的MD5码
- (NSString *) stringMD5:(NSString *) string {
    // Create pointer to the string as UTF8
    const char *ptr = [string UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}
/// Data 的MD5码
- (NSString *) dataMD5:(NSData *) data {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}
/// File Path的MD5码
- (NSString *) fileMD5:(NSString *) filePath{
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    return data == nil ? nil : [self dataMD5:data];
}
/// Data转化为String
- (NSString *) dataToHexString: (NSData *) data {
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

// Base 64 编码
/// 普通String转为Base64的String
- (NSString *) stringToBase64String:(NSString *)string {
    return [self dataToBase64String:[string dataUsingEncoding:NSUTF8StringEncoding]]; // 普通String采用UTF8编码
}
/// 普通String转为Base64的Data
- (NSData *) stringToBase64Data:(NSString *)string {
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64 = [self dataToBase64String:data length:(int)[data length]];
    return [base64 dataUsingEncoding:NSUTF8StringEncoding]; // Data为UTF8编码
}
/// 普通Data转化为Base64的Data
- (NSData *) dataToBase64Data:(NSData *)data {
    NSString* string = [self dataToBase64String:data length:(int)[data length]];
    return [string dataUsingEncoding:NSUTF8StringEncoding]; // Data为UTF8编码
}
/// 普通Data转为Base64的String
- (NSString *) dataToBase64String: (NSData *)data {
    return [self dataToBase64String:data length:(int) [data length]];
}
- (NSString *) dataToBase64String: (NSData *)data length: (int)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    lentext = [data length];
    if (lentext < 1) {
        return @"";
    }
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) {
            break;
        }
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext) {
                input[i] = raw[ix];
            } else {
                input[i] = 0;
            }
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        ixtext += 3;
        charsonline += 4;
        if ((length > 0) && (charsonline >= length)) {
            charsonline = 0;
        }
    }
    return result;
}
// Base 64 解码
/// base64 字符串转为普通String
- (NSString *) base64StringToString:(NSString *)base64String {
    NSData* data = [self base64StringToData:base64String];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/// base64 Data转为普通String
- (NSString *) base64DataToString:(NSData *)base64Data {
    NSString* string = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return [self base64StringToString:string];
}
/// base64 Data转为普通Data
- (NSData *) base64DataToData:(NSData *) base64Data {
    NSString* string = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return [self base64StringToData:string];
}
/// base64 String转为普通Data
- (NSData *) base64StringToData:(NSString *)base64String {
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    if (base64String == nil) {
        return [NSData data];
    }
    ixtext = 0;
    tempcstring = (const unsigned char *)[base64String UTF8String];
    lentext = [base64String length];
    theData = [NSMutableData dataWithCapacity: lentext];
    ixinbuf = 0;
    while (true) {
        if (ixtext >= lentext) {
            break;
        }
        ch = tempcstring [ixtext++];
        flignore = false;
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                ixinbuf = 3;
                flbreak = true;
            }
            inbuf [ixinbuf++] = ch;
            if (ixinbuf == 4) {
                ixinbuf = 0;
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            if (flbreak) {
                break;
            }
        }
    }
    return theData;
}
/// Base64 的64个字符标准码集(可以自定义Base64映射码😯,大小写字母,数字,+/)
char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
@end

