//
//  HAMBeaconManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class HAMHomepageData;

@protocol HAMBeaconManagerDelegate <NSObject>

- (void)displayHomepage:(HAMHomepageData*)homepage;

@end

@interface HAMBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) id<HAMBeaconManagerDelegate> delegate;
@property (nonatomic, retain) id<HAMBeaconManagerDelegate> detailDelegate;

- (void)startMonitor;

+ (HAMBeaconManager*)beaconManager;
+ (NSArray*)beaconIDArray;
+ (void)setNotifyStatus:(Boolean)status;
+ (void)setBackGroundStatus:(Boolean)status;

@end
