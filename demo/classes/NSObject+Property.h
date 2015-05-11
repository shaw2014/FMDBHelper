//
//  NSObject+Property.h
//  FMDBOrmHandler
//
//  Created by caohuan on 14-07-05.
//  Copyright (c) 2014年 hc. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#define K_SQLTYPE_Text @"text"
#define K_SQLTYPE_Date @"Date"
#define K_SQLTYPE_Int @"integer"
#define K_SQLTYPE_Double @"float"
#define K_SQLTYPE_Blob @"blob"
#define K_SQLTYPE_Null @"null"
#define K_SQLTYPE_PrimaryKey @"primary key"

@interface NSObject (Property)

- (NSDictionary *)convertDictionary;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSString *)className;

#pragma mark - extend
/**
 *	获取对象的属性列表
 *
 *	@return	属性列表
 */
- (NSArray *)propertyArray;

/**
 *	根据类反射获取对象属性类型字典
 *
 *	@return	property info
 */
- (NSDictionary *)propertyInfoDictionary;

/**
 *  安全的获取属性值
 *
 *	@param	valueKey	property name
 *
 *	@return	value
 */
- (id)safetyValueForKey:(NSString*)key;

/**
 @Deprecated
 
 *	不安全的获取属性值，仅当属性为对象的时候是安全的
 *
 *	@param	valueKey	property name
 *
 *	@return	value
 */
- (id)dangerousValueForKey:(NSString*)key;

@end
