//
//  UtilSecurity.swift
//  DriftBook
//
//  Created by XiaoTian on 16/6/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilSecurity : NSObject {
    // 密码加密
    func encodePassword(_ password:String) -> String{
        let xtcs = XTFCryptorSecurity()
        // 密码->Base64
        let paswordBase64 = xtcs.string(toBase64Data: password)
        // RSA 加密
        let encryData = xtcs.encryptData(byRSA: paswordBase64, exponent: ConstantApp.RSA_PUBLIC_EXPONENT, modulus: ConstantApp.RSA_MODULUS, paddingType: SecPadding())
        let encryString = xtcs.data(toHexString: encryData);
        // 加密结果MD5
        return xtcs.stringMD5(encryString);
    }
    // MD5
    func md5Code(_ data:String) -> String{
        let xtcs = XTFCryptorSecurity()
        return xtcs.stringMD5(data);
    }
    /// assert
    func assert(_ value: Bool){
        assert(value)
    }
}
