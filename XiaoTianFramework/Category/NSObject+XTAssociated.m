//
//  NSObject+XTAssociated.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/6.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import "NSObject+XTAssociated.h"
#import <objc/runtime.h>

@implementation NSObject(XTAssociated)
// 静态变量,绑定引用地址(静态保持地址不变)
static void* KEY_XT_ASSOCIATED_CELL_ROW = "\n";
static void* KEY_XT_ASSOCIATED_CELL_TYPE = "\n";
static void* KEY_XT_ASSOCIATED_CELL_INDEXPATH = "\n";

// 重写 getter/setter 绑定数据
@dynamic cellType;
- (int)cellType{
    NSNumber* value = objc_getAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_TYPE);
    if(value){
        return [value intValue];
    }
    return -1;
}
- (void)setCellType:(int)cellType{
    objc_setAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_TYPE, [NSNumber numberWithInt:cellType], OBJC_ASSOCIATION_COPY);
}
@dynamic cellIndexPath;
- (NSIndexPath *)cellIndexPath{
    NSIndexPath* value = objc_getAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_INDEXPATH);
    if(value){
        return value;
    }
    return [NSIndexPath indexPathForRow:-1 inSection:-1];
}
- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath{
    objc_setAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_INDEXPATH, cellIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@dynamic cellRow;
-(int)cellRow{
    NSNumber* value = objc_getAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_ROW);
    if(value){
        return [value intValue];
    }
    return -1;
}
- (void)setCellRow:(int)cellRow{
    objc_setAssociatedObject(self, &KEY_XT_ASSOCIATED_CELL_ROW, [NSNumber numberWithInt:cellRow], OBJC_ASSOCIATION_COPY);
}
@dynamic cellData;
- (NSObject *)cellData{
    return objc_getAssociatedObject(self, @selector(cellData));//@selector(data):是一个地址,并且是一个方法地址(地址常量)
}
- (void)setCellData:(NSObject *)cellData{
    objc_setAssociatedObject(self, @selector(cellData), cellData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSObject*) getAssociated:(const void* _Nonnull)key{
    return objc_getAssociatedObject(self, key);
}
-(void) setAssociated:(id _Nonnull)object key:(const void* _Nonnull)key{
    objc_setAssociatedObject(self, key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
