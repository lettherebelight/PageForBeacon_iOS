//
//  HAMDBManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCoupon.h"
#import "HAMCouponTimeRecord.h"

#import "HAMDBManager.h"
#import "HAMFileTools.h"
#import "HAMTools.h"
#import "HAMLogTool.h"

#define DBNAME @"beacon.db"
#define DB_COUPON_IDCOUPON @"ID_COUPON"
#define DB_COUPON_IDBID @"ID_BID"
#define DB_COUPON_IDBMAJOR @"ID_BMAJOR"
#define DB_COUPON_IDBMINOR @"ID_BMINOR"

#define DB_COUPON_TIMECREATED @"TIME_CREATED"
#define DB_COUPON_TIMEUPDATED @"TIME_UPDATED"

#define DB_COUPON_TITLE @"TITLE"
#define DB_COUPON_THUMBNAIL @"THUMBNAIL"
#define DB_COUPON_DESCBRIEF @"DESC_BRIEF"
#define DB_COUPON_DESCURL @"DESC_URL"

#define DB_COUPON_PROMOTE @"PROMOTE"

#define DB_COUPON_ALLFIELD DB_COUPON_IDCOUPON, DB_COUPON_IDBID, DB_COUPON_IDBMAJOR, DB_COUPON_IDBMINOR, DB_COUPON_TIMECREATED, DB_COUPON_TIMEUPDATED, DB_COUPON_TITLE, DB_COUPON_THUMBNAIL, DB_COUPON_DESCBRIEF, DB_COUPON_DESCURL, DB_COUPON_PROMOTE

static HAMDBManager* dbManager = nil;

@implementation HAMDBManager
{
    sqlite3* database;
    
    Boolean dbIsOpen;
}

#pragma mark - Singleton Methods

+ (HAMDBManager*)dbManager{
    @synchronized(self) {
        if (dbManager == nil)
            dbManager = [[HAMDBManager alloc] init];
    }
    
    return dbManager;
}

- (id)init{
    if (self = [super init]) {
        dbIsOpen = false;
    }
    
    return self;
}

#pragma mark - Open & Close

-(Boolean)openDatabase
{
    if (dbIsOpen)
    {
        [HAMLogTool warn:@"Trying to open database when database is already open!"];
        return true;
    }
    
    if (sqlite3_open([[HAMFileTools filePath:DBNAME] UTF8String], &database)
        != SQLITE_OK)
    {
        sqlite3_close(database);
        [HAMLogTool error:@"Fail to open database!"];
        return false;
    }
    
    dbIsOpen=YES;
    return true;
}

-(void)closeDatabaseWithStatement:(sqlite3_stmt*)statement
{
    if (!dbIsOpen)
        return;
    
    if (statement != nil) {
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    dbIsOpen=NO;
}

-(void)closeDatabase
{
    if (!dbIsOpen)
        return;
    
    sqlite3_close(database);
    dbIsOpen=NO;
}

#pragma mark - Common Methods

-(Boolean)isDatabaseExist
{
    int rc = sqlite3_open_v2([[HAMFileTools filePath:DBNAME] UTF8String], &database, SQLITE_OPEN_READWRITE, NULL);
    if (rc == 0)
        sqlite3_close(database);
    return rc == 0;
}

-(Boolean)runSQL:(NSString*)sql
{
    char *errorMsg;
    
    [self openDatabase];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        [HAMLogTool error:[NSString stringWithFormat:@"Run SQL '%@' fail : %s",sql,errorMsg]];
        [self closeDatabase];
        return false;
    }
    [self closeDatabase];
    return true;
}

-(NSString*)stringOfStatement:(sqlite3_stmt*)statement at:(int)column
{
    char* text=(char*)sqlite3_column_text(statement, column);
    
    if (text)
        return [NSString stringWithUTF8String:text];
    else
        return nil;
}

-(void)bindString:(NSString*)string toStatement:(sqlite3_stmt*)statement at:(int)column{
    sqlite3_bind_text(statement, column, [string UTF8String], -1, NULL);
}

#pragma mark - Clear & Init

- (void)clear{
//    [self runSQL:@"DELETE FROM COUPON;"];
    [self runSQL:@"DROP TABLE IF EXISTS COUPON;"];
    [self initDatabase];
}

