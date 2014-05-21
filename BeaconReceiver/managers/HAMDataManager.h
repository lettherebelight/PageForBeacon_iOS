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
@class HAMGlobalData;

@interface HAMDataManager : NSObject

+ (HAMAppDelegate*)appDelegate;
+ (NSManagedObjectContext*)context;

+ (void)saveData;
+ (void)deleteRecord:(NSManagedObject*)object;
+ (HAMGlobalData*)globalData;

@end
