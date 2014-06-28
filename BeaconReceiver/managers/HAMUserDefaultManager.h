//
//  HAMUserDefaultManager.h
//  BeaconReceiver
//
//  Created by daiyue on 6/24/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMThing;

@interface HAMUserDefaultManager : NSObject

+ (HAMUserDefaultManager*)userDefaultManager;

#pragma mark - ThingNotificateDate

+ (void)recordThingNotificated:(HAMThing*)thing;
+ (Boolean)isThingNotificatedRecently:(HAMThing*)thing;

#pragma mark - ThingBoundToBeacon

+ (void)recordThing:(HAMThing*)thing isBoundToBeacon:(NSString*)isBoundToBeacon;
+ (NSString*)isThingBoundToBeaconInCache:(HAMThing*)thing;

@end
