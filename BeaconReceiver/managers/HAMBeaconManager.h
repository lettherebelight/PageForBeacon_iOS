//
//  HAMBeaconManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol HAMBeaconManagerDelegate <NSObject>

- (void)displayHomepage:(NSArray*) homepageArray;

@end

@interface HAMBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) id<HAMBeaconManagerDelegate> delegate;

- (void)startMonitor;

+ (HAMBeaconManager*)beaconManager;
+ (NSArray*)beaconIDArray;
+ (void)setNotifyStatus:(Boolean)status;
+ (void)setBackGroundStatus:(Boolean)status;

@end
