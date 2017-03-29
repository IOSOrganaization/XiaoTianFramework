//
//  UtilSecurity.swift
//  DriftBook
//
//  Created by XiaoTian on 16/6/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class UtilSecurity : NSObject {
    // 密码加密
    func encodePassword(password:String) -> String{
        let xtcs = XTFCryptorSecurity()
        // 密码->Base64
        let paswordBase64 = xtcs.stringToBase64Data(password)
        // RSA 加密
        let encryData = xtcs.encryptDataByRSA(paswordBase64, exponent: ConstantApp.RSA_PUBLIC_EXPONENT, modulus: ConstantApp.RSA_MODULUS, paddingType: SecPadding.None)
        let encryString = xtcs.dataToHexString(encryData);
        // 加密结果MD5
        return xtcs.stringMD5(encryString);
    }
    // MD5
    func md5Code(data:String) -> String{
        let xtcs = XTFCryptorSecurity()
        return xtcs.stringMD5(data);
    }
    /// assert
    func assert(value: Bool){
        assert(value)
    }
}