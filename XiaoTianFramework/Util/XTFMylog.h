//
//  XTFMylog.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/25/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//works in DEBUG mode only
#ifndef __OPTIMIZE__
#define XTFMylog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define XTFMylog(s, ...)
#endif
@interface XTFMylog : NSObject
// @property: corresponding setter accessor method
@property(nonatomic,null_resettable,strong) NSString* debugTag;
//
+(void) infoDate;
+(void) infoDate:(NSString * _Nullable) key;
//
+(void) info:(id _Nullable ) message, ...;// format:NSString, ... 不定参数,任意格式;
+(void) infoId:(id _Nullable) message;
+(void) infoClassMethod: (id _Nullable) message;
+(void) infoClassMethodCurrent: (id _Nullable) message;
+(void) infoClassField: (id _Nullable) message;
+(void) infoClassProperty: (id _Nullable) message;
+(void) infoClassVariable: (id _Nullable) message;
+(void) infoMethodImplementation: (id _Nullable) target selector: (SEL _Nullable) selector;
//
+(void) infoBundleAllFiles;
+(void) infoBundleAllFolder;
+(void) infoBundleAllFiles:(NSString * _Nullable)extends;
//@property policies:
//strong, retain (no Swift equivalent)
//  The default. The two terms are pure synonyms of one another; retain is the term inherited from pre-ARC days. Assignment to this property retains the incoming value and releases the existing value.
//copy (no Swift equivalent, or @NSCopying)
//  The same as strong or retain, except that the setter copies the incoming value by sending copy to it; the incoming value must be an object of a type that adopts NSCopying, to ensure that this is possible. The copy, which has an increased retain count already, becomes the new value.
//weak (Swift weak)
//  An ARC-weak reference. The incoming object value is not retained, but if it goes out of existence behind our back, ARC will magically substitute nil as the value of this property, which must be typed as an Optional declared with var.
//assign (Swift unowned(unsafe))
//  No memory management. This policy is inherited from pre-ARC days, and is inherently unsafe (hence the additional unsafe warning in the Swift translation of the name): if the object referred to goes out of existence, this reference will become a dangling pointer and can cause a crash if you subsequently try to use it.
@end
