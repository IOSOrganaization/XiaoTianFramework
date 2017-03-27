//
//  UtilSecurity.m
//  DriftBook
//
//  Created by XiaoTian on 16/6/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

#import "XTFCryptorSecurity.h"
#include <CommonCrypto/CommonCrypto.h>
#import "BasicEncodingRules.h"

// Base 64 Encode/Decode

@implementation XTFCryptorSecurity

- (void) test {
    /*
     登陆密码自动缓冲到本地APP[自动登录],所以采用加密的方式存储:
     1.密码采用UTF-8转为Base64后通过RSA密钥加密后保存密文在本地文件,\
     当需要自动登录时自动获取密文计算MD5作为登录密码
     
     2.RSA加密参数:
     指数:bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07
     公匙的模:10001
     私匙的模:88741cf7500c0ef43125d5fa1c3df8e9ae5859791efce3a8b73d5538eeba9be1bc71f90d109b7941bd19605f8e89619e77ea626d9c53557cb193e0e7cfe6eb6c437a3c0967dc5e9d6313c5e8ba6b058078763359cf4bda21472e54e5f856a79943057ad4ffd748e40dc617a1f23b179e7b9937955a8c7cdc0b58897a55948961
     
     3.案例[RSA算码器采用随机填充模式],请参考案例结果进行调试:
     明文:123456
     密文:7493D9ADE81BBC26B6B200545124F7CA24F964590E87A07F56D5BBCEA8BB03BE66F9B1D558E755C00095B029450FF30FCC7611E209CADE2A669D24492C2D3303D0FB660DF6ACE9AAB8107DE03E74D3F835AFF486A061F3F8A0D6CBBB5438D8210DFC0D1C9CA5441DA7C626BD93D81E4C52FD9723BBFF73C0C96788260ED8BE34
     密码:0428e4e99a05652a0c7cdbc3e99be06a
     */
    //[self pem];
    //[self generateKeyPairWithPublicTag:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test" privateTag: @"com.xiaotian.XTCryptorSecurity.RSA_PriKey\test" keyBits:1024];
    //[self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey\test"];
    //
    //NSData * d = [self encryptDataByRSA:[self dataToBase64Data:[@"123456" dataUsingEncoding:NSUTF8StringEncoding]] exponent:@"010001" modulus:@"bbb315ca618d5a34d466f20d09598b81eb6bbdfb722e233c377bd7f8a0b2e06853d77384aeff2bfb0c3f00ccdce84b5a4c9acda47a2b77d2792ddb7b6fe7e72d9dcaaef111f9275ecb2ca0f7c4f37d9d70e5af5b3c85b2da00c03f87cea76fae6e73833117b8df9e17aba7409451b03e66587d9b3f4f4d5d176bd85927983f07" paddingType:kSecPaddingNone];
    
    //[Mylog info:[self stringMD5:[self dataToHexString:d]]];
    [self calculatePublicKeyExponentAndModulus:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey"];
    //30818902818100B81DCD7D57DA87FBFBB4DD2A3336058F14BA92C537963AA148AF2FA6A8CE4351BD5BD5C2E13FA3792586DF8CF7377ADCC8ADF04BAC965BFCC73ED9CC1967AE3D192C78625D92878A85D6983F5A152E2F47CC1E4DEF74554B8F833A79C77A34E40F8F25C588A11DC17A22B4F4AD9A9210689D1A995987A82E22DE53B1F9906E270203010001
    
}

-(NSData*) encryptDataByRSA:(NSData *)data exponent:(NSString*) exp modulus:(NSString*) mod paddingType:(SecPadding) padding {
    SecKeyRef key = [self addPublicKeyChain:@"com.xiaotian.XTCryptorSecurity.RSA_PubKey" exponent:exp modulus:mod]; // module:五位,不足前面补0
    if (key) {
        return [self encryptDataByRSA:data withKeyRef:key paddingType:padding];
    }
    return NULL;
}
- (BOOL) generateRSAPublicKeyChain:(NSString*)keyChainTag modulus: (NSString*)modulus exponent:(NSString*)exponent {
    const uint8_t UNSIGNED_FLAG_FOR_BYTE = 0x81;
    const uint8_t UNSIGNED_FLAG_FOR_BYTE2 = 0x82;
    const uint8_t UNSIGNED_FLAG_FOR_BIGNUM = 0x00;
    const uint8_t SEQUENCE_TAG = 0x30;
    const uint8_t INTEGER_TAG = 0x02;
    
    NSData* tagData = [keyChainTag dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t* modulusBytes = (uint8_t*)[[self hexStringToData: modulus] bytes];
    uint8_t* exponentBytes = (uint8_t*)([[self hexStringToData: exponent] bytes]); // 指数,默认0x10001
    
    //(1) calculate lengths
    //- length of modulus
    int lenMod = (int)[modulus length];
    if(modulusBytes[0] >= 0x80){
        lenMod ++;	//place for UNSIGNED_FLAG_FOR_BIGNUM
    }
    int lenModHeader = 2 + (lenMod >= 0x80 ? 1 : 0) + (lenMod >= 0x0100 ? 1 : 0);
    //- length of exponent
    int lenExp = (int)[exponent length];
    int lenExpHeader = 2;
    //- length of body
    int lenBody = lenModHeader + lenMod + lenExpHeader + lenExp;
    //- length of total
    int lenTotal = 2 + (lenBody >= 0x80 ? 1 : 0) + (lenBody >= 0x0100 ? 1 : 0) + lenBody;
    
    int index = 0;
    uint8_t* byteBuffer = malloc(sizeof(uint8_t) * lenTotal);
    memset(byteBuffer, 0x00, sizeof(uint8_t) * lenTotal);
    
    //(2) fill up byte buffer
    //- sequence tag
    byteBuffer[index ++] = SEQUENCE_TAG;
    //- total length
    if(lenBody >= 0x80)
        byteBuffer[index ++] = (lenBody >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenBody >= 0x0100)
    {
        byteBuffer[index ++] = (uint8_t)(lenBody / 0x0100);
        byteBuffer[index ++] = lenBody % 0x0100;
    }
    else
        byteBuffer[index ++] = lenBody;
    //- integer tag
    byteBuffer[index ++] = INTEGER_TAG;
    //- modulus length
    if(lenMod >= 0x80)
        byteBuffer[index ++] = (lenMod >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenMod >= 0x0100){
        byteBuffer[index ++] = (int)(lenMod / 0x0100);
        byteBuffer[index ++] = lenMod % 0x0100;
    } else{
        byteBuffer[index ++] = lenMod;
    }
    //- modulus value
    if(modulusBytes[0] >= 0x80)
        byteBuffer[index ++] = UNSIGNED_FLAG_FOR_BIGNUM;
    memcpy(byteBuffer + index, modulusBytes, sizeof(uint8_t) * [modulus length]);
    index += [modulus length];
    //- exponent length
    byteBuffer[index ++] = INTEGER_TAG;
    byteBuffer[index ++] = lenExp;
    //- exponent value
    memcpy(byteBuffer + index, exponentBytes, sizeof(uint8_t) * lenExp);
    index += lenExp;
    
    if(index != lenTotal){
        [XTFMylog info:@"lengths mismatch: index = %d, lenTotal = %d", index, lenTotal];
    }
    NSMutableData* publicKeyData = [NSMutableData dataWithBytes:byteBuffer length:lenTotal];
    free(byteBuffer);
    NSDictionary * publicKeyAttr = [NSDictionary dictionaryWithObjectsAndKeys:
     (id)kSecClassKey, kSecClass,
     (id)kSecAttrKeyTypeRSA, kSecAttrKeyType,
     (id)kSecAttrKeyClassPublic, kSecAttrKeyClass,
     kCFBooleanTrue, kSecAttrIsPermanent,
     tagData, kSecAttrApplicationTag,
     publicKeyData, kSecValueData,
     kCFBooleanTrue, kSecReturnPersistentRef,
     nil];
    SecItemDelete((CFDictionaryRef) publicKeyAttr);
    //
    CFDataRef ref;
    OSStatus status = SecItemAdd((CFDictionaryRef)publicKeyAttr, (CFTypeRef *)&ref);
    
    [XTFMylog info:@"result = %@", [self fetchOSStatus:status]];
    if(status == noErr){ // 添加无错误
        return YES;
    } else if(status == errSecDuplicateItem){ // 已存在,更新
        OSStatus status = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                (id)kSecClassKey, kSecClass,
                                                                kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                                kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                                keyChainTag, kSecAttrApplicationTag,
                                                                nil],
                                              NULL);	//don't need public key ref
        
        if(status == noErr) {
            status = SecItemUpdate((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                     (id)kSecClassKey, kSecClass,
                                                     kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                     kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                     keyChainTag, kSecAttrApplicationTag,
                                                     nil],
                                   (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                     publicKeyData, kSecValueData,
                                                     nil]);
            return status == noErr;
        }
        return NO;
    }
    return NO;
}