- (void)initDatabase{
    [self runSQL:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS COUPON (%@ varchar(36) primary key, %@ varchar(36), %@ int, %@ int, %@ INTEGER, %@ INTEGER, %@ nvarchar(50), %@ varchar(255), %@ nvarchar(200), %@ varchar(255), %@ int);",DB_COUPON_ALLFIELD]];
    [self runSQL:@"CREATE TABLE IF NOT EXISTS COUPON_VISIT_HISTORY (ID_COUPON varchar(36), TIME_VISITED INTEGER);"];
    [self runSQL:@"CREATE TABLE IF NOT EXISTS COUPON_NOTIFY_HISTORY (ID_COUPON varchar(36), TIME_NOTIFIED INTEGER);"];
}

#pragma mark - Coupon Methods

-(void)insertCoupon:(HAMCoupon*)coupon
{
    [self openDatabase];
    
    NSString* update=[NSString stringWithFormat:@"INSERT INTO COUPON (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",DB_COUPON_ALLFIELD];
    
    sqlite3_stmt* statement;
    
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        [self bindString:coupon.idCoupon toStatement:statement at:1];
        [self bindString:coupon.idBid toStatement:statement at:2];
        sqlite3_bind_int(statement, 3, [coupon.idBmajor intValue]);
        sqlite3_bind_int(statement, 4, [coupon.idBminor intValue]);
        
        sqlite3_bind_int64(statement, 5, [HAMTools longLongFromDate:coupon.timeCreated]);
        sqlite3_bind_int64(statement, 6, [HAMTools longLongFromDate:coupon.timeUpdated]);
        
        [self bindString:coupon.title toStatement:statement at:7];
        [self bindString:coupon.thumbNail toStatement:statement at:8];
        [self bindString:coupon.descBrief toStatement:statement at:9];
        [self bindString:coupon.descUrl toStatement:statement at:10];
        
        int promote = coupon.promote ? 1 : 0;
        
        sqlite3_bind_int(statement, 11, promote);
    }
    
    if (sqlite3_step(statement)!= SQLITE_DONE)
        [HAMLogTool error:@"Fail to insert into coupon!"];
    
    [self closeDatabaseWithStatement:statement];
}

-(HAMCoupon*)couponFromStatement:(sqlite3_stmt*)statement{
    HAMCouponBuilder* couponBuilder = [[HAMCouponBuilder alloc] init];
    
    couponBuilder.idCoupon = [self stringOfStatement:statement at:0];
    couponBuilder.idBid = [self stringOfStatement:statement at:1];
    couponBuilder.idBmajor = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
    couponBuilder.idBminor = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
    
    long long timeCreatedSince1970 = sqlite3_column_int64(statement, 4);
    couponBuilder.timeCreated = [HAMTools dateFromLongLong:timeCreatedSince1970];
    long long timeUpdatedSince1970 = sqlite3_column_int64(statement, 5);
    couponBuilder.timeUpdated = [HAMTools dateFromLongLong:timeUpdatedSince1970];
    
    couponBuilder.title = [self stringOfStatement:statement at:6];
    couponBuilder.thumbNail = [self stringOfStatement:statement at:7];
    couponBuilder.descBrief = [self stringOfStatement:statement at:8];
    couponBuilder.descUrl = [self stringOfStatement:statement at:9];
    
    int promote = sqlite3_column_int(statement, 10);
    couponBuilder.promote = promote == 1 ? YES : NO;
    
    return [couponBuilder build];
}

-(HAMCoupon*)couponWithID:(NSString*)couponID
{
    [self openDatabase];
    
    sqlite3_stmt* statement;
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT * FROM COUPON WHERE %@ = '%@'", DB_COUPON_IDCOUPON, couponID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from Coupon!"];
        [self closeDatabaseWithStatement:statement];
        return nil;
    }
    
    HAMCoupon* coupon;
    if (sqlite3_step(statement) == SQLITE_ROW) {
        coupon = [self couponFromStatement:statement];
    }
    else {
        coupon = nil;
        [HAMLogTool warn:[NSString stringWithFormat: @"Coupon not found with ID : %@",couponID]];
    }
    
    [self closeDatabaseWithStatement:statement];
    return coupon;
}

-(HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor
{
    if (beaconID == nil || major == nil || minor == nil) {
        return nil;
    }
    
    [self openDatabase];
    
    sqlite3_stmt* statement;
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT * FROM COUPON WHERE %@ = '%@' AND %@ = %@ AND %@ = %@", DB_COUPON_IDBID, beaconID, DB_COUPON_IDBMAJOR, major, DB_COUPON_IDBMINOR, minor];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from Coupon!"];
        [self closeDatabaseWithStatement:statement];
        return nil;
    }

    HAMCoupon* coupon;
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        coupon = [self couponFromStatement:statement];
    }
    else {
        coupon = nil;
        [HAMLogTool warn:[NSString stringWithFormat: @"Coupon not found with BeaconID : %@", beaconID]];
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        [HAMLogTool warn:[NSString stringWithFormat: @"Duplicate coupon found with bid:%@ major:%@ minor:%@", beaconID, major, minor]];
    }
    
    [self closeDatabaseWithStatement:statement];
    return coupon;
}


