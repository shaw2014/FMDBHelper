//
//  DBHelper.h
//  BidMarket
//
//  Created by shaw on 15/5/9.
//  Copyright (c) 2015年 shaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import "MTLFMDBAdapter.h"

@interface DBHelper : NSObject

+(DBHelper *)helper;

-(BOOL)createTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(BOOL)insertTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(BOOL)updateTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(BOOL)deleteTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(NSArray *)selectFromTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

@end