- (void) pem {
    NSError *error;
    NSString *keyStringPub = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"pem"] encoding:NSUTF8StringEncoding error:&error];
    NSString *keyStringPri = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"pem"] encoding:NSUTF8StringEncoding error:&error];
    [XTFMylog info:keyStringPub];
    [XTFMylog info:keyStringPri];
    // 过滤出完整Public Key字符串
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
        [XTFMylog info:@"通过-----BEGIN PUBLIC KEY-----截取公钥字符串失败."];
        return;
    }
    // 截取
    NSUInteger s = spospu.location + spospu.length;
    NSUInteger e = epospu.location;
    NSRange range = NSMakeRange(s, e-s);
    keyPubPurity = [keyStringPub substringWithRange:range];
    // 清除无效字符
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    keyPubPurity = [keyPubPurity stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // Public Key 进行Base64编码,后续对Base64结果码进行操作
    NSData *keyDataPub = [self stringToBase64Data: keyPubPurity];
    
    // 过滤RSA公钥头声明 Skip ASN.1 public key header
    unsigned long len = [keyDataPub length];
    unsigned char *c_key = (unsigned char *)[keyDataPub bytes];
    unsigned int  idx	 = 0;
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
                    keyDataPub = ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
                } else {
                    [XTFMylog info:@"编码错误: RSA PKCS #1后续头结束位\0读取错误."];
                    return;
                }
            } else {
                [XTFMylog info:@"编码错误: RSA PKCS #1后必须以0x03开始."];
                return;
            }
        } else {
            [XTFMylog info:@"编码错误: RSA PKCS #1 匹配失败."];
            return;
        }
    } else {
        [XTFMylog info:@"编码错误: RSA 秘钥必须以0x30开始."];
        return;
    }
    [XTFMylog info:@"过滤后保存的公钥Data:\n%@", [self dataToHexString:keyDataPub]];
    // keychain 秘钥链存储标志TAG
    NSString *tag = @"com.xiaotian.XTCryptorSecurity.RSA_PubKey";
    NSData *tagData = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    // 配置秘钥链属性
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType]; // 类型RSA
    [publicKey setObject:tagData forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey); // 如果秘钥链存在则删除,重新添加秘钥链
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:keyDataPub forKey:(__bridge id)kSecValueData]; // 公钥值
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass]; // 声明Public Key公钥
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef]; // 返回持久化结果引用
    // 添加配置属性到的秘钥链
    CFTypeRef persistKeyRef = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKeyRef);
    if (persistKeyRef != nil){
        CFRelease(persistKeyRef);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        [XTFMylog info:@"编码错误: 添加公钥到秘钥链失败,status=%d", status];
        return;
    }
    // 配置读取秘钥链
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef]; // 返回秘钥引用
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType]; // 类型RSA
    // 开始匹配TAG的秘钥链 Now fetch the SecKeyRef version of the key
    SecKeyRef pubKeyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&pubKeyRef);
    if (status != noErr) {
        [XTFMylog info:@"编码错误: 匹配%@的秘钥链失败,status=%d", tag, status];
        return;
    }
    if(!pubKeyRef){
        [XTFMylog info:@"编码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", tag];
        return;
    }
    NSData *enCode = [self encryptDataByRSA:[@"小甜甜爱吃萝卜GAGA" dataUsingEncoding:NSUTF8StringEncoding]  withKeyRef:pubKeyRef paddingType:kSecPaddingPKCS1];
    [XTFMylog info:@"编码结果:%@", [self dataToHexString:enCode]];
    [XTFMylog info:@"编码结果Base64:%@", [self dataToBase64String:enCode length:(int)[enCode length]]];
    
    //pubKeyRef = [self addPublicKeyByExponent:@"10001" modulus:@"D471AF6FAE20799E6561030E1C9656B9EFE6C6319C80C9A2FB6F0050D4C5884123F764861BFD936A8B616B74886736291D8B518026B4220EE8206E520041E0C6A82C77D98B103CB0342E93F9A10CC5BB20A6452498B191E781FCCB5393E9C2ACD466FEDA3DB3DEFF000547F5C56B25DCA3CBB88C8AB6E4AE9F87BFF95F62DE6F"];
    //enCode = [self encryptData: [@"1234567890" dataUsingEncoding:NSUTF8StringEncoding] withKeyRef:pubKeyRef];
    //[Mylog info:@"编码结果Base64:%@", [self dataToBase64String:enCode length:(int)[enCode length]]];
    // 私钥解码
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
        [XTFMylog info:@"解错误: 通过-----BEGIN RSA PRIVATE KEY-----或-----BEGIN PRIVATE KEY-----截取私钥字符串失败."];
        return;
    }
    // 截取
    NSString *keyPriPurity = nil;
    NSUInteger sp = spospri.location + spospri.length;
    NSUInteger ep = epospri.location;
    NSRange rangep = NSMakeRange(sp, ep-sp);
    keyPriPurity = [keyStringPri substringWithRange:rangep];
    // 清除无效字符
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    keyPriPurity = [keyPriPurity stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // Private Key 进行Base64编码,后续对Base64结果码进行操作
    NSData *keyDataPri = [self stringToBase64Data:keyPriPurity];
    [XTFMylog info:[self dataToHexString:keyDataPri]];
    // 过滤RSA私钥头声明 Skip ASN.1 public key header
    unsigned long lenp = [keyDataPri length];
    unsigned char *c_keyp = (unsigned char *)[keyDataPri bytes];
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
                [XTFMylog info:@"解码错误:RSA私钥的字段长度大于缓存值."];
                return;
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
        keyDataPri = [keyDataPri subdataWithRange:NSMakeRange(idxp, c_len)];
    } else {
        [XTFMylog info:@"解码错误: 私钥的第22位必须为0x04.pkb64[22]=0x%02X",c_keyp[--idxp]];
        return;
    }
    // keychain 秘钥链存储标志TAG
    NSString *tagp = @"com.xiaotian.XTCryptorSecurity.RSA_PrivKey";
    NSData *tagDatap = [NSData dataWithBytes:[tagp UTF8String] length:[tagp length]];
    // 配置秘钥链属性
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType]; // 类型RSA
    [privateKey setObject:tagDatap forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey); // 如果秘钥链存在则删除,重新添加秘钥链
    // Add persistent version of the key to system keychain
    [privateKey setObject:keyDataPri forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    // 开始匹配TAG的秘钥链
    CFTypeRef persistKeyRefp = nil;
    OSStatus statusp = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKeyRefp);
    if (persistKeyRefp != nil){
        CFRelease(persistKeyRefp);
    }
    if ((statusp != noErr) && (statusp != errSecDuplicateItem)) {
        [XTFMylog info:@"解码错误: 添加私钥到秘钥链失败,status=%d", statusp];
        return;
    }
    // 配置读取秘钥链
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // 开始匹配TAG的秘钥链
    SecKeyRef priKeyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&priKeyRef);
    if(statusp != noErr){
        [XTFMylog info:@"解码错误: 匹配%@的秘钥链失败,status=%d", tagp, statusp];
        return;
    }
    if(!priKeyRef){
        [XTFMylog info:@"解码错误: 匹配%@的秘钥链失败,秘钥链结果为nil.", tagp];
        return;
    }
    
    NSData *deCode = [self decryptData:enCode withKeyRef:priKeyRef];
    [XTFMylog info:@"解码结果:%@",[self dataToHexString: deCode]];
}

