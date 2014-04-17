//
//  HAMDataManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;
@class HAMHistoryHomepage;
@class HAMAppDelegate;

@interface HAMDataManager : NSObject

+ (HAMAppDelegate*)appDelegate;
+ (NSManagedObjectContext*)context;

+ (void)saveData;
+ (void)deleteRecord:(NSManagedObject*)object;
+ (void)clearData;
+ (HAMHomepageData*)newPageData;
+ (HAMHomepageData*)pageDataWithBID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;
+ (void)addAMarkedRecord:(HAMHomepageData*)home;
+ (void)removeMarkedRecord:(HAMHomepageData*)home;
+ (void)addAHistoryRecord:(HAMHomepageData*)home;
+ (NSArray*)fetchMarkedRecords;
+ (NSArray*)fetchHistoryRecords;
+ (void)updateHistoryRecord:(HAMHistoryHomepage*)history;

@end
