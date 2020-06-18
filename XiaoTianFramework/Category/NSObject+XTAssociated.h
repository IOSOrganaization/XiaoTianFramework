//
//  NSObject+XTAssociated.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/6.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject(XTAssociated)
// 在ARC下不需要dealloc释放,在MRC中，对于使用retain或copy策略的则需要其他不需要
// 扩展属性
/// 绑定关联的Cell IndexPath值 对象
@property(strong,nonatomic)NSIndexPath* cellIndexPath;
/// 绑定关联的CellType值 int
@property(assign,nonatomic)int cellType;
/// 获取关联的Cell Row值 int
@property(assign,nonatomic)int cellRow;
/// 获取绑定的Data值 对象
@property(strong,nonatomic)NSObject* cellData;

// 扩展方法
/// 根据Key绑定关联对象到当前实例
-(NSObject*) getAssociated:(const void* _Nonnull)key;
-(void) setAssociated:(id _Nonnull)object key:(const void* _Nonnull)key;
@end

NS_ASSUME_NONNULL_END