// Hex NSString转化为NSData
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
// String 的MD5码
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
// Data 的MD5码
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
// Data转化为String
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

// 通过秘钥链引用对数据执行编码
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
// 通过秘钥链引用对数据执行解码
- (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef {
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
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
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

// 通过指数+模创建SecKeyRef秘钥链
- (SecKeyRef) addPublicKeyChain:(NSString*) keyChaintTag exponent:(NSString*)exponent modulus:(NSString*)modulus {
    NSData* publicKeyData = [self createBerRSAData:[self hexStringToData:exponent] modulus:[self hexStringToData:modulus]];
    NSData * tagData = [[NSData alloc] initWithBytes:(const void *)[keyChaintTag UTF8String] length:[keyChaintTag length]];
    //
    NSMutableDictionary * peerKeyAttr = [[NSMutableDictionary alloc] init];
    [peerKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerKeyAttr setObject:tagData forKey:(__bridge id)kSecAttrApplicationTag];
    [peerKeyAttr setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [peerKeyAttr setObject:publicKeyData forKey:(__bridge id)kSecValueData];
    OSStatus statusDel = [self deleteKeyChainByTag:tagData]; // 如果秘钥链存在则删除,重新添加秘钥链
    if (statusDel != noErr){
        [XTFMylog info:@"删除秘钥链%@失败.%@", keyChaintTag, [self fetchOSStatus:statusDel]];
    }
    SecKeyRef persistKeyRef = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) peerKeyAttr, (CFTypeRef *)&persistKeyRef);
    if (persistKeyRef != nil){
        CFRelease(persistKeyRef);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        [XTFMylog info:@"编码错误: 添加私钥到秘钥链失败,status=%d", status];
        return nil;
    }
    // 配置读取秘钥链
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
    [peerKeyAttr removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [peerKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [peerKeyAttr setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    // 开始匹配TAG的秘钥链
    SecKeyRef secKeyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)peerKeyAttr, (CFTypeRef *)&secKeyRef);
    if(status != noErr) {
        [XTFMylog info:@"编码错误: 匹配%@的秘钥链失败,%@", keyChaintTag, [self fetchOSStatus:status]];
        return nil;
    }
    if(!secKeyRef) {
        [XTFMylog info:@"编码错误: 匹配秘钥链%@失败,秘钥链结果SecKeyRef=nil.", keyChaintTag];
        return nil;
    }
    return secKeyRef;
}

// 生成RSA秘钥对并加入秘钥链[publicTagString:公钥保存到KeyChain的Tag,privateTagString:私钥保存到KeyChain的Tag,keyBits:秘钥位数[1024,2048]]
-(BOOL) generateKeyPairWithPublicTag:(NSString *)publicTagString privateTag:(NSString *)privateTagString keyBits:(int) keyBits {
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // Name Tag
    NSData *publicTag = [publicTagString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateTag = [privateTagString dataUsingEncoding:NSUTF8StringEncoding];
    // 秘钥Key
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    //
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:keyBits] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    // 如果已经有该秘钥链,则删除
    [self deleteKeyChainByTag:publicTag];
    [self deleteKeyChainByTag:privateTag];
    // 生成秘钥对
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
    if(status != noErr){
        [XTFMylog info:@"生成RSA秘钥错误: 生成秘钥链失败.%@", [self fetchOSStatus:status]];
        return false;
    } else {
        [XTFMylog info:@"生成RSA秘钥对已经成功添加到KeyChain秘钥链中,可以通过KeyChain的Tag进行使用秘钥对了.%@", [self fetchOSStatus:status]];
        return true;
    }
}

// 计算公钥的两大部分组成信息[Exponent指数,Modulus模]
- (void)calculatePublicKeyExponentAndModulus:(NSString *) keyChainTag {
    NSData* keyChainData = [self getKeyChainBits: keyChainTag];
    if (keyChainData == NULL) return;
    [XTFMylog info:@"Key Chain Data :\n%@", [self dataToHexString:keyChainData]];
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
    [XTFMylog info:@"Key Chain Exponent :\n%@", [self dataToHexString:keyChainExponent]];
    [XTFMylog info:@"Key Chain Modulus :\n%@", [self dataToHexString:keyChainModule]];
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

// 创建可以保存于KeyChain中的RSA秘钥数据[expBits:指数值,modBits:模值]
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
// 根据KeyChain中的秘钥TAG获取公钥的二进制数据
- (NSData *)getKeyChainBits:(NSString*) keyChainTag {
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = NULL;
    CFTypeRef secKeyRef;
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    NSData* publicTag = [keyChainTag dataUsingEncoding:NSUTF8StringEncoding]; // KeyChain tag
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge_transfer id)kSecClassKey forKey:(__bridge_transfer id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge_transfer id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge_transfer id)kSecAttrKeyTypeRSA forKey:(__bridge_transfer id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge_transfer id)kSecReturnData];
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge_retained CFDictionaryRef)queryPublicKey, &secKeyRef); // matching KeyChain tag
    if (sanityCheck != noErr) {
        [XTFMylog info:@"获取秘钥错误: 根据秘钥Tag=%@匹配KeyChain时发生错误.%@", keyChainTag, [self fetchOSStatus:sanityCheck]];
        publicKeyBits = NULL;
    } else {
        publicKeyBits = (__bridge_transfer NSData*)secKeyRef;
        //NSLog(@"public bits %@",publicKeyBits);
    }
    return publicKeyBits;
}

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
        XTFMylog(@"exception: %@", [e reason]);
    }
    return nil;
}
// 删除KeyChain Tag的秘钥链
- (OSStatus)deleteKeyChainByTag:(NSData*) keyChainTag {
    NSMutableDictionary * query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [query setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [query setObject:keyChainTag forKey:(__bridge id)kSecAttrApplicationTag];
    return SecItemDelete((CFDictionaryRef)query);
}
// 转化OSStatus消息
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

// Base 编码
// 普通String转为Base64的String
- (NSString *) stringToBase64String:(NSString *)string {
    return [self dataToBase64String:[string dataUsingEncoding:NSUTF8StringEncoding]]; // 普通String采用UTF8编码
}
// 普通String转为Base64的Data
- (NSData *) stringToBase64Data:(NSString *)string {
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64 = [self dataToBase64String:data length:(int)[data length]];
    return [base64 dataUsingEncoding:NSUTF8StringEncoding]; // Data为UTF8编码
}
// 普通Data转化为Base64的Data
- (NSData *) dataToBase64Data:(NSData *)data {
    NSString* string = [self dataToBase64String:data length:(int)[data length]];
    return [string dataUsingEncoding:NSUTF8StringEncoding]; // Data为UTF8编码
}
// 普通Data转为Base64的String
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
// base64 字符串转为普通String
- (NSString *) base64StringToString:(NSString *)base64String {
    NSData* data = [self base64StringToData:base64String];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
// base64 Data转为普通String
- (NSString *) base64DataToString:(NSData *)base64Data {
    NSString* string = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return [self base64StringToString:string];
}
// base64 Data转为普通Data
- (NSData *) base64DataToData:(NSData *) base64Data {
    NSString* string = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return [self base64StringToData:string];
}
// base64 String转为普通Data
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

char base64EncodingTable[64] = { // Base64 的64个字符码集
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
@end

