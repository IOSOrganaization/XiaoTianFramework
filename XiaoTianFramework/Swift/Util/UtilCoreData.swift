//
//  UtilCoreData.swift
//  SupplierApp
//  1.创建sqlite文件或自动生成(初始化的时候系统会自动生成/拷贝)
//  2.创建实体模型文件 xxx.xcdatamodeld
//  3.在模型中创建实体Entity,添加约束,关联,
//  4.手动写模型实体类/自动生成模型实体类(配置代码生成模式,进行生成代码)
//  5.执行相关操作
//  Created by guotianrui on 2017/6/1.
//  Copyright © 2017年 vsix. All rights reserved.
//

import Foundation
import CoreData

@objc(UtilCoreDataXT)
open class UtilCoreData: NSObject{
    // Code Data : SQLite(存取速度快),Atomic(存取相对比较慢,如果数据量大),In-memory(存取很快,但是只保存在内存)
    var datamodeldFilename: String!
    var sqliteFilename: String!
    var queryQueue: DispatchQueue?
    
    /// 对象管理上下文
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil{
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    /// 持久化协调类
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator! = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var storeURL = self.applicationDocumentsDirectory.appendingPathComponent(self.sqliteFilename)
        do{
            Mylog.log(storeURL)
            // 数据转移自动匹配选项
            //let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }catch{
            var error = NSError(domain: "UtilCoreData", code: 9999, userInfo: [NSLocalizedDescriptionKey:"Failed to initialize the application's saved data",NSLocalizedFailureReasonErrorKey:"There was an error creating or loading the application's saved data.",NSUnderlyingErrorKey: error])
            Mylog.log("Unresolved error \(error), \(error.userInfo)")
            abort() // 抛出异常中断
        }
        return coordinator
    }()
    /// 模型管理 .xcdatamodeld文件,编译后后缀名为.momd[包含管理的模式]
    lazy var managedObjectModel: NSManagedObjectModel! = {
        let modelURL = Bundle.main.url(forResource: self.datamodeldFilename, withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)
    }()
    
