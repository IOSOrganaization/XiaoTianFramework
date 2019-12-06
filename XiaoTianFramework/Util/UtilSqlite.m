//
//  UtilSqlite.m
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

#import "UtilSqlite.h"
static const void * const XTFUtilSqliteDispatchQueueSpecificKey = &XTFUtilSqliteDispatchQueueSpecificKey;

@implementation UtilSqlite{
    dispatch_queue_t queryQueue;
}

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
        
        //
        queryQueue = dispatch_queue_create([[NSString stringWithFormat:@"XTFUtilSqlite.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(queryQueue, XTFUtilSqliteDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}
-(BOOL) isDatabaseFileInit:(NSString *)dbFilename{
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:dbFilename];
    return [[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
}
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    // Set the database file path.
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // Check if the query is non-executable.
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            } else {
                // This is the case of an executable query (insert, update, ...).
                
                // Execute the query.
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                } else {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        } else {
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }
    // Close the database.
    sqlite3_close(sqlite3Database);
}
-(NSArray *)loadDataFromDB:(NSString *)query{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}
-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}
-(NSDictionary *)loadDataFromDBQueue:(NSString *)query{
    __block NSMutableDictionary * result = [[NSMutableDictionary alloc] init]; // ["arrColumnNames":arrColumnNames,"arrResults":arrResults,"affectedRows":affectedRows,"lastInsertedRowID":lastInsertedRowID]
    dispatch_sync(queryQueue, ^{
        NSArray * arrResultsDB = [self loadDataFromDB:query];
        NSMutableArray * arrColumnNamesNew = [[NSMutableArray alloc] initWithCapacity:[self.arrColumnNames count]];
        for (NSString* column in self.arrColumnNames) {
            [arrColumnNamesNew addObject:column];
        }
        NSMutableArray * arrResultsNew = [[NSMutableArray alloc] initWithCapacity:[arrResultsDB count]];
        for (NSString* value in arrResultsDB) {
            [arrResultsNew addObject:value];
        }
        [result setObject:arrColumnNamesNew forKey:@"arrColumnNames"];
        [result setObject:arrResultsNew forKey:@"arrResults"];
        [result setObject:[NSNumber numberWithInteger:self.affectedRows] forKey:@"affectedRows"];
        [result setObject:[NSNumber numberWithInteger:self.lastInsertedRowID] forKey:@"lastInsertedRowID"];
    });
    return result;
}
-(NSDictionary *)executeQueryQueue:(NSString *)query{
    __block NSMutableDictionary * result = [[NSMutableDictionary alloc] init]; // ["arrColumnNames":arrColumnNames,"arrResults":arrResults,"affectedRows":affectedRows,"lastInsertedRowID":lastInsertedRowID]
    dispatch_sync(queryQueue, ^{
        [self executeQuery:query];
        [result setObject:[NSNumber numberWithInteger:self.affectedRows] forKey:@"affectedRows"];
        [result setObject:[NSNumber numberWithInteger:self.lastInsertedRowID] forKey:@"lastInsertedRowID"];
    });
    return result;
}
@end
/*
 1.sqlite3_open: This function is used to create and open a database file. It accepts two parameters, where the first one is the database file name, and the second a handler to the database. If the file does not exist, then it creates it first and then it opens it, otherwise it just opens it.
 2.sqlite3_prepare_v2: The purpose of this function is to get a SQL statement (a query) in string format, and convert it to an executable format recognizable by SQLite 3.
 3.sqlite3_step: This function actually executes a SQL statement (query) prepared with the previous function. It can be called just once for executable queries (insert, update, delete), or multiple times when retrieving data. It’s important to have in mind that it can’t be called prior to the sqlite3_preprare_v2 function.
 4.sqlite3_column_count: This method’s name it makes it easy to understand what is about. It returns the total number of columns (fields) a contained in a table.
 5.sqlite3_column_text: This method returns the contents of a column in text format, actually a C string (char *) value. It accepts two parameters: The first one is the query converted (compiled) to a SQLite statement, and the second one is the index of the column.
 6.sqlite3_column_name: It returns the name of a column, and its parameters are the same to the previous function’s.
 7.sqlite3_changes: It actually returns the number of the affected rows, after the execution of a query.
 8.sqlite3_last_insert_rowid: It returns the last inserted row’s ID.
 9.sqlite3_errmsg: It returns the description of a SQLite error.
 10.sqlite3_finalize: It deletes a prepared statement from memory.
 11.sqlite3_close: It closes an open database connection. It should be called after having finished any data exchange with the database, as it releases any reserved system resources.
 */


