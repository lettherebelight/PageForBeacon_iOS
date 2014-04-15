//
//  HAMBeaconManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconManager.h"
#import "HAMLogTool.h"
#import "HAMHomepageData.h"
#import "HAMHomepageManager.h"

@implementation HAMBeaconManager
@synthesize delegate;

static HAMBeaconManager* beaconManager = nil;

NSMutableArray *beaconRegions;
CLLocationManager *locationManager;
CLBeacon *closestBeacon;
NSMutableArray *beaconsAround = nil;
bool allowNotify = YES;
bool isInBackground = NO;

+ (HAMBeaconManager*)beaconManager{
    @synchronized(self) {
        if (beaconManager == nil) {
            beaconManager = [[HAMBeaconManager alloc] init];
        }
    }
    return beaconManager;
}

+ (void)setNotifyStatus:(Boolean)status {
    allowNotify = status;
}

+ (void)setBackGroundStatus:(Boolean)status {
    isInBackground = status;
}

+ (NSArray*)beaconIDArray{
    NSMutableArray *beaconIDArray = [NSMutableArray arrayWithObjects:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"F62D3F65-2FCB-AB76-00AB-68186B10300D", nil];
    return beaconIDArray;
}


- (void)startMonitor {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = [HAMBeaconManager beaconManager];
    beaconRegions = [NSMutableArray array];
    closestBeacon = [[CLBeacon alloc] init];
    beaconsAround = [NSMutableArray array];
    
    for (NSString* BId in [HAMBeaconManager beaconIDArray])
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BId];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:BId];
        region.notifyEntryStateOnDisplay = YES;
        [beaconRegions addObject:region];
    }
    
    for (CLBeaconRegion* beaconRegion in beaconRegions)
    {
        [locationManager startMonitoringForRegion:beaconRegion];
        [locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)getAndDisplayHomepagesAround {
    if (delegate) {
        NSMutableArray *objectsAround;
        objectsAround = [NSMutableArray array];
        for (CLBeacon* beacon in beaconsAround) {
            HAMHomepageData *homepage = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
            if (homepage) {
                [objectsAround addObject:homepage];
            }
        }
        [delegate displayHomepage:objectsAround];
    }
}

- (NSArray*)removeBeaconByUUID:(NSString*)uuid {
    NSMutableArray *removedBeaconInfo;
    removedBeaconInfo = [NSMutableArray array];
    long i;
    for (i = [beaconsAround count] - 1; i >= 0; i--) {
        CLBeacon *beacon = [beaconsAround objectAtIndex:i];
        if ([beacon.proximityUUID.UUIDString isEqualToString:uuid]) {
            NSString *info = [NSString stringWithFormat:@"%@%@", beacon.major, beacon.minor];
            [removedBeaconInfo addObject:info];
            [beaconsAround removeObjectAtIndex:i];
        }
    }
    return removedBeaconInfo;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //[HAMLogTool debug:[NSString stringWithFormat:@"enter region: %@", region.identifier]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //[HAMLogTool debug:[NSString stringWithFormat:@"exit region: %@", region.identifier]];
    [self removeBeaconByUUID:region.identifier];
    [self getAndDisplayHomepagesAround];
}

- (BOOL)beacon:(CLBeacon *)beacon1 isCloserToBeacon:(CLBeacon *)beacon2 {
    if (beacon2 == nil)
    {
        return true;
    }
    else if (beacon1.proximity == CLProximityUnknown)
    {
        return false;
    }
    else if (beacon2.proximity == CLProximityUnknown)
    {
        return true;
    }
    else if (beacon1.proximity > beacon2.proximity)
    {
        return false;
    }
    else if (beacon1.proximity < beacon2.proximity)
    {
        return true;
    }
    else if (beacon1.accuracy < beacon2.accuracy)
    {
        return true;
    }
    else
    {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    bool needToNotificate = YES;
    
    NSArray *removedBeaconInfo = [self removeBeaconByUUID:region.identifier];
    
    for (CLBeacon* beacon in beacons) {
        if (beacon == nil || beacon.accuracy > 1) {
            continue;
        }
        NSString *currentBInfo = [NSString stringWithFormat:@"%@%@", beacon.major, beacon.minor];
        for (NSString *bInfo in removedBeaconInfo) {
            if ([currentBInfo isEqualToString:bInfo]) {
                needToNotificate = NO;
                break;
            }
        }
        long i;
        for (i = 0; i < [beaconsAround count]; i++) {
            if ([self beacon:beacon isCloserToBeacon:[beaconsAround objectAtIndex:i]]) {
                [beaconsAround insertObject:beacon atIndex:i];
                break;
            }
        }
        if (i == [beaconsAround count]) {
            [beaconsAround addObject:beacon];
        }
        if (allowNotify == YES && needToNotificate == YES && isInBackground == YES) {
            HAMHomepageData *homepage = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
            if (homepage != nil) {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                NSDate *now = [NSDate date];
                localNotification.fireDate = now;
                if (homepage.pageTitle  == nil) {
                    localNotification.alertBody = @"beacon  found";
                }
                else {
                    localNotification.alertBody = homepage.pageTitle;
                }
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
    
    [self getAndDisplayHomepagesAround];
}

@end
