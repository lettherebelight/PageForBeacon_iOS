//
//  HAMBeaconManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeaconManager.h>

@class HAMHomepageData;

@protocol HAMBeaconManagerDelegate <NSObject>

//- (void)displayHomepage:(HAMHomepageData*)homepage;
- (void)displayHomepage:(NSArray*)stuffsAround;

@end

@interface HAMBeaconManager_estSDK : NSObject <ESTBeaconManagerDelegate>

@property (nonatomic, retain) id<HAMBeaconManagerDelegate> delegate;
@property (nonatomic, retain) id<HAMBeaconManagerDelegate> detailDelegate;
@property ESTBeacon *nearestBeacon;

- (void)setupESTBeaconManager;
- (void)startMonitor;
- (void)stopMonitor;

+ (HAMBeaconManager*)beaconManager;
+ (NSArray*)beaconIDArray;
+ (void)setBackGroundStatus:(Boolean)status;

@end
