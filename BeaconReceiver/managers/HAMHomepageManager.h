//
//  HAMHomepageManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;

@protocol HAMHomepageManagerDelegate <NSObject>

- (void)updateThings:(NSArray*)thingsAround;

@end

@interface HAMHomepageManager : NSObject {
    NSTimer *updateTimer;
    NSMutableArray *thingsInWorld;
}

@property (nonatomic, retain) id<HAMHomepageManagerDelegate> delegate;

+ (HAMHomepageManager*)homepageManager;

+ (HAMHomepageData*)homepageWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

+ (void)homepageFromWebWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor;

@end
