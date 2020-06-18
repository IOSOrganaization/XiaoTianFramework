//
//  XTFUtilSqlite.h
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//
/*
#import <Foundation/Foundation.h>
// 动态包含在系统中,不同环境,位置不一样,所以在module中直接引入不了,需要拷贝这两个工具类到所在项目中
#import <sqlite3.h>

@interface XTFUtilSqlite : NSObject

// Result Property
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults; // Results (not nil column string in array)
@property (nonatomic, strong) NSMutableArray *arrColumnNames; // Result Column Name (not nil column string in array)
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;
//
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename; // init
//
-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable; // run base sql query
//
-(BOOL) isDatabaseFileInit:(NSString *)dbFilename;
-(NSArray *)loadDataFromDB:(NSString *)query; // query
-(void)executeQuery:(NSString *)query; // inser,update
// 队列调度 XTFUtilSqlite 必须保持单例
-(NSDictionary *)loadDataFromDBQueue:(NSString *)query;
-(NSDictionary *)executeQueryQueue:(NSString *)query;
@end
*/
