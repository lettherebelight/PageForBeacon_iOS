//
//  HAMHomepageManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;

@interface HAMHomepageManager : NSObject

+ (HAMHomepageData*)homepageWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

+ (void) addHomepage:(HAMHomepageData*) home;

+ (NSMutableDictionary*) homepageDict;
+ (NSMutableArray*) homepageVisited;


@end
