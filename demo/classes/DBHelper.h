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

-(void)createTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(void)insertTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(void)updateTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

-(void)deleteTableWithModel:(MTLModel<MTLFMDBSerializing> *)model;

@end