#pragma mark - Beacon Methods

//TODO: change to select from table beacon
-(NSArray*)beaconIDArray{
    [self openDatabase];
    
    sqlite3_stmt* statement;
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT %@ FROM COUPON", DB_COUPON_IDBID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from COUPON!"];
        [self closeDatabaseWithStatement:statement];
        return nil;
    }
    
    NSMutableArray* beaconIDArray = [NSMutableArray array];
    while (sqlite3_step(statement) == SQLITE_ROW){
        [beaconIDArray addObject:[self stringOfStatement:statement at:0]];
    }
    
    [self closeDatabaseWithStatement:statement];
    return [NSArray arrayWithArray:beaconIDArray];
}

#pragma mark - Coupon Visit History Methods

-(void)insertVisitRecord:(HAMCouponTimeRecord*)record
{
    [self openDatabase];
    
    NSString* update = @"INSERT INTO COUPON_VISIT_HISTORY (ID_COUPON, TIME_VISITED) VALUES (?, ?);";
    
    sqlite3_stmt* statement;
    
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        [self bindString:record.couponID toStatement:statement at:1];
        sqlite3_bind_int64(statement, 2, [HAMTools longLongFromDate:record.time]);
    }
    
    if (sqlite3_step(statement)!= SQLITE_DONE)
        [HAMLogTool error:@"Fail to insert into COUPON_VISIT_HISTORY!"];
    
    [self closeDatabaseWithStatement:statement];
}

-(NSArray*)couponVisitHistory{
    [self openDatabase];
    
    sqlite3_stmt* statement;
    
    NSString* query = @"SELECT ID_COUPON, MAX(TIME_VISITED) FROM COUPON_VISIT_HISTORY GROUP BY ID_COUPON ORDER BY MAX(TIME_VISITED) DESC";
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from COUPON_VISIT_HISTORY!"];
        [self closeDatabaseWithStatement:statement];
        return nil;
    }
    
    NSMutableArray* recordArray = [NSMutableArray array];
    while (sqlite3_step(statement) == SQLITE_ROW){
        NSString* couponID = [self stringOfStatement:statement at:0];
        long long dateInLongLong = sqlite3_column_int64(statement, 1);
        NSDate* visitedDate = [HAMTools dateFromLongLong:dateInLongLong];
        [recordArray addObject:[HAMCouponTimeRecord recordWithCouponID:couponID time:visitedDate]];
    }
    
    [self closeDatabaseWithStatement:statement];
    return [NSArray arrayWithArray:recordArray];
}

#pragma mark - Coupon Notify History Methods

-(void)insertNotifyRecord:(HAMCouponTimeRecord*)record
{
    [self openDatabase];
    
    NSString* update = @"INSERT INTO COUPON_NOTIFY_HISTORY (ID_COUPON, TIME_NOTIFIED) VALUES (?, ?);";
    
    sqlite3_stmt* statement;
    
    if (sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        [self bindString:record.couponID toStatement:statement at:1];
        sqlite3_bind_int64(statement, 2, [HAMTools longLongFromDate:record.time]);
    }
    
    if (sqlite3_step(statement)!= SQLITE_DONE)
        [HAMLogTool error:@"Fail to insert into COUPON_NOTIFY_HISTORY!"];
    
    [self closeDatabaseWithStatement:statement];
}

-(NSDate*)couponLastNotifyTimeWithID:(NSString*)couponID{
    [self openDatabase];
    
    sqlite3_stmt* statement;
    
    NSString* query = [NSString stringWithFormat: @"SELECT MAX(TIME_NOTIFIED) FROM COUPON_NOTIFY_HISTORY WHERE ID_COUPON = '%@'", couponID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        [HAMLogTool error:@"Fail to select from COUPON_NOTIFY_HISTORY!"];
        [self closeDatabaseWithStatement:statement];
        return nil;
    }
    
    NSDate* lastNotifyTime;
    if (sqlite3_step(statement) == SQLITE_ROW){
        long long lastNotifyTimeInLongLong = sqlite3_column_int64(statement, 0);
        lastNotifyTime = [HAMTools dateFromLongLong:lastNotifyTimeInLongLong];
    }
    else{
        lastNotifyTime = nil;
    }
    
    [self closeDatabaseWithStatement:statement];
    return lastNotifyTime;
}


@end