//
//  ZYSQLite3.h
//  FTMobileAgent
//
//  Created by hulilei on 2019/12/2.
//  Copyright © 2019 hll. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define FT_DB_TRACE_EVENT_TABLE_NAME @"trace_event"
@class FTRecordModel;
/// Tool for operating database data
@interface FTTrackerEventDBTool : NSObject
/// Whether to discard the latest data when logging type data exceeds the maximum value
@property (nonatomic, assign) BOOL discardNew;
/// Maximum number of logging type data in database
@property (nonatomic, assign) NSInteger dbLoggingMaxCount;
/// Singleton
+ (FTTrackerEventDBTool *)sharedManger;
/// Singleton
/// @param dbPath Database path
/// @param dbName Database name
+ (FTTrackerEventDBTool *)shareDatabaseWithPath:(nullable NSString *)dbPath dbName:(nullable NSString *)dbName;

/// Add an object to the database
/// @param item Data to record
-(BOOL)insertItem:(FTRecordModel *)item;

/// Add a group of objects to the database
/// @param items Data to record
-(BOOL)insertItemsWithDatas:(NSArray<FTRecordModel*> *)items;

/// Add a group of objects to the log cache
/// @param data Data to record
-(void)insertLoggingItems:(FTRecordModel *)data;

/// Add cached data to database
-(void)insertCacheToDB;

/// Get all data from database
-(NSArray *)getAllDatas;

/// Get data from the front end of the database according to specified type and quantity
/// @param recordSize Number of data records to get
/// @param type Data type
-(NSArray *)getFirstRecords:(NSUInteger)recordSize withType:(NSString *)type;
/// Delete uploaded data according to type
/// @param type Data type
/// @param tm Delete data before this time
-(BOOL)deleteItemWithType:(NSString *)type tm:(long long)tm;

/// Delete uploaded data according to type
/// @param type Data type
/// @param identify Delete data before this _id
-(BOOL)deleteItemWithType:(NSString *)type identify:(NSString *)identify;

/// Delete data before the given time
/// @param tm Delete time
-(BOOL)deleteItemWithTm:(long long)tm;

/// Delete log data
/// @param count Delete the first count data
-(BOOL)deleteLoggingItem:(NSInteger)count;

/// Get total number of database data
- (NSInteger)getDatasCount;

/// Get total number of data of a certain type in database
/// @param type Data type
- (NSInteger)getDatasCountWithType:(NSString *)type;

@end
NS_ASSUME_NONNULL_END