    /***************************** SQL持久化构造器 *****************************/
    public convenience init(sqliteFilename:String, datamodeld: String) {
        self.init()
        self.sqliteFilename = sqliteFilename
        self.datamodeldFilename = datamodeld
        self.copyDatabaseIntoDocumentsDirectory(sqliteFilename)
    }
    private func copyDatabaseIntoDocumentsDirectory(_ sqliteFilename: String){
        let fm = FileManager.default
        let bundleSqliteFile = Bundle.main.path(forResource: sqliteFilename, ofType: "sqlite")
        if let bundleSqliteFile = bundleSqliteFile{
            let storeURL = applicationDocumentsDirectory.appendingPathComponent(sqliteFilename)
            if !fm.fileExists(atPath: storeURL!.path){
                //fm.removeItem(atPath: storeURL!.path)
                do{
                    try fm.copyItem(atPath: bundleSqliteFile, toPath: storeURL!.path)
                }catch{
                    Mylog.log("Copy \(sqliteFilename).sqlite to DocumentsDirectory error: \(error.localizedDescription)")
                }
            }
        }
    }
    /// 保存当前上下文
    public func saveContext(){
        if(managedObjectContext!.hasChanges){
            UtilDispatch.syncTaskMain {
                do{
                    try self.managedObjectContext?.save()
                }catch{
                    Mylog.log("Unresolved error \(error)")
                    abort()
                }
            }
        }
        
    }
    /// undo 管理器
    public func undoManager() -> UndoManager{
        if let undoManager = self.managedObjectContext?.undoManager{
            return undoManager
        }
        let undoManager = UndoManager()
        self.managedObjectContext?.undoManager = undoManager
        return undoManager
    }
    public func enableUndoRegistration(){
        // 默认undo是byevent的,如果要开启undobyGroup,要把byevent关闭
        let undoManager = self.undoManager()
        if !undoManager.isUndoRegistrationEnabled{
            undoManager.enableUndoRegistration()
        }
    }
    public func disableUndoRegistration(){
        let undoManager = self.undoManager()
        if undoManager.isUndoRegistrationEnabled{
            undoManager.disableUndoRegistration()
        }
    }
    public func beginUndoRegistrationGrouping(){
        let undoManager = self.undoManager()
        if undoManager.groupsByEvent{
            undoManager.groupsByEvent = false
        }
        undoManager.beginUndoGrouping()
    }
    public func endUndoRegistrationGrouping(){
        let undoManager = self.undoManager()
        undoManager.endUndoGrouping()
    }
    /// 重置缓冲上下文
    public func reset(){
        self.managedObjectContext?.reset()
    }
    /// class Method
    /***************************** 增 *****************************/
    /// Create New Object And Insert To Context
    public func createAndInsertNewObjectToContext<T>(_ entityName:String,_ clazz:T.Type) -> T? where T : NSManagedObject{
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.managedObjectContext!) as? T
    }
    /***************************** 删 *****************************/
    /// Delete Entity Object
    public func deleteObject<T>(_ entityObject:T?) where T : NSManagedObject{
        self.managedObjectContext?.delete(entityObject!)
    }
    /***************************** 查/改 *****************************/
    /// Fetch Context Entity Object Array
    public func executeFetch<T>(_ fetchRequest:NSFetchRequest<T>) -> [T]? where T : NSFetchRequestResult{
        do{
            return try self.managedObjectContext?.fetch(fetchRequest)
        }catch{
            Mylog.log(error)
            return nil
        }
    }
    public func executeCount<T>(_ fetchRequest:NSFetchRequest<T>) -> Int? where T : NSFetchRequestResult{
        do{
            return try self.managedObjectContext?.count(for: fetchRequest)
        }catch{
            Mylog.log(error)
            return nil
        }
    }
    /// 普通查询所有
    public func queryArrayObjectFromContext<T>(_ entityName:String,_ clazz:T.Type) -> [T]? where T : NSManagedObject{
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do{
            return try self.managedObjectContext?.fetch(fetchRequest)
        }catch{
            Mylog.log(error)
            return nil
        }
    }
    /// 带条件查询
    public func queryArrayObjectFromContext<T>(_ entityName:String,_ clazz:T.Type,_ whereStatement:String) -> [T]? where T : NSManagedObject{
        return queryArrayObjectFromContext(entityName, clazz, NSPredicate(format: whereStatement))
    }
    /// 带谓词查询
    public func queryArrayObjectFromContext<T>(_ entityName:String,_ clazz:T.Type,_ predicate:NSPredicate) -> [T]? where T : NSManagedObject{
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do{
            // NSPredicate 可以拼接: NSComparisonPredicate[NSExpression(forKeyPath:),NSExpression(forConstantValue:)]
            //let exprTitle = NSExpression(forKeyPath: "title")
            //let exprValue = NSExpression(forConstantValue: "The first book")
            //let predicate = NSComparisonPredicate(leftExpression: exprTitle, rightExpression: exprValue, modifier: .direct, type: .equalTo, options: [])
            fetchRequest.predicate = predicate // Predicate Search Language(String结果拼接到sql的where语句后面)
            return try self.managedObjectContext?.fetch(fetchRequest)
        }catch{
            Mylog.log(error)
            return nil
        }
    }
    /// 批量更新,速度更快
    public func update(_ entityName:String,_ propertiesToUpdate:[String:Any]) -> NSBatchUpdateResult?{
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        batchUpdateRequest.resultType = .updatedObjectsCountResultType
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate //["name":"xiaotian"]
        do{
            return try managedObjectContext?.execute(batchUpdateRequest) as? NSBatchUpdateResult
        }catch{
            Mylog.log(error)
        }
        return nil
    }
    // 批量更新,带谓词
    public func update(_ entityName:String,_ propertiesToUpdate:[String:Any],_ predicate: NSPredicate) -> NSBatchUpdateResult?{
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        batchUpdateRequest.resultType = .updatedObjectsCountResultType
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate //["name":"xiaotian"]
        batchUpdateRequest.predicate = predicate
        do{
            return try managedObjectContext?.execute(batchUpdateRequest) as? NSBatchUpdateResult
        }catch{
            Mylog.log(error)
        }
        return nil
    }
    /// 统计总数
    public func count(_ entityName:String) -> Int?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do{
            return try self.managedObjectContext?.count(for: fetchRequest)
        }catch{
            return nil
        }
    }
    public func count(_ entityName:String,_ predicate: NSPredicate) -> Int?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do{
            fetchRequest.predicate = predicate
            return try self.managedObjectContext?.count(for: fetchRequest)
        }catch{
            return nil
        }
    }
    public func filterByFetchedPropertyName<T>(_ fetchedResultObject:T,_ fetchedPropertyName:String) -> Any? where T : NSManagedObject{
        // Fetched property(这个功能作用不大,没什么卵用)
        //1. fectPropertyName模型里面的Fected Property名称(这个是KVC针对NSObject对象进行过滤)
        //2. 编写Fected Property有三个参数
        //      a.名称 name
        //      b.目标 destination
        //      c.谓语查询语句 predicate(SELF:代表当前的目录,$FETCH_SOURCE:代表当前执行的对象 eg: SELF.price < 30 AND (SELF.category=$FETCH_SOURCE))
        return fetchedResultObject.value(forKeyPath: fetchedPropertyName)
    }
    /***************************** 谓词查询条件 NSPredicate *****************************/
    public func createPredicatKeyPathBetween(_ propertyFieldName: String,_ range: Range<Int>) -> NSPredicate{
        let length = NSExpression(forKeyPath: propertyFieldName)
        let lower = NSExpression(forConstantValue: range.lowerBound)
        let upper = NSExpression(forConstantValue: range.upperBound)
        let expr = NSExpression(forAggregate: [lower, upper])
        /*
         modifier:
         1.direct: X     Compares the left expression directly to the right expression
         2.all: ALL X    Compares the left expression (a collection) to the right expression, returning YES only if all the values match
         3.any: ANY X    Compares the left expression (a collection) to the right expression, returning YES if any of the values match
         
         type:
         1.lessThan:             L< R
         2.lessThanOrEqualTo:    L <= R
         3.greaterThan:          L > R
         4.greaterThanOrEqualTo: L >= R
         5.equalTo:              L = R
         6.notEqualTo:           L != R
         7.matches:              L MATCHES R (正则匹配)
         8.like:                 L LIKE R ('b*ball’ would match baseball and basketball but not football)
         9.beginsWith:           L BEGINSWITH R
         10.endsWith:            L ENDSWITH R
         11.`in`:                L IN R
         12.customSelector:
         13.contains:            L CONTAINS R
         14.between:             L BETWEEN R
         
         options:
         1.caseInsensitive:      The comparison is case-insensitive(忽略大小写)
         2.diacriticInsensitive: The comparison overlooks accents(忽略发音符)
         3.normalized:           Indicates that the operands have been preprocessed (made all the same
         case, accents removed, etc.), so NSCaseInsensitivePredicateOption and NSDiacriticInsensitivePredicateOption options can be ignored
         
         NSCompoundPredicate: 多个合并谓词条件
         1.andPredicateWithSubpredicates:    P1 AND P2 AND P3
         2.orPredicateWithSubpredicates:     P1 OR P2 OR P3
         3.notPredicateWithSubpredicate:     NOT P
         
         Aggregating: 统计
         1.公式: (key path to collection).@(operator).(key path to argument property)
         operator:
         a.avg
         b.count
         c.min
         d.max
         f.sum
         eg. words.@count > 10000 (字数worlds合计大于10000)
         */
        return NSComparisonPredicate(leftExpression: length, rightExpression: expr, modifier: .direct, type: .between, options: [.caseInsensitive])
    }
    /***************************** 排序 NSSortDescriptor *****************************/
    @objc(createSortDescriptorPropertyFieldName:ascending:)
    public class func createSortDescriptor(_ propertyFieldName: String,_ ascending: Bool) -> NSSortDescriptor{
        return NSSortDescriptor(key: propertyFieldName, ascending: ascending)
    }
    
    private var applicationDocumentsDirectory: NSURL{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1] as NSURL
    }
    
    /***************************** 队列调度,必须保持单例 *****************************/
    // 查询
    /// 异步查询
    @objc(queueExecuteQueryAsync:)
    public func queueExecuteQueryAsync(_ execute: @escaping () -> Void){
        if queryQueue == nil{
            queryQueue = DispatchQueue(label: "DispatchQueue_UtilCoreData_QueryQueue")
        }
        UtilDispatch.asyncTask {
            UtilDispatch.syncTask(self.queryQueue!, execute)
        }
    }
    /// 队列同步块查询
    @objc(queueExecuteQuery:)
    public func queueExecuteQuery(_ execute: @escaping () -> Any? ) -> Any?{
        if queryQueue == nil{
            queryQueue = DispatchQueue(label: "DispatchQueue_UtilCoreData_QueryQueue")
        }
        var result: Any?
        queryQueue?.sync {
            result = execute()
        }
        return result
    }
    /// 队列执行查询
    public func queueExecuteFectch<T>(_ fetchRequest:NSFetchRequest<T>) -> [T]? where T : NSFetchRequestResult{
        return executeFetch(fetchRequest)
    }
    /// 统计
    public func queueExecuteCount<T>(_ fetchRequest:NSFetchRequest<T>) -> Int? where T : NSFetchRequestResult{
        return executeCount(fetchRequest)
    }
    //1. 如果没有声明模型对应的实体,则默认对应于NSManagedObject [key-value coding (KVC)]
    //2. 自动生成实体类: Editor ➤ Create NSManagedObject Subclass... (默认生成的实体,不要改里面的源码,默认源码生成在build目录,当前目录是引用,所有属性,方法@NSManaged进行声明)
    //3.系统会自动query相关联的所有实体
    //
    //4. 类型匹配关系:
    //  Int16,Int32,Int64,Double,Float,Boolean:NSNumber
    //  Decimal: NSDecimalNumber
    //  Date: NSDate
    //  Binary Data: NSData
    //  Transformable: Any non-standard type(用户自定义类型)
    //
    // Relationships 关系
    //5. 创建关系,选择关系的字段,配置关系属性
    //  a.Optional: 是否时可选关系(是否可以为nil)
    //  b.Delete Rule:
    //      Cascade: The source object is deleted and any related destination objects are also deleted.
    //      Deny: If the source object is related to any destination objects, the deletion request fails and nothing is deleted.
    //      Nullify: The source object is deleted and any related destination objects have their inverse relationships set to nil.
    //      No Action: The source object is deleted and nothing changes in any related destination objects.
    
    //  c.Type: To Many(对多,这个关系对多个对象约束),To One(对单,这个关系只对单个对象约束)
    //      Count Minimum,Maximum: 约束的最小,最大对象个数限制(如果没有达到限制会报错误)
    //      Ordered: 对多是否排序
    //6. Predicates 谓词查询(条件查询: predicate query language)
    //7. 配置控制台打印所有SQL执行语句,Product->Scheme->Edit Scheme->Arguments->Arguments Passed On Launch
    //   添加配置: -com.apple.CoreData.SQLDebug 1
    //   配置输出级别: 1,2,3 the higher the number, the more information Core Data will log
    //
    // Console 查看命令:
    // 打开指定sqlite数据库文件,进去sqlite命令控制台: xxx.sqlite -exec sqlite3 {} \;
    // 查看创建表语句: .schema
    // select显示表头: .header on
    // select显示列对齐: .mode column
    //
    // 谓词 Predicate 查询 (NSExpression:表达式)
    //1. NSPredicate(format: "name = 'The first book'") 属性 = "xxx"
    //2. NSPredicate(format: "category.name = %@", "Biography") 属性.属性 = "xxx"
    //3. NSPredicate(format: "words.@count > %d", argumentArray: [10000]) worlds合计大于10000字
    // 排序 NSSortDescriptor
    //1. NSSortDescriptor(key: "length", ascending: true)
    //2. NSSortDescriptor(key: "text", ascending: false)
    //3. NSPredicate(format: "(name LIKE %@) OR (rating < %d)", "*e*ie*", 5) like非常耗时
    //4. NSPredicate(format: "(rating < %d) OR (name LIKE %@)", 5, "*e*ie*") like置后,速度更快
    //5. NSPredicate(format: "(SUBQUERY(selfies, $x, ($x.rating < %d) OR ($x.name LIKE %@)).@count > 0)", 5, "*e*ie*") 子查询
}
