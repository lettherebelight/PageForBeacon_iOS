//
//  HAMDataManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;
@class HAMAppDelegate;

@interface HAMDataManager : NSObject

+ (HAMAppDelegate*)appDelegate;
+ (NSManagedObjectContext*)context;

+ (void)clearData;
+ (void)addAMarkedRecord:(HAMHomepageData*)home;
+ (void)addAHistoryRecord:(HAMHomepageData*)home;
+ (NSArray*)fetchMarkedRecords;
+ (NSArray*)fetchHistoryRecords;

@end
