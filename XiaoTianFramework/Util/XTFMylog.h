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
//
+(void) infoSCGRect:(CGRect) rect;
+(void) infoSCGRect:(CGRect) rect key:(NSString*) key;
+(void) infoSCGSize:(CGSize) size;
+(void) infoSCGSize:(CGSize) size key:(NSString*) key;
+(void) infoSCGPoint:(CGPoint) point;
+(void) infoSCGPoint:(CGPoint) point key:(NSString*) key;
+(void) infoSCGVector:(CGVector) vector;
+(void) infoSCGVector:(CGVector) vector key:(NSString*) key;
+(void) infoSCGAffineTransform:(CGAffineTransform) transform;
+(void) infoSCGAffineTransform:(CGAffineTransform) transform key:(NSString*) key;
+(void) infoSUIEdgeInsets:(UIEdgeInsets) edge;
+(void) infoSUIEdgeInsets:(UIEdgeInsets) edge key:(NSString*) key;
+(void) infoSUIOffset:(UIOffset) offset;
+(void) infoSUIOffset:(UIOffset) offset key:(NSString*) key;
+(void) infoBool:(BOOL) value key:(NSString *)key;
+(void) infoBool:(BOOL) value;
//
+(void) info:(id) message, ...;// format:NSString, ... 不定参数,任意格式;
+(void) infoId:(id) message;
+(void) infoDate:(NSString *) key;
+(void) infoDate;
+(void) infoClassMethod: (id) message;
+(void) infoClassMethodCurrent: (id) message;
+(void) infoClassField: (id) message;
+(void) infoClassProperty: (id) message;
+(void) infoClassVariable: (id) message;
+(void) infoMethodImplementation: (id) target selector: (SEL) selector;
//
+(void) infoBundleAllFiles;
+(void) infoBundleAllFolder;
+(void) infoBundleAllFiles:(NSString *)extends;
//
@end
