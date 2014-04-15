//
//  HAMDBManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-19.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class HAMCoupon;
@class HAMCouponTimeRecord;

@interface HAMDBManager : NSObject

+(HAMDBManager*)dbManager;

- (void)clear;
- (void)initDatabase;

- (void)insertCoupon:(HAMCoupon*)coupon;
- (HAMCoupon*)couponWithID:(NSString*)couponID;
- (HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

-(NSArray*)beaconIDArray;

-(void)insertVisitRecord:(HAMCouponTimeRecord*)record;
-(NSArray*)couponVisitHistory;

-(void)insertNotifyRecord:(HAMCouponTimeRecord*)record;
-(NSDate*)couponLastNotifyTimeWithID:(NSString*)couponID;

@end