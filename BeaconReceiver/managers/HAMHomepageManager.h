//
//  HAMHomepageManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;

@interface HAMHomepageManager : NSObject {
    NSTimer *updateTimer;
    NSMutableArray *thingsInWorld;
}

+ (HAMHomepageManager*)homepageManager;

+ (HAMHomepageData*)homepageWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

+ (void)homepageFromWebWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor;

@end
