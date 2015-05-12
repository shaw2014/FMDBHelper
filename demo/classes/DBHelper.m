//
//  DBHelper.m
//  BidMarket
//
//  Created by shaw on 15/5/9.
//  Copyright (c) 2015年 shaw. All rights reserved.
//

#import "DBHelper.h"
#import <objc/runtime.h>
#import "NSObject+Property.h"

@implementation DBHelper

const static NSString* normalTypesString = @"floatdoublelong";
const static NSString* intTypesString = @"intcharshort";
const static NSString* dateTypeString = @"NSDate";
const static NSString* blobTypeString = @"NSDataUIImage";

+(DBHelper *)helper
{
    static DBHelper *dbHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbHelper = [[DBHelper alloc]init];
    });
    
    return dbHelper;
}

/**
 *	get sqliteType
 *
 *	@param	type	property type
 *
 *	@return sqltype
 */
- (NSString *)sqliteTypeWithPropertyType:(NSString *)type
{
    if([intTypesString rangeOfString:type].location != NSNotFound){
        return K_SQLTYPE_Int;
    }
    if ([normalTypesString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Double;
    }
    if ([blobTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Blob;
    }
    if ([dateTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Date;
    }
    return K_SQLTYPE_Text;
}

+(NSString *)getDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = paths[0];
    dbPath = [dbPath stringByAppendingPathComponent:@"demo.sqlite"];
    
    NSLog(@"database path is ==============%@",dbPath);
    return dbPath;
}

+(FMDatabase *)database
{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDBPath]];
    if(![db open])
    {
        return nil;
    }
    
    return db;
}

-(void)createTableWithModel:(MTLModel<MTLFMDBSerializing> *)model
{
    FMDatabase *db = [DBHelper database];
    
    if(db)
    {
        NSString *tableName = [model.class FMDBTableName];
        NSMutableString *sql = [[NSMutableString alloc] init];
        
        if (!tableName) {
            tableName = [NSString  stringWithUTF8String:class_getName(model.class)];
        }
        
        [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName] ;
        
        NSDictionary *propertyInfoDic = [model propertyInfoDictionary];
        NSMutableArray* propertyNameArray = [propertyInfoDic objectForKey:@"name"];
        NSMutableArray* propertyTypeArray = [propertyInfoDic objectForKey:@"type"];
        
        //primaryKey
        NSString *primaryKey = [model.class FMDBPrimaryKeys][0];
        
        NSInteger count = propertyNameArray.count;
        for (int i = 0; i < count; i++)
        {
            if (i > 0)
            {
                [sql appendString:@","];
            }
            
            NSString *propertyName = propertyNameArray[i];
            NSString *propertyType = propertyTypeArray[i];
            
            [sql appendFormat:@"%@ %@ ",propertyName, [self sqliteTypeWithPropertyType:propertyType]];
            
            if (primaryKey && [propertyName isEqualToString:primaryKey])
            {
                [sql appendString:@"PRIMARY KEY"];
            }
        }
        [sql appendString:@")"];
        
        [db executeUpdate:sql];
        
        NSLog(@"create table sql is : %@",sql);
    }
}

-(void)insertTableWithModel:(MTLModel<MTLFMDBSerializing> *)model
{
    FMDatabase *db = [DBHelper database];
    
    if(db)
    {
        NSString *stmt = [MTLFMDBAdapter insertStatementForModel:model];
        
        NSArray *columnValues = [MTLFMDBAdapter columnValues:model];
        
        [db executeUpdate:stmt withArgumentsInArray:columnValues];
    }
}

-(void)updateTableWithModel:(MTLModel<MTLFMDBSerializing> *)model
{
    FMDatabase *db = [DBHelper database];
    
    if(db)
    {
        NSString *stmt = [MTLFMDBAdapter updateStatementForModel:model];
        
        NSArray *columnValues = [MTLFMDBAdapter columnValues:model];
        
        [db executeUpdate:stmt withArgumentsInArray:columnValues];
    }
}

-(void)deleteTableWithModel:(MTLModel<MTLFMDBSerializing> *)model
{
    FMDatabase *db = [DBHelper database];
    
    if(db)
    {
        NSString *stmt = [MTLFMDBAdapter deleteStatementForModel:model];
        
        [db executeUpdate:stmt];
    }
}

-(id)selectFromTableWithModel:(MTLModel<MTLFMDBSerializing> *)model
{
    NSString *tableName = [model.class FMDBTableName];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1=1",tableName];
    if (model)
    {
        //遍历所有字段
        NSArray *columnArray = [model propertyArray];
        for (NSString *field in columnArray)
        {
            id value = [model safetyValueForKey:field];
            if (value != nil && ![value isEqualToString:[NSString string]]) {
                [sql appendFormat:@" and %@ = '%@'",field,value];
            }
        }
    }
    
    NSLog(@"条件查询sql:%@",sql);
    
    return [self query2ObjectArray:model sql:sql];
}

-(id)query2ObjectArray:(MTLModel<MTLFMDBSerializing> *)model sql:(NSString *)sql
{
    FMDatabase *db = [DBHelper database];
        
    FMResultSet *rs = [db executeQuery:sql];
    
    if (!rs) {
        [db close];
        return nil;
    }
    
    NSMutableArray *dataList = [NSMutableArray array];
    
    while([rs next])
    {
        MTLModel *resultModel = [MTLFMDBAdapter modelOfClass:model.class fromFMResultSet:rs error:nil];
        [dataList addObject:resultModel];
    }
    
    if(dataList.count > 1)
    {
        return dataList;
    }
    else
    {
        return dataList[0];
    }
    
    return nil;
}

@end
